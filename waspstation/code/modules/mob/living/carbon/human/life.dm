/mob/living/carbon/human/proc/handle_fractures()
	//this whole thing is hacky and WILL NOT work right with multiple hands
	//you've been warned
	var/obj/item/bodypart/L = get_bodypart("l_arm")
	var/obj/item/bodypart/R = get_bodypart("r_arm")

	if(istype(L) && L.bone_status == BONE_FLAG_BROKEN && held_items[1] && prob(30))
		emote("scream")
		visible_message("<span class='warning'>[src] screams and lets go of [held_items[1]] in pain.</span>", "<span class='userdanger'>A horrible pain in your [parse_zone(L)] makes it impossible to hold [held_items[1]]!</span>")
		dropItemToGround(held_items[1])

	if(istype(R) && R.bone_status == BONE_FLAG_BROKEN && held_items[2] && prob(30))
		emote("scream")
		visible_message("<span class='warning'>[src] screams and lets go of [held_items[2]] in pain.</span>", "<span class='userdanger'>A horrible pain in your [parse_zone(R)] makes it impossible to hold [held_items[2]]!</span>")
		dropItemToGround(held_items[2])

/mob/living/carbon/human/proc/update_shock()
	traumatic_shock = (maxHealth - health) + getOrganLoss(ORGAN_SLOT_BRAIN)

	// broken or ripped off organs will add quite a bit of pain
	for(var/thing in bodyparts)
		var/obj/item/bodypart/BP = thing
		if(BP.bone_status == BONE_FLAG_BROKEN)
			traumatic_shock += 15

	if(drunkenness)
		traumatic_shock = traumatic_shock / (1 + drunkenness / 100)
	return traumatic_shock

/mob/living/carbon/human/proc/handle_shock()
	if(status_flags & GODMODE)
		return

	if(NOPAIN in dna.species.species_traits)
		return

	if(IsUnconscious())
		return

	update_shock()

	if(health <= HEALTH_THRESHOLD_CRIT)
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 70)
		shock_stage += (traumatic_shock / 100)
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage - 1, 0)
		return

	var/list/ouch_list = list("It hurts!", "Agh, it hurts!", "The pain!", "You really need some painkillers...")
	var/list/very_ouch_list = list("It hurts so much!", "Dear God, the pain!", "The pain is unbearable!")
	var/list/holy_heck_the_ouch_list = list("PLEASE, JUST END THE PAIN!", "GOOD GOD, MAKE THE PAIN STOP!", "AGH, IT HURTS!!!")

	stuttering = max(stuttering, 4)
	blur_eyes(50)

	switch(shock_stage)
		if(30)
			visible_message("<span class='warning'><b>[src]</b> is having trouble keeping their eyes open.</span>", "<span class='userdanger'>[pick(ouch_list)]</span>")

		if(40)
			visible_message("<span class='warning'><b>[src]</b> grinds their teeth in pain.</span>", "<span class='userdanger'>[pick(ouch_list)]</span>")

		if(41 to 71)
			if(prob(2))
				to_chat(src, "<span class='userdanger'>[pick(very_ouch_list)]</span>")
				Knockdown(200)

		if(71 to INFINITY)
			if(prob(2))
				to_chat(src, "<span class='userdanger'>[pick(very_ouch_list)]</span>")
				Knockdown(200)
				return

	if(shock_stage > 90)
		if(prob(2) && stat == CONSCIOUS)
			visible_message("<span class='warning'><b>[src]</b> blacks out.</span>", "<span class='userdanger'>[pick("You black out from the pain!", "The pain is too much to bear!")]</span>")
			Unconscious(100)
		if(prob(5))
			adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)

	if(shock_stage > 150)
		if((mobility_flags & MOBILITY_STAND) && !resting && !buckled)
			visible_message("<span class='warning'><b>[src]</b> falls onto the floor, limp.</span>", "<span class='userdanger'>[pick(holy_heck_the_ouch_list)]</span>")
		Knockdown(200)

	if(shock_stage > 210 && can_heartattack() && !undergoing_cardiac_arrest())
		set_heartattack(TRUE)
		to_chat(src, "<span class='userdanger'>You feel your heart stop beating...</span>")
		//if you survived this long, you won't survive much longer
