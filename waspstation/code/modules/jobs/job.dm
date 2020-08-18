/datum/job
	var/list/alt_titles = list()
	var/senior_title

/datum/job/after_spawn(mob/living/H, mob/M, latejoin)
	..()
	var/obj/item/card/id/id = H.get_idcard(TRUE)
	var/datum/bank_account/account = id?.registered_account
	if(account && outfit)
		account.regen_vendables(outfit)
