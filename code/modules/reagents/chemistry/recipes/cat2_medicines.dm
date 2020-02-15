

/*****BRUTE*****/

/datum/chemical_reaction/helbidine
	name = "helbidine"
	id = /datum/reagent/medicine/C2/helbidine
	results = list(/datum/reagent/medicine/C2/helbidine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fluorine = 1, /datum/reagent/carbon = 1)
	mix_message = "The mixture turns into a thick, yellow powder."

/datum/chemical_reaction/libidine
	name = "libidine"
	id = /datum/reagent/medicine/C2/libidine
	results = list(/datum/reagent/medicine/C2/libidine = 3)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1)

/*****BURN*****/

/datum/chemical_reaction/lenotane
	name = "lenotane"
	id = /datum/reagent/medicine/C2/lenotane
	results = list(/datum/reagent/medicine/C2/lenotane = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/dermotane
	name = "dermotane"
	id = /datum/reagent/medicine/C2/dermotane
	results = list(/datum/reagent/medicine/C2/dermotane = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/hydrogen = 2)

/*****OXY*****/

/datum/chemical_reaction/hypalin
	name = "hypalin"
	id = /datum/reagent/medicine/C2/hypalin
	results = list(/datum/reagent/medicine/C2/hypalin = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/fuel/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/tiralin
	name = "tiralin"
	id = /datum/reagent/medicine/C2/tiralin
	results = list(/datum/reagent/medicine/C2/tiralin = 5)
	required_reagents = list(/datum/reagent/nitrogen = 3, /datum/reagent/acetone = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)

/*****TOX*****/

/datum/chemical_reaction/cryoaxalin
	name = "cryoaxalin"
	id = /datum/reagent/medicine/C2/cryoaxalin
	results = list(/datum/reagent/medicine/C2/cryoaxalin = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/potassium = 1, /datum/reagent/aluminium = 1)

/datum/chemical_reaction/syrilin
	name = "syrilin"
	id = /datum/reagent/medicine/C2/syrilin
	results = list(/datum/reagent/medicine/C2/syrilin = 5)
	required_reagents = list(/datum/reagent/sulfur = 1, /datum/reagent/fluorine = 1, /datum/reagent/toxin = 1, /datum/reagent/nitrous_oxide = 2)

/datum/chemical_reaction/penthrite
	name = "penthrite"
	id  = /datum/reagent/medicine/C2/penthrite
	results = list(/datum/reagent/medicine/C2/penthrite = 4)
	required_reagents = list(/datum/reagent/acetone = 1,  /datum/reagent/toxin/acid/nitracid = 1)
