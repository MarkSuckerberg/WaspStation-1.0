/datum/component/wound
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/bodypart/L
	var/woundtype ///Type of wound, aka "cut", "bruise", etc. Must be a string.
	var/wound_msg ///Message shown when wound inflicted, always proceeded by " your [limb name here]!"

	var/pain_chance ///Chance of random pain
	var/remove_pain ///Pain inflicted on removal of the wound. Unused
	var/heal_chance ///Chance per tick of the wound healing.
	var/initial_pain ///Pain inflicted upon recieving the wound.
	var/irritate_chance ///Chance of random pain when walking
	var/irritate_pain ///Pain caused by random pain

	var/damage_type_initial ///Damage type first recieved
	var/damage_type ///Damage type of all subsequent pain recieved


/datum/component/wound/Initialize(woundtype = "wound",
	wound_msg = "A wound appears on",
	pain_chance = 0,
	remove_pain = 0,
	heal_chance = 0,
	initial_pain = 0,
	irritate_chance = 0,
	irritate_pain = 0,
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
	src.damage_type_initial = damage_type_initial
	src.damage_type = damage_type

	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/human/victim = L.owner

	L.wounds += woundtype
	to_chat(victim, "<span class='danger'>[wound_msg] your [L.name]!</span>")
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
		RegisterSignal(L.owner, COMSIG_HUMAN_EMBED_REMOVAL, .proc/tend_wound)

/datum/component/wound/UnregisterFromParent()
	if(ishuman(L.owner))
		UnregisterSignal(L.owner, list(COMSIG_MOVABLE_MOVED, COMSIG_HUMAN_EMBED_REMOVAL))

/datum/component/wound/process()
	if(ishuman(L.owner))
		processHuman()


/// Called every time a human with a wound moves, rolling a chance for the wound to inflict pain. The chance is halved if the human is crawling or walking.
/datum/component/wound/proc/irritate_check()
	var/mob/living/carbon/human/victim = L.owner

	var/chance = irritate_chance
	if(victim.m_intent == MOVE_INTENT_WALK || victim.lying)
		chance *= 0.5

	if(prob(chance))
		if(damage_type == BURN)
			L.receive_damage(burn = irritate_pain)
		else if(damage_type == STAMINA)
			L.receive_damage(stamina = irritate_pain)
		else
			L.receive_damage(brute = irritate_pain)
		to_chat(victim, "<span class='danger'>The [woundtype] on your [L.name] hurts!</span>")


/// Called when then wound randomly heals after healing.
/datum/component/wound/proc/randheal()
	var/mob/living/carbon/human/victim = L.owner

	if(remove_pain)
		L.receive_damage(brute = remove_pain)
		to_chat(victim, "<span class='danger'>The [woundtype] on your [L.name] hurts, but then seems to heal!</span>")
	else
		to_chat(victim, "<span class='notice'>The [woundtype] on your [L.name] seems to have fully healed!</span>")

	tend_wound()

/// This proc handles the final step and actual removal of an embedded/stuck item from a human, whether or not it was actually removed safely.
/// Pass TRUE for to_hands if we want it to go to the victim's hands when they pull it out
/datum/component/wound/proc/tend_wound()
	var/mob/living/carbon/human/victim = L.owner

	if(!victim.has_wounds())
		L.wounds -= woundtype
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "wounded")
	qdel(src)


/// Items embedded/stuck to humans both check whether they randomly fall out (if applicable), as well as if the target mob and limb still exists.
/// Items harmfully embedded in humans have an additional check for random pain (if applicable)
/datum/component/wound/proc/processHuman()
	var/mob/living/carbon/human/victim = L.owner

	if(victim.stat == DEAD)
		return

	if(prob(pain_chance))
		if(damage_type == BURN)
			L.receive_damage(burn = irritate_pain)
		else if(damage_type == STAMINA)
			L.receive_damage(stamina = irritate_pain)
		else
			L.receive_damage(brute = irritate_pain)
		to_chat(victim, "<span class='userdanger'>The [woundtype] on your [L.name] hurts!</span>")

	if(prob(heal_chance))
		irritate_pain--
		if(!irritate_pain > 0)
			randheal()
		else
			to_chat(victim, "<span class='notice'>The [woundtype] on your [L.name] seems to have healed slightly.</span>")
