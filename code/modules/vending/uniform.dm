/obj/machinery/vending/uniform
	name = "\improper Uniform Vendor"
	desc = "Dispenses job-related clothing."



/obj/machinery/vending/uniform/ui_static_data(mob/user)
	. = ..()
	var/obj/item/card/id/C = user.get_idcard(TRUE)
	var/datum/bank_account/account = C?.registered_account

	if(account)
		.["product_records"] = list()
		for (var/datum/data/vending_product/R in account.account_vendables)
			var/list/data = list(
				path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
				name = R.name,
				price = R.custom_price || default_price,
				max_amount = R.max_amount,
				ref = REF(R)
			)
			.["product_records"] += list(data)

/obj/machinery/vending/uniform/ui_data(mob/user)
	. = ..()
	var/obj/item/card/id/C = user.get_idcard(TRUE)
	var/datum/bank_account/account = C?.registered_account

	if(account)
		.["stock"] = list()
		for (var/datum/data/vending_product/R in account.account_vendables)
			.["stock"][R.name] = R.amount
