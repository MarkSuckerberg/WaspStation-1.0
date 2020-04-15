/datum/surgery/wound/stitch
	name = "Basic stitches"
	steps = list(/datum/surgery_step/antibiotic, /datum/surgery_step/stitch, /datum/surgery_step/bandage/gash)
	woundtype = "gash"

/datum/surgery_step/bandage/gash
	woundtype = "gash"
	quality = 3

/datum/surgery_step/bandage/cut/adv
	quality = 5

/datum/surgery_step/stitch
	name = "stitch wound closed"
	time = 16
	implements = list(/obj/item/stack/woundtreat/stitches = 100, /obj/item/stack/medical/suture = 90, /obj/item/stack/cable_coil = 50)

/datum/surgery_step/stitch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to stitch up [target]'s [parse_zone(target_zone)] with the [tool]...</span>",
		"<span class='notice'>[user] begins to stitch up [target]'s [parse_zone(target_zone)] with the [tool]...</span>",
		"<span class='notice'>[user] begins to stitch [target]'s [parse_zone(target_zone)]'...</span>")

/datum/surgery_step/stitch/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You finish stitching up [target]'s [parse_zone(target_zone)] with the [tool].</span>",
		"<span class='notice'>[user] finishes stitching up [target]'s [parse_zone(target_zone)] with the [tool].</span>",
		"<span class='notice'>[user] finishes stitching up [target]'s [parse_zone(target_zone)].</span>")
	if(istype(tool, /obj/item/stack))
		tool.use(1)
	return ..()
