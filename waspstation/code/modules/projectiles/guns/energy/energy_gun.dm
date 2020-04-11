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
	fire_delay = 15
	var/wielded = FALSE

	lefthand_file = 'waspstation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	lefthand_file = 'waspstation/icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/energy/e_gun/emitcannon/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/gun/energy/e_gun/emitcannon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed)

/// triggered on wield of two handed item
/obj/item/gun/energy/e_gun/emitcannon/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/gun/energy/e_gun/emitcannon/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/gun/energy/e_gun/emitcannon/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!wielded)
		to_chat(user, "<span class='danger'>You need to hold [src] with two hands to fire it!</span>")
		return 0
	..()
