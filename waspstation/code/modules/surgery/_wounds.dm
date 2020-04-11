/datum/surgery/wound
	name = "Wound Treatment"
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	self_operable = TRUE
	lying_required = FALSE
	ignore_clothes = TRUE
	var/woundtype = "wound"

/datum/surgery/wound/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/affected = H.get_bodypart(user.zone_selected)
		return affected.haswound(woundtype)

/datum/surgery_step/bandage
	name = "bandage wound"
	time = 32
	experience_given = MEDICAL_SKILL_EASY
	implements = list(/obj/item/stack/woundtreat/bandages = 100, /obj/item/stack/sheet/cloth = 70, /obj/item/stack/packageWrap = 50) //cargo will be bootleg medical, I bet on it
	var/woundtype = "wound"
	var/quality = 5 //How many irritations the surgery can survive before the wound reopens

	var/obj/item/bodypart/L = null

/datum/surgery_step/bandage/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.operated_bodypart
	if(L)
		display_results(user, target, "<span class='notice'>You begin bandaging [target]'s [parse_zone(target_zone)] with \the [tool]...</span>",
			"<span class='notice'>[user] begins bandaging [target]'s [parse_zone(target_zone)] with \the [tool].</span>",
			"<span class='notice'>[user] begins to bandage [target].</span>")

/datum/surgery_step/bandage/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(L)
		display_results(user, target, "<span class='notice'>You finish bandaging [target]'s [parse_zone(target_zone)] with \the [tool].</span>",
			"<span class='notice'>[user] finishes bandaging [target]'s [parse_zone(target_zone)] with \the [tool].</span>",
			"<span class='notice'>[user] finishes applying something on [target].</span>")
		SEND_SIGNAL(target, COMSIG_HUMAN_WOUND_HEAL, L, woundtype, quality)
	else
		to_chat(user, "<span class='warning'>You can't find [target]'s [parse_zone(user.zone_selected)], let alone bandage it!</span>")
	return ..()
