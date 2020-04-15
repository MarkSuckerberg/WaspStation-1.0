/mob/living/carbon/proc/heal_wounds()
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		SEND_SIGNAL(src, COMSIG_HUMAN_WOUND_HEAL, L)

	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "wounded")

/mob/living/carbon/proc/has_wounds()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/I in L.wounds)
			return 1

/mob/living/carbon/proc/wounds_in_part(var/obj/item/bodypart/L)
	return L.wounds
