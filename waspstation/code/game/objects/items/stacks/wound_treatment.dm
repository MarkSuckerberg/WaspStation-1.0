/obj/item/stack/woundtreat
	name = "wound treatment stack"
	desc = "This shouldn't be here, but if you wanna try to treat wounds with it, knock yourself out. Not literally."
	icon = 'waspstation/icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	gender = PLURAL
	tool_behaviour = TOOL_SURGERY_START

/obj/item/stack/woundtreat/bandages
	name = "bandages"
	desc = "Some rolls and strips of cloth used by medical professionals and otherwise to cover wounds."
	singular_name = "bandage"
	icon_state = "bandage"
	grind_results = list(/datum/reagent/cellulose = 2)

/obj/item/stack/woundtreat/antibact
	name = "antibacterial ointment"
	desc = "Some ointment used for the cleansing of open wounds to prevent infection. Stinging and burning included."
	singular_name = "antibacterial ointment"
	icon_state = "antibact"
	grind_results = list(/datum/reagent/medicine/spaceacillin = 1, /datum/reagent/space_cleaner/sterilizine = 1)

/obj/item/stack/woundtreat/stitches
	name = "stitches"
	desc = "A set of fine threads and needles used to stitch closed open wounds such as bulletholes and large cuts."
	singular_name = "stitches"
	icon_state = "stitch"
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/stack/woundtreat/icepack
	name = "icepacks"
	desc = "A handy icepack used for the treatment of bruises and burns. It's slightly cold."
	singular_name = "icepack"
	icon_state = "icepack"
	amount = 3
	max_amount = 3
	grind_results = list(/datum/reagent/consumable/ice = 5)

