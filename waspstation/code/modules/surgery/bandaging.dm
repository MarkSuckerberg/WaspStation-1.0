/datum/surgery/wound/cut
	name = "Cut bandaging"
	steps = list(/datum/surgery_step/antibiotic, /datum/surgery_step/bandage/cut)
	woundtype = "cut"

/datum/surgery_step/bandage/cut
	woundtype = "cut"
	quality = 3

/datum/surgery_step/bandage/cut/adv
	woundtype = "cut"
	quality = 5

/datum/surgery_step/antibiotic
	name = "apply antibiotic"
	time = 16
	implements = list(/obj/item/stack/medical/ointment = 100, /obj/item/reagent_containers = 70)

/datum/surgery_step/antibiotic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to apply [tool] on [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] begins to apply [tool] on [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] begins to apply something on [target].</span>")

/datum/surgery_step/antibiotic/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item/reagent_containers)
		var/obj/item/reagent_containers/RC = tool
		if(RC.reagents.has_reagent(/datum/reagent/consumable/ethanol, 15) || RC.reagents.has_reagent(/datum/reagent/space_cleaner, 10) || RC.reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine, 5))
			return TRUE
		return TRUE

/datum/surgery_step/antibiotic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You finish applying [tool] on [target]'s [parse_zone(target_zone)]...</span>",
		"<span class='notice'>[user] finishes applying [tool] on [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] finishes applying something on [target].</span>")
	if(istype(tool, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = tool
		RC.reagents.reaction(target, TOUCH, 10)
	return ..()
