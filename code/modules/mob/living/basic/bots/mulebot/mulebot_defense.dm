
/mob/living/basic/bot/mulebot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/stock_parts/power_store/cell) && bot_access_flags & BOT_COVER_MAINTS_OPEN)
		if(cell)
			to_chat(user, span_warning("[src] already has a power cell!"))
			return TRUE
		if(!user.transferItemToLoc(attacking_item, src))
			return TRUE
		cell = attacking_item
		//diag_hud_set_mulebotcell()
		user.visible_message(
			span_notice("[user] inserts \a [cell] into [src]."),
			span_notice("You insert [cell] into [src]."),
		)
		return TRUE
	else if(is_wire_tool(attacking_item) && bot_access_flags & BOT_COVER_MAINTS_OPEN)
		return attack_hand(user)
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1 + attacking_item.force * 2))
			unload()
			user.visible_message(span_danger("[user] knocks [load] off [src] with \the [attacking_item]!"),
									span_danger("You knock [load] off [src] with \the [attacking_item]!"))
		else
			to_chat(user, span_warning("You hit [src] with \the [attacking_item] but to no effect!"))
			return ..()
	else
		return ..()

/mob/living/basic/bot/mulebot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN && !HAS_AI_ACCESS(user))
		wires.interact(user)
		return
	if(wires.is_cut(WIRE_RX) && HAS_AI_ACCESS(user))
		return

	return ..()

/mob/living/basic/bot/mulebot/bullet_act(obj/projectile/proj)
	. = ..()
	if(. && !QDELETED(src)) //Got hit and not blown up yet.
		if(prob(50) && !isnull(load))
			unload()
		if(prob(25))
			visible_message(span_danger("Something shorts out inside [src]!"))
			wires.cut_random(source = proj.firer)

/mob/living/basic/bot/mulebot/crowbar_act(mob/living/user, obj/item/tool)
	if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN) || user.combat_mode)
		return
	if(!cell)
		to_chat(user, span_warning("[src] doesn't have a power cell!"))
		return ITEM_INTERACT_SUCCESS
	cell.add_fingerprint(user)
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(cell)
	else
		cell.forceMove(drop_location())
	user.visible_message(
		span_notice("[user] crowbars [cell] out from [src]."),
		span_notice("You pry [cell] out of [src]."),
	)
	cell = null
	diag_hud_set_mulebotcell()
	return ITEM_INTERACT_SUCCESS

/mob/living/basic/bot/mulebot/emag_effects(mob/user)
	flick("[base_icon_state]-emagged", src)
	playsound(src, SFX_SPARKS, 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/mob/living/basic/bot/mulebot/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)

/mob/living/basic/bot/mulebot/ex_act(severity)
	unload()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			wires.cut_random()
			wires.cut_random()
		if(EXPLODE_LIGHT)
			wires.cut_random()

	return TRUE

/mob/living/basic/bot/mulebot/explode()
	var/atom/drop_turf = drop_location()

	new /obj/item/assembly/prox_sensor(drop_turf)
	new /obj/item/stack/rods(drop_turf)
	new /obj/item/stack/rods(drop_turf)
	new /obj/item/stack/cable_coil/cut(drop_turf)
	if(cell)
		cell.forceMove(drop_turf)
		cell = null

	new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/mob/living/basic/bot/mulebot/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	update_appearance()
