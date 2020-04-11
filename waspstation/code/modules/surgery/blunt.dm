/datum/surgery/wound/blunt
	name = "Blunt trauma "
	steps = list(/datum/surgery_step/ice, /datum/surgery_step/bandage/blunt)
	woundtype = "cut"

/datum/surgery_step/bandage/blunt
	woundtype = "bruise"
	quality = 3

/datum/surgery_step/bandage/blunt/adv
	quality = 5

/datum/surgery_step/ice
	name = "apply ice"
	time = 32
	implements = list(/obj/item/stack/woundtreat/icepack = 100, /obj/item/gun/energy/temperature = 70)

/datum/surgery_step/ice/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to apply [tool] on [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] begins to apply [tool] on [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] begins to apply something on [target]...</span>")

/datum/surgery_step/ice/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You finish applying [tool] on [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] finishes applying [tool] on [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] finishes applying something on [target].</span>")
	if(istype(tool, /obj/item/stack))
		tool.use(1)
	return ..()
