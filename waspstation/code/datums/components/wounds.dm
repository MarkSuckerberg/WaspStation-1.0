/datum/component/wound
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/bodypart/L
	var/woundtype ///Type of wound, aka "cut", "bruise", etc. Must be a string.
	var/wound_msg ///Message shown when wound inflicted
	var/list/hurtwords = list("hurts!") ///Message(s) shown when wounds hurt, not really needed but it's fun to have

	var/pain_chance ///Chance of random pain on process
	var/remove_pain ///Pain inflicted on removal of the wound. Unused.

	var/heal_chance ///Chance per tick of the wound healing.
	var/initial_pain ///Damage inflicted upon recieving the wound.
	var/irritate_chance ///Chance of random pain when walking
	var/irritate_pain ///Damage caused by random pain
	var/max_irritate_pain ///Maximum amount of pain that can be done per irritation.
	var/bleed ///Amount of bleeding per tick

	var/damage_type_initial ///Damage type first recieved
	var/damage_type ///Damage type of all subsequent pain recieved

	var/tended = 0 ///How good is the wound tended/how long will the tending last if continually irritated?

/datum/component/wound/Initialize(woundtype = "wound",
	wound_msg = "A wound appears on your limb!",
	pain_chance = 0,
	remove_pain = 0,
	heal_chance = 0,
	initial_pain = 0,
	irritate_chance = 0,
	irritate_pain = 0,
	max_irritate_pain = 7,
	damage_type_initial = BRUTE,
	damage_type = BRUTE)

	if(istype(parent, /obj/item/bodypart))
		L = parent
	else
		return COMPONENT_INCOMPATIBLE


	src.woundtype = woundtype
	src.wound_msg = wound_msg
	src.pain_chance = pain_chance
	src.remove_pain = remove_pain
	src.initial_pain = initial_pain
	src.irritate_chance = irritate_chance
	src.irritate_pain = irritate_pain
	src.max_irritate_pain = max_irritate_pain
	src.damage_type_initial = damage_type_initial
	src.damage_type = damage_type

	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/human/victim = L.owner

	L.wounds += woundtype
	to_chat(victim, "<span class='danger'>[wound_msg]</span>")
	if(damage_type == BURN)
		L.receive_damage(burn = initial_pain)
	else if(damage_type == STAMINA)
		L.receive_damage(stamina = initial_pain)
	else
		L.receive_damage(brute = initial_pain)
	SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "wounded", /datum/mood_event/wounded)

/datum/component/wound/RegisterWithParent()
	if(ishuman(L.owner))
		RegisterSignal(L.owner, COMSIG_MOVABLE_MOVED, .proc/irritate_check)
		RegisterSignal(L.owner, COMSIG_HUMAN_WOUND_HEAL_SURGERY, .proc/tend)

/datum/component/wound/UnregisterFromParent()
	if(ishuman(L.owner))
		UnregisterSignal(L.owner, list(COMSIG_MOVABLE_MOVED, COMSIG_HUMAN_WOUND_HEAL_SURGERY))

/datum/component/wound/process()
	if(ishuman(L.owner))
		processHuman()


/// Called every time a human with a wound moves, rolling a chance for the wound to inflict pain.
/// The chance is halved if the human is crawling or walking. There is an even smaller chance that the wound opens even more, negating all passive healing.
/datum/component/wound/proc/irritate_check()
	var/mob/living/carbon/human/victim = L.owner

	if(irritate_chance) //If there's no chance, why check?
		var/chance = irritate_chance
		if(victim.m_intent == MOVE_INTENT_WALK || victim.lying)
			chance *= 0.5
		if(prob(chance))
			if(!tended && irritate_pain < max_irritate_pain)
				irritate_pain++
				to_chat(victim, "<span class='userdanger'>The [woundtype] on your [L.name] [pick(hurtwords)] and gets worse!</span>")
			if(tended)
				tended--
				if(tended)
					to_chat(victim, "<span class='danger'>The tended [woundtype] on your [L.name] seems to shift a bit.</span>")
				else
					heal_chance = heal_chance / 2 //at least I'm not reupping the random pain amount, be thankful
					to_chat(victim, "<span class='userdanger'>The [woundtype] on your [L.name] reopens!</span>") //shoulda layed down, dunkass

/// Called whenever the wound is treated in surgery.
/// Halves the amount of pain done every time it's irritated, which, as long as the woundee doesn't reopen it, shouldn't ever happen. Also increases heal chance for quicker healing.
/// If called in-proc, don't specify the woundtype or it will likely fail to call. This is only to check for if the surgery is the correct one for the wound.
/datum/component/wound/proc/tend(quality, woundtype = src.woundtype)

	if(woundtype != src.woundtype)
		return

	irritate_pain = round((irritate_pain / 2))
	heal_chance = heal_chance * 2
	tended = quality


/// Called when then wound heals.
/// Heals the pain done by every irritation by the healamnt, and if that results in there being no irritate damage, the wound is healed.
/datum/component/wound/proc/rand_heal(healamnt = 1, woundtype = src.woundtype)
	var/mob/living/carbon/human/victim = L.owner

	irritate_pain = irritate_pain - healamnt

	if(irritate_pain <= 0)
		if(remove_pain)
			L.receive_damage(brute = remove_pain)
			to_chat(victim, "<span class='danger'>The [woundtype] on your [L.name] [pick(hurtwords)], but then seems to heal!</span>")
		else
			to_chat(victim, "<span class='notice'>The [woundtype] on your [L.name] seems to have fully healed!</span>")

		heal_wound()
	else
		to_chat(victim, "<span class='notice'>The [woundtype] on your [L.name] seems to have healed slightly.</span>")

/// This proc handles the final step and actual healing of a wound that was on a human.
/datum/component/wound/proc/heal_wound()
	var/mob/living/carbon/human/victim = L.owner

	L.wounds -= woundtype
	SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "wounded")
	qdel(src)


/// Wounds continually check for both random pain damage and random healing damage.
/datum/component/wound/proc/processHuman()
	var/mob/living/carbon/human/victim = L.owner

	if(victim.stat == DEAD)
		return

	if(!tended)
		if(bleed)
			victim.bleed(bleed)

		if(prob(pain_chance))
			if(damage_type == BURN)
				L.receive_damage(burn = irritate_pain)
			else if(damage_type == STAMINA)
				L.receive_damage(stamina = irritate_pain)
			else
				L.receive_damage(brute = irritate_pain)
			to_chat(victim, "<span class='userdanger'>The [woundtype] on your [L.name] [pick(hurtwords)]!</span>")

	if(prob(heal_chance))
		rand_heal(1)
