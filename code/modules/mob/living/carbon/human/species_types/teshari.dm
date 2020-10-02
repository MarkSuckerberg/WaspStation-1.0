/datum/species/teshari
	name = "Teshari"
	id = "teshari"
	species_traits = list(MUTCOLORS, EYECOLOR, AGENDER, NO_UNDERWEAR)
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-1), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	sexes = FALSE

	mutanteyes = /obj/item/organ/eyes/tesheyes

/datum/species/teshari/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/mob/living/carbon/human/H = C
	H.dna.add_mutation(/datum/mutation/human/dorfism, MUT_OTHER)

/datum/species/teshari/on_species_loss(mob/living/carbon/H, datum/species/new_species)
	. = ..()
	H.dna.remove_mutation(/datum/mutation/human/dorfism)

