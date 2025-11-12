/datum/xeno_strain/tosser
	name = CARRIER_TOSSER
	description = "In exchange for your ability to carry eggs and place traps you gain the ability to gestate lesser facehuggers. They won't grow into a larva unless the host is nested, but they'll temporarily blind and slowly poison the host, and can be tossed directly onto them."
	flavor_description = "Our brood is small but numerous. We will pelt them from afar, overwhelming their senses and rotting their insides."
	icon_state_prefix = null

	actions_to_remove = list(
		/datum/action/xeno_action/onclick/place_trap,
		/datum/action/xeno_action/onclick/set_hugger_reserve,
		/datum/action/xeno_action/activable/retrieve_egg,
	)
	actions_to_add = list(
		/datum/action/xeno_action/activable/throw_lesser_hugger,
	)

	behavior_delegate_type = /datum/behavior_delegate/carrier_tosser

/datum/xeno_strain/tosser/apply_strain(mob/living/carbon/xenomorph/carrier/carrier)
	carrier.eggs_cur = 0
	carrier.eggs_max = 0
	carrier.egg_planting_range = 0

/datum/behavior_delegate/carrier_tosser
	name = "Tosser Carrier Behavior Delegate"
	var/lesser_facehuggers_cur = 99
	var/lesser_facehuggers_max = 99//3

/datum/behavior_delegate/carrier_tosser/append_to_stat()
	. = list()
	. += "Lesser Facehuggers: [lesser_facehuggers_cur] / [lesser_facehuggers_max]"

/datum/behavior_delegate/carrier_tosser/on_life()
	. = ..()
	if((lesser_facehuggers_cur < lesser_facehuggers_max))
		lesser_facehuggers_cur++
		// how do i maake a good tiemr help

/datum/behavior_delegate/carrier_tosser/handle_death(mob/M)
	var/mob/living/carbon/xenomorph/carrier/carrier_owner = M
	if(lesser_facehuggers_cur)
		//Baby hugger explosion!
		var/obj/item/clothing/mask/facehugger/lesser/hugger
		carrier_owner.visible_message(SPAN_XENOWARNING("The chittering mass of very tiny aliens is trying to escape [carrier_owner]!"))
		for(var/i in 1 to lesser_facehuggers_cur)
			if(prob(75))
				hugger = new(carrier_owner.loc, carrier_owner.hivenumber)
				step_away(hugger, carrier_owner, 1)

/datum/action/xeno_action/activable/throw_lesser_hugger
	name = "Throw Lesser Facehugger"
	action_icon_state = "throw_hugger_lesser"
	macro_path = /datum/action/xeno_action/verb/verb_throw_facehugger_lesser
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_4

/datum/action/xeno_action/activable/throw_lesser_hugger/use_ability(atom/target)
	..()
	var/mob/living/carbon/xenomorph/carrier/carrier_owner = owner

	var/datum/behavior_delegate/carrier_tosser/behavior = carrier_owner.behavior_delegate

	var/obj/item/clothing/mask/facehugger/lesser/lesser_hugger = carrier_owner.get_active_hand()

	if(lesser_hugger)
		behavior.lesser_facehuggers_cur++
		qdel(lesser_hugger)
		to_chat(src, SPAN_XENONOTICE("We take the lesser facehugger and carry it for safekeeping. Now sheltering: [behavior.lesser_facehuggers_cur] / [behavior.lesser_facehuggers_max]."))
		return

	if(!behavior.lesser_facehuggers_cur)
		to_chat(carrier_owner, SPAN_WARNING("We have no lesser facehuggers to throw!"))
		return FALSE

	lesser_hugger = new(carrier_owner, carrier_owner.hivenumber)
	behavior.lesser_facehuggers_cur--
	carrier_owner.put_in_active_hand(lesser_hugger)
	to_chat(carrier_owner, SPAN_XENONOTICE("We grab one of the lesser facehuggers in our storage. Now sheltering: [behavior.lesser_facehuggers_cur] / [behavior.lesser_facehuggers_max]."))
	carrier_owner.update_icons()
	return
