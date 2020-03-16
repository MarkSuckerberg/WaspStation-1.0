/datum/job/explorer
	title = "Explorer"
	flag = EXPLORER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/explorer

	access = list(ACCESS_MINING_STATION, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MINING, ACCESS_TELEPORTER, ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY)
	minimal_access = list(ACCESS_MINING_STATION, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CURATOR

/datum/outfit/job/explorer
	name = "Explorer"
	jobtype = /datum/job/explorer

	shoes = /obj/item/clothing/shoes/workboots/mining
	belt = /obj/item/pda/shaftminer
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/curator/treasure_hunter
	l_hand = /obj/item/storage/firstaid
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = 	/obj/item/flashlight/seclite
	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/mining_voucher=1,\
		/obj/item/stack/marker_beacon/ten=1)

/datum/outfit/job/explorer/equipped
	name = "Explorer (Equipment)"
	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/gas/explorer
	suit = /obj/item/clothing/suit/space/eva
	head = /obj/item/clothing/head/helmet/space/eva
	back = /obj/item/tank/jetpack/carbondioxide
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
