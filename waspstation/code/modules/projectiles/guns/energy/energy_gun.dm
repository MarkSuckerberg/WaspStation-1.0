/obj/item/gun/energy/e_gun/lieutenant
	name = "advanced stun revolver"
	desc = "An advanced stun revolver with the capacity to shoot both disabler and lethal lasers."
	icon = 'waspstation/icons/obj/guns/energy.dmi'
	icon_state = "bsgun"
	item_state = "gun"
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/electrode/old)
	ammo_x_offset = 1

/obj/item/gun/energy/e_gun/emitcannon
	name = "emitter cannon"
	desc = "The framework of an emitter haphazardly attached to a trigger assembly. What could go wrong?"
	icon = 'waspstation/icons/obj/guns/energy.dmi'
	icon_state = "emitgun"
	item_state = "gun"
	force = 15
	ammo_type = list(/obj/item/ammo_casing/energy/emitter)
	ammo_x_offset = 1
	fire_delay = 15
