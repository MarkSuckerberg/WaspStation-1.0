// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/C2
	metabolization_rate = 0.2

/******BRUTE******/
/*Suffix: -bidine*/

/datum/reagent/medicine/C2/helbidine //only REALLY a C2 if you heal the other damages but not being able to outright heal the other guys is close enough to damaging
	name = "Helbidine"
	description = "Named after the norse goddess Hel, this medicine heals the patient's bruises the closer they are to death. Burns, toxins, and asphyxition will increase healing but these damages must be maintained while the drug is being metabolized or the drug will react negatively."
	color = "#9400D3"
	taste_description = "cold and lifeless"
	overdose_threshold = 35
	reagent_state = SOLID
	var/helbent = FALSE
	var/beginning_combo = 0
	var/reaping = FALSE

/datum/reagent/medicine/C2/helbidine/on_mob_metabolize(mob/living/carbon/M)
	beginning_combo = M.getToxLoss() + M.getOxyLoss() + M.getFireLoss() //This DOES mean you can cure Tox/Oxy and then do burn to maintain the brute healing that way.
	return ..()

/datum/reagent/medicine/C2/helbidine/on_mob_life(mob/living/carbon/M)
	. = TRUE
	var/cccombo = M.getToxLoss() + M.getOxyLoss() + M.getFireLoss()
	var/healed_this_iteration = FALSE
	if(cccombo >= beginning_combo)
		M.adjustBruteLoss(FLOOR(cccombo/-15,0.1)) //every 15 damage adds 1 per tick
		healed_this_iteration = TRUE
	else
		M.adjustToxLoss((beginning_combo-cccombo)*0.1) //If you are just healing instead of converting the damage we'll KINDLY do it for you AND make it the most difficult!

	if(healed_this_iteration && !reaping && prob(0.0001)) //janken with the grim reaper!
		reaping = TRUE
		var/list/RockPaperScissors = list("rock" = "paper", "paper" = "scissors", "scissors" = "rock") //choice = loses to
		if(M.apply_status_effect(/datum/status_effect/necropolis_curse,CURSE_BLINDING))
			helbent = TRUE
		to_chat(M, "<span class='hierophant'>Malevolent spirits appear before you, bartering your life in a 'friendly' game of rock, paper, scissors. Which do you choose?</span>")
		var/timeisticking = world.time
		var/RPSchoice = input(M, "Janken Time! You have 60 Seconds to Choose!", "Rock Paper Scissors",null) as null|anything in RockPaperScissors
		if(QDELETED(M) || (timeisticking+(1.1 MINUTES) < world.time))
			reaping = FALSE
			return //good job, you ruined it
		if(!RPSchoice)
			to_chat(M, "<span class='hierophant'>You decide to not press your luck, but the spirits remain... hopefully they'll go away soon.</span>")
			reaping = FALSE
			return
		var/grim = pick(RockPaperScissors)
		if(grim == RPSchoice) //You Tied!
			to_chat(M, "<span class='hierophant'>You tie, and the malevolent spirits disappear... for now.</span>")
			reaping = FALSE
		else if(RockPaperScissors[RPSchoice] == grim) //You lost!
			to_chat(M, "<span class='hierophant'>You lose, and the malevolent spirits smirk eerily as they surround your body.</span>")
			M.dust()
			return
		else //VICTORY ROYALE
			to_chat(M, "<span class='hierophant'>You win, and the malevolent spirits fade away as well as your wounds.</span>")
			M.revive(full_heal = TRUE, admin_revive = FALSE)
			M.reagents.del_reagent(type)
			return

	..()
	return

/datum/reagent/medicine/C2/helbidine/overdose_process(mob/living/carbon/M)
	if(!helbent)
		M.apply_necropolis_curse(CURSE_WASTING | CURSE_BLINDING)
		helbent = TRUE
	..()
	return TRUE

/datum/reagent/medicine/C2/helbidine/on_mob_delete(mob/living/L)
	if(helbent)
		L.remove_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE)
	..()

/datum/reagent/medicine/C2/libidine //messes with your liber
	name = "Libidine"
	description = "A bruise reliever. Does minor liver damage."
	color = "#ECEC8D" // rgb: 236	236	141
	taste_description = "bitter with a hint of alcohol"
	reagent_state = SOLID

/datum/reagent/medicine/C2/libidine/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.3*REM)
	M.adjustBruteLoss(-4*REM)
	..()
	return TRUE

/******BURN******/
/*Suffix: -otane*/
/datum/reagent/medicine/C2/lenotane
	name = "Lenotane"
	description = "Used to treat burns. Makes you move slower while it is in your system. Applies stomach damage when it leaves your system."
	reagent_state = LIQUID
	color = "#6171FF"
	var/resetting_probability = 0
	var/spammer = 0

/datum/reagent/medicine/C2/lenotane/on_mob_life(mob/living/carbon/M)
		M.adjustFireLoss(-4 * REM)
		M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.5 * REM)
		..()
		return TRUE
/datum/reagent/medicine/C2/lenotane/on_mob_metabolize(mob/living/carbon/M)
	M.add_movespeed_modifier(MOVESPEED_ID_LENTANE, update=TRUE, priority=100, multiplicative_slowdown=1.50, blacklisted_movetypes=(FLYING|FLOATING))
	. = ..()
/datum/reagent/medicine/C2/lenotane/on_mob_end_metabolize(mob/living/carbon/M)
	M.remove_movespeed_modifier(MOVESPEED_ID_LENTANE)

	. = ..()
/datum/reagent/medicine/C2/dermotane
	name = "Dermotane"
	description = "Used to treat burns. Does minor eye damage."
	reagent_state = LIQUID
	color = "#8C93FF"
	var/resetting_probability = 0
	var/message_cd = 0

/datum/reagent/medicine/C2/dermotane/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-3*REM)
	M.adjustOrganLoss(ORGAN_SLOT_EYES,0.25*REM)
	..()
	return TRUE

/******OXY******/
/*Suffix: -lin*/
#define	HYPALIN_RATIO 5		//# Oxygen damage to result in 1 tox

/datum/reagent/medicine/C2/hypalin
	name = "Hypalin"
	description = "Restores oxygen deprivation while producing a lesser amount of toxic byproducts. Both scale with exposure to the drug and current amount of oxygen deprivation. Overdose causes toxic byproducts regardless of oxygen deprivation."
	reagent_state = LIQUID
	color = "#FF6464"
	overdose_threshold = 35 // at least 2 full syringes +some, this stuff is nasty if left in for long

/datum/reagent/medicine/C2/hypalin/on_mob_life(mob/living/carbon/human/M)
	var/oxycalc = 2.5*REM*current_cycle
	if(!overdosed)
		oxycalc = min(oxycalc,M.getOxyLoss()+0.5) //if NOT overdosing, we lower our toxdamage to only the damage we actually healed with a minimum of 0.1*current_cycle. IE if we only heal 10 oxygen damage but we COULD have healed 20, we will only take toxdamage for the 10. We would take the toxdamage for the extra 10 if we were overdosing.
	M.adjustOxyLoss(-oxycalc, 0)
	M.adjustToxLoss(oxycalc/HYPALIN_RATIO, 0)
	if(prob(current_cycle) && M.losebreath)
		M.losebreath--
	..()
	return TRUE

/datum/reagent/medicine/C2/hypalin/overdose_process(mob/living/carbon/human/M)
	metabolization_rate += 1
	..()
	return TRUE

#undef	HYPALIN_RATIO

/datum/reagent/medicine/C2/tiralin
	name = "Tiralin"
	description = "An oxygen deprivation medication that causes fatigue. Prolonged exposure causes the patient to fall asleep once the medicine metabolizes."
	color = "#FF6464"
	var/drowsycd = 0

/datum/reagent/medicine/C2/tiralin/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-4)
	M.adjustStaminaLoss(2)
	if(drowsycd && (world.time > drowsycd))
		M.drowsyness += 10
		drowsycd = world.time + (45 SECONDS)
	else if(!drowsycd)
		drowsycd = world.time + (15 SECONDS)
	..()
	return TRUE

/datum/reagent/medicine/C2/tiralin/on_mob_end_metabolize(mob/living/L)
	if(current_cycle > 20)
		L.Sleeping(10 SECONDS)
	..()

/******TOXIN******/
/*Suffix: -lin*/

/datum/reagent/medicine/C2/cryoaxalin
	name = "Cryoaxalin"
	description = "A medicine that shifts functionality based on temperature. Colder temperatures incurs radiation removal while hotter temperatures promote antitoxicity. Damages the heart." //CHEM HOLDER TEMPS, NOT AIR TEMPS
	var/radbonustemp = (T0C - 100) //being below this number gives you 10% off rads.

/datum/reagent/medicine/C2/cryoaxalin/on_mob_metabolize(mob/living/carbon/human/M)
	. = ..()
	radbonustemp = rand(radbonustemp - 50, radbonustemp + 50) // Basically this means 50K and below will always give the percent heal, and upto 150K could. Calculated once.

/datum/reagent/medicine/C2/cryoaxalin/on_mob_life(mob/living/carbon/human/M)
	var/chemtemp = min(M.reagents?.chem_temp, 1000)
	chemtemp = chemtemp ? chemtemp : 273 //why do you have null sweaty
	var/healypoints = 0 //5 healypoints = 1 heart damage; 5 rads = 1 tox damage healed for the purpose of healypoints

	//you're hot
	var/toxcalc = min(round((chemtemp-1000)/175+5,0.1),5) //max 5 tox healing a tick
	if(toxcalc > 0)
		M.adjustToxLoss(toxcalc*-2)
		healypoints += toxcalc

	//and you're cold
	var/radcalc = round((T0C-chemtemp)/6,0.1) //max ~45 rad loss unless you've hit below 0K. if so, wow.
	if(radcalc > 0)
		//no cost percent healing if you are SUPER cold (on top of cost healing)
		if(chemtemp < radbonustemp*0.1) //if you're super chilly, it takes off 25% of your current rads
			M.radiation = round(M.radiation * 0.75)
		else if(chemtemp < radbonustemp)//else if you're under the chill-zone, it takes off 10% of your current rads
			M.radiation = round(M.radiation * 0.9)
		M.radiation -= radcalc
		healypoints += (radcalc/5)


	//you're yes and... oh no!
	healypoints = round(healypoints,0.1)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, healypoints/5)
	..()
	return TRUE

#define issyrinormusc(A)	(istype(A,/datum/reagent/medicine/C2/syrilin) || istype(A,/datum/reagent/medicine/C2/morthalin)) //musc is metab of syrin so let's make sure we're not purging either

/datum/reagent/medicine/C2/syrilin //Inject >> SYRINge
	name = "Syrilin"
	description = "A potent antidote for intravenous use with a narrow therapeutic index, it is considered an active prodrug of morthalin."
	reagent_state = LIQUID
	color = "#8CDF24" // heavy saturation to make the color blend better
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 6
	var/conversion_amount

/datum/reagent/medicine/C2/syrilin/on_transfer(atom/A, method=INJECT, trans_volume)
	if(method != INJECT || !iscarbon(A))
		return
	var/mob/living/carbon/C = A
	if(trans_volume >= 0.6) //prevents cheesing with ultralow doses.
		C.adjustToxLoss(-2.5 * min(2, trans_volume) * REM, 0)	  //This is to promote iv pole use for that chemotherapy feel.
	var/obj/item/organ/liver/L = C.internal_organs_slot[ORGAN_SLOT_LIVER]
	if((L.organ_flags & ORGAN_FAILING) || !L)
		return
	conversion_amount = trans_volume * (min(100 -C.getOrganLoss(ORGAN_SLOT_LIVER), 80) / 100) //the more damaged the liver the worse we metabolize.
	C.reagents.remove_reagent(/datum/reagent/medicine/C2/syrilin, conversion_amount)
	C.reagents.add_reagent(/datum/reagent/medicine/C2/morthalin, conversion_amount)
	..()

/datum/reagent/medicine/C2/syrilin/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.8)
	M.adjustToxLoss(-2*REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(issyrinormusc(R))
			continue
		M.reagents.remove_reagent(R.type,0.4)

	..()
	. = 1

/datum/reagent/medicine/C2/syrilin/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	M.reagents.add_reagent(/datum/reagent/medicine/C2/morthalin, 0.225 * REM)
	..()
	. = 1

/datum/reagent/medicine/C2/morthalin //MUScles
	name = "Morthalin"
	description = "The active metabolite of syrilin. Causes muscle weakness on overdose"
	reagent_state = LIQUID
	color = "#DFD54E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	var/datum/brain_trauma/mild/muscle_weakness/U

/datum/reagent/medicine/C2/morthalin/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1)
	M.adjustToxLoss(-2*REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(issyrinormusc(R))
			continue
		M.reagents.remove_reagent(R.type,0.2)
	..()
	. = 1

/datum/reagent/medicine/C2/morthalin/overdose_start(mob/living/carbon/M)
	U = new()
	M.gain_trauma(U, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/medicine/C2/morthalin/on_mob_delete(mob/living/carbon/M)
	if(U)
		QDEL_NULL(U)
	return ..()

/datum/reagent/medicine/C2/morthalin/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	..()
	. = 1

#undef issyrinormusc
/******COMBOS******/
/*Suffix: Combo of healing, prob gonna get wack REAL fast*/
/datum/reagent/medicine/C2/instabidinetane
	name = "Synthflesh (Instabidinetane)"
	description = "Has a 100% chance of instantly healing brute and burn damage at the cost of toxicity (75% of damage healed). Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/C2/instabidinetane/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1)
	if(iscarbon(M))
		var/mob/living/carbon/C = M //whoever the fuck named the var "Carbies" needs to see a psychologist imho
		if (C.stat == DEAD)
			show_message = 0
		if(method in list(PATCH, TOUCH))
			var/harmies = min(C.getBruteLoss(),C.adjustBruteLoss(-2 * reac_volume)*-1)
			var/burnies = min(C.getFireLoss(),C.adjustFireLoss(-2 * reac_volume)*-1)
			C.adjustToxLoss((harmies+burnies)*0.66)
			if(show_message)
				to_chat(C, "<span class='danger'>You feel your burns and bruises healing! It stings like hell!</span>")
			SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
			//Has to be at less than TRESHOLD_UNHUSK burn damage and have 100 isntabidinetane before unhusking. Corpses dont metabolize.
			if(HAS_TRAIT_FROM(M, TRAIT_HUSK, "burn") && C.getFireLoss() < TRESHOLD_UNHUSK && C.reagents.has_reagent(/datum/reagent/medicine/C2/instabidinetane, 100))
				C.cure_husk("burn")
				C.visible_message("<span class='nicegreen'>With most of the burnt off flesh replaced, [C] looks a lot healthier.")
	..()
	return TRUE

/******ORGAN HEALING******/
/*Suffix: -rite*/
/datum/reagent/medicine/C2/penthrite
	name = "Penthrite"
	description = "An explosive compound used to stabilize heart conditions. May interfere with stomach acid!"
	color = "#F5F5F5"
	self_consuming = TRUE

/datum/reagent/medicine/C2/penthrite/on_mob_add(mob/living/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_STABLEHEART, type)

/datum/reagent/medicine/C2/penthrite/on_mob_metabolize(mob/living/M)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH,0.5 * REM)

/datum/reagent/medicine/C2/penthrite/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_STABLEHEART, type)
	. = ..()

/******NICHE******/
//todo

