/datum/component/outline
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/permanent

/datum/component/outline/Initialize(perm = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.permanent = perm
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/OnExamine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/OnClean)

	var/atom/movable/A = parent
	A.add_filter("sprite-bane", 2, list("type"="outline", "color"="#000000", "size"=1))

/datum/component/outline/Destroy()
	var/atom/movable/A = parent
	A.remove_filter("sprite-bane")
	return ..()

/datum/component/outline/InheritComponent(datum/component/C, i_am_original, perm)
	if(!i_am_original)
		return
	if(C)
		var/datum/component/outline/other = C
		permanent = other.permanent
	else
		permanent = perm

/datum/component/outline/proc/OnExamine(datum/source, mob/user, atom/thing)
	to_chat(user, "<span class='warning'>That outline is hideous!</span>")

/datum/component/outline/proc/OnAttackBy(datum/source, obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/soap))
		return

	var/obj/item/soap/S = I
	var/clean_speedies = S.cleanspeed * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+0.1,1)
	user.visible_message("<span class='notice'>[user] begins to scrub off the outlines surrounding [parent] with [S].</span>", "<span class='warning'>You begin to scrub out the outlines surrounding [parent] with [S]...</span>")
	if(do_after(user, clean_speedies, target = parent))
		user?.mind.adjust_experience(/datum/skill/cleaning, CLEAN_SKILL_GENERIC_WASH_XP)
		S.decreaseUses(user)
		OnClean(source, CLEAN_MEDIUM)
		return COMPONENT_NO_AFTERATTACK

/datum/component/outline/proc/OnClean(datum/source, clean_strength)
	if(clean_strength >= CLEAN_MEDIUM)
		var/atom/A = parent
		playsound(A, 'sound/effects/slosh.ogg', 50, TRUE)
		A.visible_message("<span class='notice'>The outline around [A] is washed away!")
		qdel(src)
