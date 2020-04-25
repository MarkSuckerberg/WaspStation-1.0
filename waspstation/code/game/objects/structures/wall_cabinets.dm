/obj/structure/wall_cabinet
	name = "wall cabinet"
	desc = "A small wall mounted cabinet that can hold an item."
	icon = 'waspstation/icons/obj/wallmounts.dmi' //WaspStation Edit - Better Icons
	icon_state = "cabinet"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 0.25

	var/obj/item/stored_item = null
	var/list/obj/item/storables = list()

	var/mapload_item = null
	var/opened = FALSE

/obj/structure/wall_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	icon_state = "[initial(icon_state)]_closed"
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
		opened = TRUE
		icon_state = "extinguisher_empty"
	else if(mapload_item)
		stored_item = new mapload_item

/obj/structure/wall_cabinet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It contains [stored_item ? "[stored_item]":"nothing"].</span>"
	. += "<span class='notice'>Alt-click to [opened ? "close":"open"] it.</span>"

/obj/structure/wall_cabinet/Destroy()
	if(stored_item)
		qdel(stored_item)
		stored_item = null
	return ..()

/obj/structure/wall_cabinet/contents_explosion(severity, target)
	if(stored_item)
		stored_item.ex_act(severity, target)

/obj/structure/wall_cabinet/handle_atom_del(atom/A)
	if(A == stored_item)
		stored_item = null
		update_icon()

/obj/structure/wall_cabinet/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && !stored_item)
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(is_type_in_list(I, storables))
		if(!stored_item && opened)
			if(!user.transferItemToLoc(I, src))
				return
			stored_item = I
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_icon()
			return TRUE
		else
			toggle_cabinet(user)
	else if(user.a_intent != INTENT_HARM)
		toggle_cabinet(user)
	else
		return ..()


/obj/structure/wall_cabinet/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "<span class='notice'>You take [stored_item] from [src].</span>")
		stored_item = null
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/wall_cabinet/attack_tk(mob/user)
	if(stored_item)
		stored_item.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [stored_item] from [src].</span>")
		stored_item = null
		opened = 1
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		update_icon()
	else
		toggle_cabinet(user)


/obj/structure/wall_cabinet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/wall_cabinet/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	toggle_cabinet(user)

/obj/structure/wall_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		to_chat(user, "<span class='warning'>[src] is broken open.</span>")
	else
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		opened = !opened
		update_icon()

/obj/structure/wall_cabinet/update_icon_state()
	if(!opened)
		icon_state = "[initial(icon_state)]_closed"
	else if(stored_item)
		icon_state = "[initial(icon_state)]_full"
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/structure/wall_cabinet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = 1
		opened = 1
		if(stored_item)
			stored_item.forceMove(loc)
			stored_item = null
		update_icon()


/obj/structure/wall_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/wall_cabinet(loc)
		else
			new /obj/item/stack/sheet/metal (loc, 2)
		if(stored_item)
			stored_item.forceMove(loc)
			stored_item = null
	qdel(src)

/obj/item/wallframe/wall_cabinet
	name = "wall cabinet frame"
	desc = "Used for building wall-mounted cabinets."
	icon_state = "extinguisher"
	result_path = /obj/structure/wall_cabinet

/obj/structure/wall_cabinet/firstaid
	icon_state = "medicabinet"
	storables = list(/obj/item/storage/firstaid)
	stored_item = /obj/item/storage/firstaid/regular
