#define CLAIM_DONTCLAIM 0
#define CLAIM_CLAIMIFNONE 1
#define CLAIM_OVERRIDE 2

/client
	var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
	var/datum/admin_help/current_ticket	//the current ticket the (usually) not-admin client is dealing with

// UI holder for admins
/datum/admin_help_ui

/client/proc/openTicketManager()
	set name = "Ticket Manager"
	set desc = "Opens the ticket manager"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	GLOB.ahelp_tickets.BrowseTickets(usr)

//
// Ticket manager
//

GLOBAL_DATUM_INIT(ahelp_tickets, /datum/admin_help_tickets, new)

/datum/admin_help_tickets
	var/list/unclaimed_tickets = list()
	var/list/active_tickets = list()
	var/list/closed_tickets = list()
	var/list/resolved_tickets = list()

	var/obj/effect/statclick/ticket_list/browse_statclick = new(null, null, null)
	var/obj/effect/statclick/ticket_list/ustatclick = new(null, null, AHELP_UNCLAIMED)
	var/obj/effect/statclick/ticket_list/astatclick = new(null, null, AHELP_ACTIVE)
	var/obj/effect/statclick/ticket_list/cstatclick = new(null, null, AHELP_CLOSED)
	var/obj/effect/statclick/ticket_list/rstatclick = new(null, null, AHELP_RESOLVED)

/datum/admin_help_tickets/Destroy()
	QDEL_LIST(unclaimed_tickets)
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	QDEL_LIST(resolved_tickets)
	QDEL_NULL(browse_statclick)
	QDEL_NULL(ustatclick)
	QDEL_NULL(astatclick)
	QDEL_NULL(cstatclick)
	QDEL_NULL(rstatclick)
	return ..()

/datum/admin_help_tickets/proc/TicketByID(id)
	var/list/lists = list(unclaimed_tickets, active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.id == id)
				return J

/datum/admin_help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	var/list/lists = list(unclaimed_tickets, active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.initiator_ckey == ckey)
				. += AH

//private
/datum/admin_help_tickets/proc/ListInsert(datum/admin_help/new_ticket)
	var/list/ticket_list
	switch(new_ticket.state)
		if(AHELP_UNCLAIMED)
			ticket_list = unclaimed_tickets
		if(AHELP_ACTIVE)
			ticket_list = active_tickets
		if(AHELP_CLOSED)
			ticket_list = closed_tickets
		if(AHELP_RESOLVED)
			ticket_list = resolved_tickets
		else
			CRASH("Invalid ticket state: [new_ticket.state]")
	var/num_closed = ticket_list.len
	if(num_closed)
		for(var/I in 1 to num_closed)
			var/datum/admin_help/AH = ticket_list[I]
			if(AH.id > new_ticket.id)
				ticket_list.Insert(I, new_ticket)
				return
	ticket_list += new_ticket

//opens the ticket listings for one of the 3 states
/datum/admin_help_tickets/proc/BrowseTickets(mob/user)
	var/client/C = user.client
	if(!C)
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[C.ckey]
	if(!admin_datum)
		message_admins("[C.ckey] attempted to browse tickets, but had no admin datum")
		return
	if(!admin_datum.admin_interface)
		admin_datum.admin_interface = new(user)
	admin_datum.admin_interface.ui_interact(user)

//TGUI TICKET THINGS
/datum/admin_help_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the ticket panel.")
		ui = new(user, src, "TicketBrowser", "ticket browser")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/admin_help_ui/ui_data(mob/user)
	var/datum/admins/admin_datum = GLOB.admin_datums[user.ckey]
	if(!admin_datum)
		log_admin_private("[user] sent a request to interact with the ticket browser without sufficient rights.")
		message_admins("[user] sent a request to interact with the ticket browser without sufficient rights.")
		return
	var/list/data = list()
	data["admin_ckey"] = user.ckey
	data["unclaimed_tickets"] = GLOB.ahelp_tickets.get_ui_ticket_data(AHELP_UNCLAIMED)
	data["open_tickets"] = GLOB.ahelp_tickets.get_ui_ticket_data(AHELP_ACTIVE)
	data["closed_tickets"] = GLOB.ahelp_tickets.get_ui_ticket_data(AHELP_CLOSED)
	data["resolved_tickets"] = GLOB.ahelp_tickets.get_ui_ticket_data(AHELP_RESOLVED)
	return data

/datum/admin_help_ui/ui_act(action, params)
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
	if(!admin_datum)
		message_admins("[usr] sent a request to interact with the ticket browser without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the ticket browser without sufficient rights.")
		return
	var/ticket_id = text2num(params["id"])
	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticket_id)
	//Doing action on a ticket claims it
	var/claim_ticket = CLAIM_DONTCLAIM
	switch(action)
		if("claim")
			if(ticket.claimed_admin)
				var/confirm = alert("This ticket is already claimed, override claim?",,"Yes", "No")
				if(confirm == "No")
					return
			claim_ticket = CLAIM_OVERRIDE
		if("reject")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Reject()
		if("ic")
			claim_ticket = CLAIM_OVERRIDE
			ticket.ICIssue()
		if("mhelp")
			claim_ticket = CLAIM_OVERRIDE
			ticket.MHelpThis()
		if("resolve")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Resolve()
		if("reopen")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Reopen()
		if("close")
			claim_ticket = CLAIM_OVERRIDE
			ticket.Close()
		if("view")
			ticket.TicketPanel()
		if("flw")
			admin_datum.admin_follow(get_mob_by_ckey(ticket.initiator.ckey))
		if("pm")
			usr.client.cmd_ahelp_reply(ticket.initiator)
			claim_ticket = CLAIM_CLAIMIFNONE
	if(claim_ticket == CLAIM_OVERRIDE || (claim_ticket == CLAIM_CLAIMIFNONE && !ticket.claimed_admin))
		ticket.Claim()

/datum/admin_help_tickets/proc/get_ui_ticket_data(state)
	var/list/l2b
	switch(state)
		if(AHELP_UNCLAIMED)
			l2b = unclaimed_tickets
		if(AHELP_ACTIVE)
			l2b = active_tickets
		if(AHELP_CLOSED)
			l2b = closed_tickets
		if(AHELP_RESOLVED)
			l2b = resolved_tickets
	if(!l2b)
		return
	var/list/dat = list()
	for(var/I in l2b)
		var/datum/admin_help/AH = I
		var/list/ticket = list(
			"id" = AH.id,
			"initiator_key_name" = AH.initiator_key_name,
			"name" = AH.name,
			"claimed_key_name" = AH.claimed_admin_key_name,
			"disconnected" = AH.initiator ? FALSE : TRUE,
			"state" = AH.state
		)
		dat += list(ticket)
	return dat

//End

//Tickets statpanel
/datum/admin_help_tickets/proc/stat_entry()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	var/list/L = list()
	var/num_disconnected = 0
	L[++L.len] = list("Active Tickets:", "[astatclick.update("[active_tickets.len]")]", null, REF(astatclick))
	astatclick.update("[active_tickets.len]")
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator)
			L[++L.len] = list("#[AH.id]. [AH.initiator_key_name]:", "[AH.statclick.update()]", REF(AH))
		else
			++num_disconnected
	if(num_disconnected)
		L[++L.len] = list("Disconnected:", "[astatclick.update("[num_disconnected]")]", null, REF(astatclick))
	L[++L.len] = list("Closed Tickets:", "[cstatclick.update("[closed_tickets.len]")]", null, REF(cstatclick))
	L[++L.len] = list("Resolved Tickets:", "[rstatclick.update("[resolved_tickets.len]")]", null, REF(rstatclick))
	return L

//Reassociate still open ticket if one exists
/datum/admin_help_tickets/proc/ClientLogin(client/C)
	C.current_ticket = CKey2ActiveTicket(C.ckey)
	if(C.current_ticket)
		C.current_ticket.initiator = C
		C.current_ticket.AddInteraction("green", "Client reconnected.")
		SSblackbox.LogAhelp(C.current_ticket.id, "Reconnected", "Client reconnected", C.ckey)

//Dissasociate ticket
/datum/admin_help_tickets/proc/ClientLogout(client/C)
	if(C.current_ticket)
		var/datum/admin_help/T = C.current_ticket
		T.AddInteraction("red", "Client disconnected.")
		SSblackbox.LogAhelp(T, "Disconnected", "Client disconnected", C.ckey)
		T.initiator = null

//Get a ticket given a ckey
/datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/l in list(unclaimed_tickets, active_tickets))
		for(var/I in l)
			var/datum/admin_help/AH = I
			if(AH.initiator_ckey == ckey)
				return AH

//
//TICKET LIST STATCLICK
//

/obj/effect/statclick/ticket_list
	var/current_state

/obj/effect/statclick/ticket_list/New(loc, name, state)
	current_state = state
	..()

/obj/effect/statclick/ticket_list/Click()
	GLOB.ahelp_tickets.BrowseTickets(usr)

//
// Ticket interaction
//

/datum/ticket_interaction
	var/time_stamp
	var/message_color = "default"
	var/from_user = ""
	var/to_user = ""
	var/message = ""

/datum/ticket_interaction/New()
	. = ..()
	time_stamp = time_stamp()

//called by admin topic
/obj/effect/statclick/ticket_list/proc/Action()
	Click()

//
// Ticket datum
//

/datum/admin_help
	var/id
	var/name
	var/state = AHELP_UNCLAIMED

	var/opened_at
	var/closed_at
	var/bwoink = FALSE

	var/client/initiator	//semi-misnomer, it's the person who ahelped/was bwoinked
	var/initiator_ckey
	var/initiator_key_name
	var/heard_by_no_admins = FALSE

	var/client/claimed_admin	//The admin that has claimed this ticket
	var/claimed_admin_key_name

	var/list/_interactions	//use AddInteraction() or, preferably, admin_ticket_log()

	var/obj/effect/statclick/ahelp/statclick

	var/static/ticket_counter = 0

//call this on its own to create a ticket, don't manually assign current_ticket
//msg is the title of the ticket: usually the ahelp text
//is_bwoink is TRUE if this ticket was started by an admin PM
/datum/admin_help/New(msg, client/C, is_bwoink)
	//clean the input msg
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg || !C || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time

	name = copytext_char(msg, 1, 100)

	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)
	if(initiator.current_ticket)	//This is a bug
		stack_trace("Multiple ahelp current_tickets")
		initiator.current_ticket.AddInteraction("red", "Ticket erroneously left open by code")
		initiator.current_ticket.Close()
	initiator.current_ticket = src

	TimeoutVerb()

	statclick = new(null, src)
	_interactions = list()

	GLOB.ahelp_tickets.unclaimed_tickets += src

	bwoink = is_bwoink

	if(is_bwoink)
		AddInteraction("blue", name, usr.ckey, initiator_key_name)
		message_admins("<font color='blue'>Ticket [TicketHref("#[id]")] created</font>")
		Claim()	//Auto claim bwoinks
	else
		MessageNoRecipient(msg)

		//send it to TGS if nobody is on and tell us how many were on
		var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [msg]")
		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
		if(admin_number_present <= 0)
			to_chat(C, "<span class='notice'>No active admins are online, your adminhelp was sent through TGS to admins who are available. This may use IRC or Discord.</span>", confidential = TRUE)
			heard_by_no_admins = TRUE

		SSredbot.send_discord_message("admin", "Ticket #[id] created by [usr.ckey] ([usr.real_name]): \"[msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]", "ticket")

/datum/admin_help/Destroy()
	RemoveActive()
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	return ..()

/datum/admin_help/proc/AddInteraction(msg_color, message, name_from, name_to)
	if(heard_by_no_admins && usr && usr.ckey != initiator_ckey)
		heard_by_no_admins = FALSE
		send2tgs(initiator_ckey, "Ticket #[id]: Answered by [key_name(usr)]")
	var/datum/ticket_interaction/interaction_message = new /datum/ticket_interaction
	interaction_message.message_color = msg_color
	interaction_message.message = message
	interaction_message.from_user = name_from
	interaction_message.to_user = name_to
	_interactions += interaction_message
	SStgui.update_uis(src)

/datum/admin_help/proc/TimeoutVerb()
	remove_verb(initiator, /client/verb/adminhelp)
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps

//private
/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state <= AHELP_ACTIVE)
		. += ClosureLinks(ref_src)

//private
/datum/admin_help/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"

//private
/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

//private
/datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

//message from the initiator without a target, all admins will see this
//won't bug irc/discord

/datum/admin_help/proc/TicketPanel()
	ui_interact(usr)

/datum/admin_help/ui_interact(mob/user, datum/tgui/ui)
	//Support multiple tickets open at once
	//ui_key = "ticket[id]"
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the ticket panel.")
		ui = new(user, src, "TicketMessenger", "Ticket Messenger")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/admin_help/ui_data(mob/user)
	var/datum/admins/admin_datum = GLOB.admin_datums[user.ckey]
	if(!admin_datum)
		message_admins("[user] sent a request to interact with the ticket window without sufficient rights.")
		log_admin_private("[user] sent a request to interact with the ticket window without sufficient rights.")
		return
	var/list/data = list()
	//Messages
	data["disconected"] = initiator
	data["time_opened"] = opened_at
	data["time_closed"] = closed_at
	data["ticket_state"] = state
	data["claimee"] = claimed_admin
	data["claimee_key"] = claimed_admin_key_name
	data["id"] = id
	data["sender"] = initiator_key_name
	data["world_time"] = world.time
	data["antag_status"] = "None"
	if(initiator)
		var/mob/living/M = initiator.mob
		if(M?.mind?.antag_datums)
			var/datum/antagonist/AD = M.mind.antag_datums[1]
			data["antag_status"] = AD.name
	data["messages"] = list()
	for(var/datum/ticket_interaction/message in _interactions)
		var/list/msg = list(
			"time" = message.time_stamp,
			"color" = message.message_color,
			"from" = message.from_user,
			"to" = message.to_user,
			"message" = message.message
		)
		data["messages"] += list(msg)
	return data

/datum/admin_help/ui_act(action, params)
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
	if(!admin_datum)
		message_admins("[usr] sent a request to interact with the ticket window without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the ticket window without sufficient rights.")
		return
	if(!check_rights(R_ADMIN))
		message_admins("[usr] sent a request to interact with the ticket window without sufficient rights. (Requires: R_ADMIN)")
		log_admin_private("[usr] sent a request to interact with the ticket window without sufficient rights.")
		return
	//Doing action on a ticket claims it
	var/claim_ticket = CLAIM_DONTCLAIM
	switch(action)
		if("sendpm")
			usr.client.cmd_ahelp_reply_instant(initiator, params["text"])
			claim_ticket = CLAIM_CLAIMIFNONE
		if("reject")
			Reject()
			claim_ticket = CLAIM_OVERRIDE
		if("mentorhelp")
			MHelpThis()
			claim_ticket = CLAIM_OVERRIDE
		if("close")
			Close()
			claim_ticket = CLAIM_OVERRIDE
		if("resolve")
			Resolve()
			claim_ticket = CLAIM_OVERRIDE
		if("markic")
			ICIssue()
			claim_ticket = CLAIM_OVERRIDE
		if("retitle")
			Retitle()
		if("reopen")
			Reopen()
			claim_ticket = CLAIM_OVERRIDE
		if("moreinfo")
			admin_datum.admin_more_info(get_mob_by_ckey(initiator.ckey))
		if("playerpanel")
			admin_datum.show_player_panel(get_mob_by_ckey(initiator.ckey))
		if("viewvars")
			usr.client.debug_variables(get_mob_by_ckey(initiator.ckey))
		if("subtlemsg")
			usr.client.cmd_admin_subtle_message(get_mob_by_ckey(initiator.ckey))
		if("flw")
			admin_datum.admin_follow(get_mob_by_ckey(initiator.ckey))
		if("traitorpanel")
			admin_datum.show_traitor_panel(get_mob_by_ckey(initiator.ckey))
		if("viewlogs")
			show_individual_logging_panel(get_mob_by_ckey(initiator.ckey))
		if("smite")
			usr.client.smite(get_mob_by_ckey(initiator.ckey))
	if(claim_ticket == CLAIM_OVERRIDE || (claim_ticket == CLAIM_CLAIMIFNONE && !claimed_admin))
		Claim()

/datum/admin_help/proc/MessageNoRecipient(msg)
	var/ref_src = "[REF(src)]"

	//Message to be sent to all admins
	var/admin_msg = "<span class='adminnotice'><span class='adminhelp'>Ticket [TicketHref("#[id]", ref_src)]</span><b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)]:</b> <span class='linkify'>[keywords_lookup(msg)]</span></span>"

	AddInteraction("red", msg, initiator_key_name, claimed_admin_key_name)
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [msg]")

	//send this msg to all admins
	for(var/client/X in GLOB.admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(X, sound('sound/effects/adminhelp.ogg'))
		window_flash(X, ignorepref = TRUE)
		to_chat(X,
			type = MESSAGE_TYPE_ADMINPM,
			html = admin_msg,
			confidential = TRUE)

	//show it to the person adminhelping too
	to_chat(initiator,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<span class='adminnotice'>PM to-<b>Admins</b>: <span class='linkify'>[msg]</span></span>",
		confidential = TRUE)
	SSblackbox.LogAhelp(id, "Ticket Opened", msg, null, initiator.ckey)

//Reopen a closed ticket
/datum/admin_help/proc/Reopen()
	if(state <= AHELP_ACTIVE)
		to_chat(usr, "<span class='warning'>This ticket is already open.</span>", confidential = TRUE)
		return

	if(GLOB.ahelp_tickets.CKey2ActiveTicket(initiator_ckey))
		to_chat(usr, "<span class='warning'>This user already has an active ticket, cannot reopen this one.</span>", confidential = TRUE)
		return

	statclick = new(null, src)
	GLOB.ahelp_tickets.active_tickets += src
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	switch(state)
		if(AHELP_CLOSED)
			SSblackbox.record_feedback("tally", "ahelp_stats", -1, "closed")
		if(AHELP_RESOLVED)
			SSblackbox.record_feedback("tally", "ahelp_stats", -1, "resolved")
	state = AHELP_ACTIVE
	closed_at = null
	if(initiator)
		initiator.current_ticket = src

	AddInteraction("purple", "Reopened by [key_name_admin(usr)]")
	var/msg = "<span class='adminhelp'>Ticket [TicketHref("#[id]")] reopened by [key_name_admin(usr)].</span>"
	message_admins(msg)
	log_admin_private(msg)
	SSblackbox.LogAhelp(id, "Reopened", "Reopened by [usr.key]", usr.ckey)
	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "reopened")
	TicketPanel()	//can only be done from here, so refresh it

//private
/datum/admin_help/proc/RemoveActive()
	if(state > AHELP_ACTIVE)
		return
	closed_at = world.time
	QDEL_NULL(statclick)
	if(state == AHELP_ACTIVE)
		GLOB.ahelp_tickets.active_tickets -= src
	else
		GLOB.ahelp_tickets.unclaimed_tickets -= src
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null

/datum/admin_help/proc/Claim(key_name = key_name_admin(usr), silent = FALSE)
	if(claimed_admin == usr)
		return
	if(initiator && !claimed_admin)
		to_chat(initiator, "<font color='red'>Your issue is being investigated by an administrator, please stand by.</span>")
	if(state == AHELP_UNCLAIMED)
		GLOB.ahelp_tickets.unclaimed_tickets -= src
		state = AHELP_ACTIVE
		GLOB.ahelp_tickets.ListInsert(src)
	var/updated = claimed_admin
	if(updated)
		AddInteraction("blue", "Claimed by [key_name] (Overwritten from [updated])")
	else
		AddInteraction("blue", "Claimed by [key_name]")
	claimed_admin = usr
	claimed_admin_key_name = usr.ckey
	if(!silent && !updated)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "claimed")
		var/msg = "Ticket [TicketHref("#[id]")] claimed by [key_name]."
		message_admins(msg)
		log_admin_private(msg)

	if(!bwoink && !silent && !updated)
		SSredbot.send_discord_message("admin", "Ticket #[id] is being investigated by [key_name(usr, include_link=0)]")

//Mark open ticket as closed/meme
/datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE)
	if(state > AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_CLOSED
	GLOB.ahelp_tickets.ListInsert(src)
	AddInteraction("red", "Closed by [key_name].")
	if(!silent)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "closed")
		var/msg = "Ticket [TicketHref("#[id]")] closed by [key_name]."
		message_admins(msg)
		SSblackbox.LogAhelp(id, "Closed", "Closed by [usr.key]", null, usr.ckey)
		log_admin_private(msg)

	if(!bwoink && !silent)
		SSredbot.send_discord_message("admin", "Ticket #[id] closed by [key_name(usr, include_link=0)]")

//Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	if(state > AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_RESOLVED
	GLOB.ahelp_tickets.ListInsert(src)

	addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 50)

	AddInteraction("green", "Resolved by [key_name].")
	to_chat(initiator, "<span class='adminhelp'>Your ticket has been resolved by an admin. The Adminhelp verb will be returned to you shortly.</span>", confidential = TRUE)
	if(!silent)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "resolved")
		var/msg = "Ticket [TicketHref("#[id]")] resolved by [key_name]"
		message_admins(msg)
		SSblackbox.LogAhelp(id, "Resolved", "Resolved by [usr.key]", null, usr.ckey)
		log_admin_private(msg)

	if(!bwoink)
		SSredbot.send_discord_message("admin", "Ticket #[id] resolved by [key_name(usr, include_link=0)]")

//Close and return ahelp verb, use if ticket is incoherent
/datum/admin_help/proc/Reject(key_name = key_name_admin(usr))
	if(state > AHELP_ACTIVE)
		return

	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))

		to_chat(initiator, "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>", confidential = TRUE)
		to_chat(initiator, "<font color='red'><b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again.</font>", confidential = TRUE)
		to_chat(initiator, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting.", confidential = TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "rejected")
	var/msg = "Ticket [TicketHref("#[id]")] rejected by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("red", "Rejected by [key_name].")
	SSblackbox.LogAhelp(id, "Rejected", "Rejected by [usr.key]", null, usr.ckey)
	Close(silent = TRUE)

	if(!bwoink)
		SSredbot.send_discord_message("admin", "Ticket #[id] rejected by [key_name(usr, include_link=0)]")

//Resolve ticket with IC Issue message
/datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
	if(state > AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as IC issue! -</b></font><br>"
	msg += "<font color='red'>Your issue has been determined by an administrator to be an in character issue and does NOT require administrator intervention at this time. For further resolution you should pursue options that are in character.</font><br>"

	if(initiator)
		to_chat(initiator, msg, confidential = TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "IC")
	msg = "Ticket [TicketHref("#[id]")] marked as IC by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("red", "Marked as IC issue by [key_name]")
	SSblackbox.LogAhelp(id, "IC Issue", "Marked as IC issue by [usr.key]", null,  usr.ckey)
	Resolve(silent = TRUE)

	if(!bwoink)
		SSredbot.send_discord_message("admin", "Ticket #[id] marked as IC by [key_name(usr, include_link=0)]")

/datum/admin_help/proc/MHelpThis(key_name = key_name_admin(usr))
	if(state > AHELP_ACTIVE)
		return

	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))

		to_chat(initiator, "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
		to_chat(initiator, "<font color='red'>This question may regard <b>game mechanics or how-tos</b>. Such questions should be asked with <b>Mentorhelp</b>.</font>")

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "mhelp this")
	var/msg = "Ticket [TicketHref("#[id]")] told to mentorhelp by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("red", "Told to mentorhelp by [key_name].")
	if(!bwoink)
		SSredbot.send_discord_message("admin", "Ticket #[id] told to mentorhelp by [key_name(usr, include_link=0)]")
	Close(silent = TRUE)

/datum/admin_help/proc/Retitle()
	var/new_title = input(usr, "Enter a title for the ticket", "Rename Ticket", name) as text|null
	if(new_title)
		name = new_title
		//not saying the original name cause it could be a long ass message
		var/msg = "Ticket [TicketHref("#[id]")] titled [name] by [key_name_admin(usr)]"
		message_admins(msg)
		log_admin_private(msg)
	TicketPanel()	//we have to be here to do this

//Forwarded action from admin/Topic
/datum/admin_help/proc/Action(action)
	testing("Ahelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("mhelp")
			MHelpThis()

//
// TICKET STATCLICK
//

/obj/effect/statclick/ahelp
	var/datum/admin_help/ahelp_datum

/obj/effect/statclick/ahelp/Initialize(mapload, datum/admin_help/AH)
	ahelp_datum = AH
	. = ..()

/obj/effect/statclick/ahelp/update()
	return ..(ahelp_datum.name)

/obj/effect/statclick/ahelp/Click()
	ahelp_datum.TicketPanel()

/obj/effect/statclick/ahelp/Destroy()
	ahelp_datum = null
	return ..()

//
//CLIENT PROCS
//

/client/proc/giveadminhelpverb()
	add_verb(src, /client/verb/adminhelp)
	deltimer(adminhelptimerid)
	adminhelptimerid = 0

// Used for methods where input via arg doesn't work
/client/proc/get_adminhelp()
	var/msg = input(src, "Please describe your problem concisely and an admin will help as soon as they're able. Include the names of the people you are ahelping against if applicable.", "Adminhelp contents") as text|null
	adminhelp(msg)

/client/verb/adminhelp(msg as message)
	set category = "Admin"
	set name = "Adminhelp"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>", confidential = TRUE)
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='danger'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>", confidential = TRUE)
		return
	if(handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = trim(msg)

	if(!msg)
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(current_ticket)
		if(alert(usr, "You already have a ticket open. Is this for the same issue?",,"Yes","No") != "No")
			if(current_ticket)
				current_ticket.MessageNoRecipient(msg)
				current_ticket.TimeoutVerb()
				return
			else
				to_chat(usr, "<span class='warning'>Ticket not found, creating new one...</span>", confidential = TRUE)
		else
			current_ticket.AddInteraction("yellow", "[usr] opened a new ticket.")
			current_ticket.Close()

	//Extremely simple system of suggesting mentorhelp instead of adminhelp
	var/msg_lower = lowertext(msg)
	if((findtext(msg_lower, "how to") == 1 || findtext(msg_lower, "how do") == 1) && GLOB.mentors.len)
		if(alert("\"[msg]\" looks like a game mechanics question, would you like to ask in mentorhelp instead?", "Adminhelp?", "Yes, mentorhelp", "No, adminhelp") == "Yes, mentorhelp")
			mentorhelp(msg)
			return

	new /datum/admin_help(msg, src, FALSE)

//
// LOGGING
//

//Use this proc when an admin takes action that may be related to an open ticket on what
//what can be a client, ckey, or mob
/proc/admin_ticket_log(what, message, whofrom = "", whoto = "", color = "white")
	var/client/C
	var/mob/Mob = what
	if(istype(Mob))
		C = Mob.client
	else
		C = what
	if(istype(C) && C.current_ticket)
		C.current_ticket.AddInteraction(color, message, whofrom, whoto)
		return C.current_ticket
	if(istext(what))	//ckey
		var/datum/admin_help/AH = GLOB.ahelp_tickets.CKey2ActiveTicket(what)
		if(AH)
			AH.AddInteraction(color, message, whofrom, whoto)
			return AH


//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/send2tgs_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2tgs(source,final)
		send2otherserver(source,final)


/proc/send2tgs(msg,msg2)
	msg = replacetext(replacetext(msg, "\proper", ""), "\improper", "")
	msg2 = replacetext(replacetext(msg2, "\proper", ""), "\improper", "")
	world.TgsTargetedChatBroadcast("[msg] | [msg2]", TRUE)

//
/proc/send2otherserver(source,msg,type = "Ahelp",target_servers)
	var/comms_key = CONFIG_GET(string/comms_key)
	if(!comms_key)
		return

	var/our_id = CONFIG_GET(string/cross_comms_name)
	var/list/message = list()
	message["message_sender"] = source
	message["message"] = msg
	message["source"] = "([our_id])"
	message["key"] = comms_key
	message += type

	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/I in servers)
		if(I == our_id) //No sending to ourselves
			continue
		if(target_servers && !(I in target_servers))
			continue
		world.send_cross_comms(I, message)

/// Sends a message to a given cross comms server by name (by name for security).
/world/proc/send_cross_comms(server_name, list/message, auth = TRUE)
	set waitfor = FALSE
	if (auth)
		var/comms_key = CONFIG_GET(string/comms_key)
		if(!comms_key)
			debug_world_log("Server cross-comms message not sent for lack of configured key")
			return
		message["key"] = comms_key
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	var/server_url = servers[server_name]
	if (!server_url)
		CRASH("Invalid cross comms config: [server_name]")
	world.Export("[server_url]?[list2params(message)]")


/proc/tgsadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/proc/keywords_lookup(msg,external)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/founds = ""
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							var/is_antag = 0
							if(found.mind && found.mind.special_role)
								is_antag = 1
							founds += "Name: [found.name]([found.real_name]) Key: [found.key] Ckey: [found.ckey] [is_antag ? "(Antag)" : null] "
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A HREF='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(found)]'>?</A>|<A HREF='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(found)]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	if(external)
		if(founds == "")
			return "Search Failed"
		else
			return founds

	return msg

#undef CLAIM_DONTCLAIM
#undef CLAIM_CLAIMIFNONE
#undef CLAIM_OVERRIDE
