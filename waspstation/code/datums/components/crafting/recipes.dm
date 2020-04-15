/datum/crafting_recipe/splint
	name = "Makeshift Splint"
	reqs = list(
			/obj/item/stack/rods = 2,
			/obj/item/stack/sheet/cloth = 4)
	result = /obj/item/stack/medical/splint/ghetto
	category = CAT_MEDICAL

/datum/crafting_recipe/stitches
	name = "Stitches"
	reqs = list(
			/obj/item/stack/rods = 1,
			/obj/item/stack/cable_coil = 2)
	result = /obj/item/stack/woundtreat/stitches
	category = CAT_MEDICAL
	subcategory = CAT_WOUNDTREAT

/datum/crafting_recipe/bandage
	name = "Bandages"
	reqs = list(
			/obj/item/stack/sheet/cloth = 2)
	result = /obj/item/stack/woundtreat/bandages
	category = CAT_MEDICAL
	subcategory = CAT_WOUNDTREAT

/datum/crafting_recipe/icepack
	name = "Icepack"
	reqs = list(
		/datum/reagent/consumable/ice = 20,
		/obj/item/stack/sheet/cloth = 1
	)
	category = CAT_MEDICAL
	subcategory = CAT_WOUNDTREAT

/datum/crafting_recipe/emitcannon
	name = "Emitter Cannon"
	reqs = list(
		/obj/item/circuitboard/machine/emitter = 1,
		/obj/item/stock_parts/micro_laser = 4,
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/stack/packageWrap = 4)
	result = /obj/item/gun/energy/e_gun/emitcannon
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

