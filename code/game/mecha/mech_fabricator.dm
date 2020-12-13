/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab
	var/time_coeff = 1
	var/component_coeff = 1
	var/datum/techweb/specialized/autounlocking/exofab/stored_research
	var/sync = 0
	var/part_set
	var/datum/design/being_built
	var/list/queue = list()
	var/list/datum/design/matching_designs
	var/processing_queue = 0
	var/screen = "main"
	var/link_on_init = TRUE
	var/temp
	var/datum/component/remote_materials/rmat
	var/list/part_sets = list(
								"Cyborg",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Durand",
								"H.O.N.K",
								"Phazon",
								"Exosuit Equipment",
								"Exosuit Ammunition",
								"Cyborg Upgrade Modules",
								"IPC components",
								"Misc"
								)
	var/datum/bank_account/linked_account

/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	stored_research = new
	matching_designs = list()
	rmat = AddComponent(/datum/component/remote_materials, "mechfab", mapload && link_on_init)
	RefreshParts() //Recalculating local material sizes if the fab isn't linked
	return ..()

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0

	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	rmat.set_local_size((200000 + (T*50000)))

	//resources adjustment coefficient (1 -> 0.85 -> 0.7 -> 0.55)
	T = 1.15
	for(var/obj/item/stock_parts/micro_laser/Ma in component_parts)
		T -= Ma.rating*0.15
	component_coeff = T

	//building time adjustment coefficient (1 -> 0.8 -> 0.6)
	T = -1
	for(var/obj/item/stock_parts/manipulator/Ml in component_parts)
		T += Ml.rating
	time_coeff = round(initial(time_coeff) - (initial(time_coeff)*(T))/5,0.01)

/obj/machinery/mecha_part_fabricator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[rmat.local_size]</b> material units.<br>Material consumption at <b>[component_coeff*100]%</b>.<br>Build time reduced by <b>[100-time_coeff*100]%</b>.</span>"
		if(linked_account)
			. += "<span class='notice'><br><b>Linked account:</b> [linked_account.account_holder]'s bank account<span>"

/obj/machinery/mecha_part_fabricator/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	req_access = list()
	say("DB error \[Code 0x00F1\]")
	sleep(10)
	say("Attempting auto-repair...")
	sleep(15)
	say("User DB corrupted \[Code 0x00FA\]. Truncating data structure...")
	sleep(30)
	say("User DB truncated. Please contact your Nanotrasen system operator for future assistance.")

/obj/machinery/mecha_part_fabricator/proc/output_parts_list(set_name)
	var/output = ""
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(D.build_type & MECHFAB)
			if(!(set_name in D.category))
				continue
			output += "<div class='part'>[output_part_info(D)]<br>"
			if(check_resources(D))
				output += "<a href='?src=[REF(src)];part=[D.id]'>Build</a> | "
			output += "<a href='?src=[REF(src)];add_to_queue=[D.id]'>Add to queue</a><a href='?src=[REF(src)];part_desc=[D.id]'>?</a></div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_info(datum/design/D)
	var/output = "[initial(D.name)] (Cost: [output_part_cost(D)]) [get_construction_time_w_coeff(D)/10]sec"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_cost(datum/design/D)
	var/i = 0
	var/output
	for(var/c in D.materials)
		var/datum/material/M = c
		output += "[i?" | ":null][get_resource_cost_w_coeff(D, M)] [M.name]"
		i++
	return output

/obj/machinery/mecha_part_fabricator/proc/output_ui_header()
	var/output
	output += "<div class='statusDisplay'><b>Mecha Fabricator</b><br>"
	output += "Security protocols: [(obj_flags & EMAGGED)? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]<br>"
	if (rmat.mat_container)
		output += "<a href='?src=[REF(src)];screen=resources'><B>Material Amount:</B> [rmat.format_amount()]</A>"
	else
		output += "<font color='red'>No material storage connected, please contact the quartermaster.</font>"
	output += "<br><a href='?src=[REF(src)];sync=1'>Sync with R&D servers</a><br>"
	if(linked_account)
		output += "<br><a href='?src=[REF(src)];link_id=1'>Unlink Linked Account: ([linked_account.account_holder])</a><br>"
	else
		output += "<br><a href='?src=[REF(src)];link_id=1'>Link Material Payment Account</a><br>"
	output += "<a href='?src=[REF(src)];screen=main'>Main Screen</a>"
	output += "</div>"
	output += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	return output

/obj/machinery/mecha_part_fabricator/proc/get_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		var/datum/material/M = R
		resources[M] = get_resource_cost_w_coeff(D, M)
	return resources

/obj/machinery/mecha_part_fabricator/proc/check_resources(datum/design/D)
	if(D.reagents_list.len) // No reagents storage - no reagent designs.
		return FALSE
	var/datum/component/material_container/materials = rmat.mat_container
	if(materials.has_materials(get_resources_w_coeff(D)))
		return TRUE
	return FALSE

/obj/machinery/mecha_part_fabricator/proc/output_ui_materials()
	var/output
	output += "<div class='statusDisplay'><h3>Material Storage:</h3>"
	for(var/mat_id in rmat.mat_container.materials)
		var/datum/material/M = mat_id
		var/amount = rmat.mat_container.materials[mat_id]
		var/ref = REF(M)
		output += "* [amount] of [M.name]: "
		if(amount >= MINERAL_MATERIAL_AMOUNT) output += "<A href='?src=[REF(src)];remove_mat=1;material=[ref]'>Eject</A>"
		if(amount >= MINERAL_MATERIAL_AMOUNT*5) output += "<A href='?src=[REF(src)];remove_mat=5;material=[ref]'>5x</A>"
		if(amount >= MINERAL_MATERIAL_AMOUNT) output += "<A href='?src=[REF(src)];remove_mat=50;material=[ref]'>All</A>"
		output += "<br>"
	output += "</div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/search(string)
	matching_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(!(D.build_type & MECHFAB))
			continue
		if(findtext(D.name,string))
			matching_designs.Add(D)

/obj/machinery/mecha_part_fabricator/proc/output_ui_search()
	var/output
	output += "<h2>Search Results:</h2>"
	for(var/datum/design/D in matching_designs)
		output += "<div class='part'>[output_part_info(D)]<br>"
		if(check_resources(D))
			output += "<a href='?src=[REF(src)];part=[D.id]'>Build</a> | "
		output += "<a href='?src=[REF(src)];add_to_queue=[D.id]'>Add to queue</a><a href='?src=[REF(src)];part_desc=[D.id]'>?</a></div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D)
	var/list/res_coef = get_resources_w_coeff(D)

	var/datum/component/material_container/materials = rmat.mat_container
	if (!materials)
		say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if (rmat.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	if(!check_resources(D))
		say("Not enough resources. Queue processing stopped.")
		return FALSE
	//Wasp start - Material Costs
	if(materials.linked_account)
		if(!linked_account)
			say("No bank account linked. Please swipe an ID to link one.")
			return FALSE
		if(!linked_account.has_money(materials.get_material_list_cost(res_coef)))
			say("Not enough credits in bank account. Queue processing stopped.")
			return FALSE
	being_built = D
	desc = "It's building \a [initial(D.name)]."
	materials.use_materials(res_coef, using_account = linked_account)
	//Wasp end
	rmat.silo_log(src, "built", -1, "[D.name]", res_coef)

	add_overlay("fab-active")
	use_power = ACTIVE_POWER_USE
	updateUsrDialog()
	sleep(get_construction_time_w_coeff(D))
	use_power = IDLE_POWER_USE
	cut_overlay("fab-active")
	desc = initial(desc)

	var/location = get_step(src,(dir))
	var/obj/item/I = new D.build_path(location)
	I.material_flags |= MATERIAL_NO_EFFECTS //Find a better way to do this.
	I.set_custom_materials(res_coef)
	say("\The [I] is complete.")
	being_built = null

	updateUsrDialog()
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/update_queue_on_page()
	send_byjax(usr,"mecha_fabricator.browser","queue",list_queue())
	return

/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(set_name)
	if(set_name in part_sets)
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			if(D.build_type & MECHFAB)
				if(set_name in D.category)
					add_to_queue(D)

/obj/machinery/mecha_part_fabricator/proc/add_to_queue(D)
	if(!istype(queue))
		queue = list()
	if(D)
		queue[++queue.len] = D
	return queue.len

/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !ISINTEGER(index) || !istype(queue) || (index<1 || index>queue.len))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/process_queue()
	var/datum/design/D = queue[1]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	temp = null
	while(D)
		if(machine_stat&(NOPOWER|BROKEN))
			return FALSE
		if(build_part(D))
			remove_from_queue(1)
		else
			return FALSE
		D = LAZYACCESS(queue, 1)
	say("Queue processing finished successfully.")

/obj/machinery/mecha_part_fabricator/proc/list_queue()
	var/output = "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		output += "<br>Nothing"
	else
		output += "<ol>"
		var/i = 0
		for(var/datum/design/D in queue)
			i++
			var/obj/part = D.build_path
			output += "<li[!check_resources(D)?" style='color: #f00;'":null]>"
			output += initial(part.name) + " - "
			output += "[i>1?"<a href='?src=[REF(src)];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] "
			output += "[i<queue.len?"<a href='?src=[REF(src)];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] "
			output += "<a href='?src=[REF(src)];remove_from_queue=[i]'>Remove</a></li>"

		output += "</ol>"
		output += "<a href='?src=[REF(src)];process_queue=1'>Process queue</a> | <a href='?src=[REF(src)];clear_queue=1'>Clear queue</a>"
	return output

/obj/machinery/mecha_part_fabricator/proc/sync()
	for(var/obj/machinery/computer/rdconsole/RDC in oview(7,src))
		RDC.stored_research.copy_research_to(stored_research)
		updateUsrDialog()
		say("Successfully synchronized with R&D server.")
		return

	temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=[REF(src)];clear_temp=1'>Return</a>"
	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, var/datum/material/resource, roundto = 1)
	return round(D.materials[resource]*component_coeff, roundto)

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(datum/design/D, roundto = 1) //aran
	return round(initial(D.construction_time)*time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user)
	. = ..()
	var/dat, left_part
	user.set_machine(src)
	var/turf/exit = get_step(src,(dir))
	if(exit.density)
		say("Error! Part outlet is obstructed.")
		return
	if(temp)
		left_part = temp
	else if(being_built)
		var/obj/I = being_built.build_path
		left_part = {"<div class='statusDisplay'>Building [initial(I.name)].<BR>
							Please wait until completion...</div>"}
	else
		left_part = output_ui_header()
		switch(screen)
			if("main")
				for(var/part_set in part_sets)
					left_part += "<a href='?src=[REF(src)];part_set=[part_set]'>[part_set]</a> - <a href='?src=[REF(src)];partset_to_queue=[part_set]'>Add all parts to queue</a><br>"
			if("parts")
				left_part += output_parts_list(part_set)
			if("resources")
				left_part += output_ui_materials()
			if("search")
				left_part += output_ui_search()
	dat = {"<html>
			<head>
			<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
			<title>[name]</title>
				<style>
				.res_name {font-weight: bold; text-transform: capitalize;}
				.red {color: #f00;}
				.part {margin-bottom: 10px;}
				.arrow {text-decoration: none; font-size: 10px;}
				body, table {height: 100%;}
				td {vertical-align: top; padding: 5px;}
				html, body {padding: 0px; margin: 0px;}
				h1 {font-size: 18px; margin: 5px 0px;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				</head><body>
				<body>
				<table style='width: 100%;'>
				<tr>
				<td style='width: 65%; padding-right: 10px; margin: 3px 0;'>
				[left_part]
				</td>
				<td style='width: 35%; background: #000000; border: 1px solid #40628a;	padding: 4px; margin: 3px 0;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>
				</body>
				</html>"}

	var/datum/browser/popup = new(user, "mecha_fabricator", name, 1000, 430)
	popup.set_content(dat)
	popup.open()
	//user << browse(dat, "window=mecha_fabricator;size=1000x430")
	//onclose(user, "mecha_fabricator")
	return

/obj/machinery/mecha_part_fabricator/Topic(href, href_list)
	if(..())
		return
	if(href_list["part_set"])
		var/tpart_set = href_list["part_set"]
		if(tpart_set)
			if(tpart_set=="clear")
				part_set = null
			else
				part_set = tpart_set
				screen = "parts"
	if(href_list["part"])
		var/T = href_list["part"]
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					if(!processing_queue)
						build_part(D)
					else
						add_to_queue(D)
					break
	if(href_list["add_to_queue"])
		var/T = href_list["add_to_queue"]
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					add_to_queue(D)
					break
		return update_queue_on_page()
	if(href_list["remove_from_queue"])
		remove_from_queue(text2num(href_list["remove_from_queue"]))
		return update_queue_on_page()
	if(href_list["partset_to_queue"])
		add_part_set_to_queue(href_list["partset_to_queue"])
		return update_queue_on_page()
	if(href_list["process_queue"])
		INVOKE_ASYNC(src, .proc/do_process_queue)
	if(href_list["clear_temp"])
		temp = null
	if(href_list["screen"])
		screen = href_list["screen"]
	if(href_list["queue_move"] && href_list["index"])
		var/index = text2num(href_list["index"])
		var/new_index = index + text2num(href_list["queue_move"])
		if(isnum(index) && isnum(new_index) && ISINTEGER(index) && ISINTEGER(new_index))
			if(ISINRANGE(new_index,1,queue.len))
				queue.Swap(index,new_index)
		return update_queue_on_page()
	if(href_list["clear_queue"])
		queue = list()
		return update_queue_on_page()
	if(href_list["sync"])
		sync()
	if(href_list["part_desc"])
		var/T = href_list["part_desc"]
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					var/obj/part = D.build_path
					temp = {"<h1>[initial(part.name)] description:</h1>
								[initial(part.desc)]<br>
								<a href='?src=[REF(src)];clear_temp=1'>Return</a>
								"}
					break
	if(href_list["search"]) //Search for designs with name matching pattern
		search(href_list["to_search"])
		screen = "search"

	if(href_list["remove_mat"] && href_list["material"])
		var/datum/material/Mat = locate(href_list["material"])
		eject_sheets(Mat, text2num(href_list["remove_mat"]))

	if(href_list["link_id"])
		link_user_id(usr)

	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/do_process_queue()
	if(processing_queue || being_built)
		return FALSE
	processing_queue = 1
	process_queue()
	processing_queue = 0

/obj/machinery/mecha_part_fabricator/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = rmat.mat_container
	if (!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if (rmat.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location(), linked_account)
	var/list/matlist = list()
	matlist[eject_sheet] = text2num(eject_amt)
	rmat.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, /atom/proc/cut_overlay, "fab-load-[M.name]"), 10)
	updateUsrDialog()

/obj/machinery/mecha_part_fabricator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return TRUE

	if(default_deconstruction_crowbar(W))
		return TRUE

	if(istype(W, /obj/item/card/id))
		link_user_id(user)

	return ..()

/obj/machinery/mecha_part_fabricator/AltClick(mob/user)
	. = ..()
	link_user_id(user)

/obj/machinery/mecha_part_fabricator/proc/link_user_id(mob/user)
	if(linked_account)
		linked_account = null
		to_chat(user, "<span class='notice'>You unlink [src]'s linked account.</span>")
	else
		var/obj/item/card/id/user_id = user.get_idcard(TRUE)
		if(user_id?.registered_account)
			linked_account = user_id.registered_account
			to_chat(user, "<span class='notice'>You link [user_id.registered_account.account_holder]'s bank account on [src].</span>")
		else
			to_chat(user, "<span class='warning'>No bank account found!</span>")

/obj/machinery/mecha_part_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE

	return TRUE

/obj/machinery/mecha_part_fabricator/maint
	link_on_init = FALSE
