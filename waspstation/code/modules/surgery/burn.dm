/datum/surgery/wound/burn
	name = "First degree burn treatment"
	steps = list(/datum/surgery_step/ice, /datum/surgery_step/bandage/burn)
	woundtype = "singe"

/datum/surgery_step/bandage/burn
	woundtype = "singe"
	quality = 3

/datum/surgery_step/bandage/burn/adv
	quality = 5

//Second degree burn treatment (blisters)
/datum/surgery/wound/burn
	name = "Second degree burn treatment"
	steps = list(/datum/surgery_step/antibiotic, /datum/surgery_step/ice, /datum/surgery_step/bandage/burn/deep)
	woundtype = "blister"

/datum/surgery_step/bandage/burn/deep
	woundtype = "blister"

//Third degree burn treatment (blackened skin)
/datum/surgery/wound/burn
	name = "Third degree burn treatment"
	steps = list(/datum/surgery_step/antibiotic, /datum/surgery_step/ice, /datum/surgery_step/bandage/burn/deep)
	woundtype = "blackened skin"

/datum/surgery_step/bandage/burn/fatal
	woundtype = "blackened skin"
