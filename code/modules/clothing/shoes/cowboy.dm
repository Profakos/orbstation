/obj/item/clothing/shoes/cowboy
	name = "cowboy boots"
	desc = "A small sticker lets you know they've been inspected for snakes, It is unclear how long ago the inspection took place..."
	icon_state = "cowboy_brown"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 90, FIRE = 0, ACID = 0) //these are quite tall
	custom_price = PAYCHECK_CREW
	var/max_occupants = 4
	can_be_tied = FALSE

/obj/item/clothing/shoes/cowboy/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

	if(prob(2))
		//There's a snake in my boot
		new /mob/living/simple_animal/hostile/retaliate/snake(src)


/obj/item/clothing/shoes/cowboy/equipped(mob/living/carbon/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_SLAM_TABLE, .proc/table_slam, override = TRUE)
	if(slot & ITEM_SLOT_FEET)
		for(var/mob/living/occupant in contents)
			var/target_zone = user.get_random_valid_zone(blacklisted_parts = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), even_weights = TRUE, bypass_warning = TRUE)
			if(!target_zone) //we broke their legs right on off!
				break
			occupant.forceMove(user.drop_location())
			user.visible_message(span_warning("[user] recoils as something slithers out of [src]."), span_userdanger("You feel a sudden stabbing pain in your [pick("foot", "toe", "ankle")]!"))
			user.Knockdown(20) //Is one second paralyze better here? I feel you would fall on your ass in some fashion.
			user.apply_damage(5, BRUTE, target_zone)
			if(istype(occupant, /mob/living/simple_animal/hostile/retaliate))
				user.reagents.add_reagent(/datum/reagent/toxin, 7)



/obj/item/clothing/shoes/cowboy/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_SLAM_TABLE)

/obj/item/clothing/shoes/cowboy/proc/table_slam(mob/living/source, obj/structure/table/the_table)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/handle_table_slam, source)

/obj/item/clothing/shoes/cowboy/proc/handle_table_slam(mob/living/user)
	user.say(pick("Hot damn!", "Hoo-wee!", "Got-dang!"), spans = list(SPAN_YELL), forced=TRUE)
	user.client?.give_award(/datum/award/achievement/misc/hot_damn, user)

/obj/item/clothing/shoes/cowboy/MouseDrop_T(mob/living/target, mob/living/user)
	. = ..()
	if(!(user.mobility_flags & MOBILITY_USE) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !isliving(target) || !user.Adjacent(target) || target.stat == DEAD)
		return
	if(contents.len >= max_occupants)
		to_chat(user, span_warning("[src] are full!"))
		return
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/snake) || istype(target, /mob/living/simple_animal/hostile/headcrab) || islarva(target))
		target.forceMove(src)
		to_chat(user, span_notice("[target] slithers into [src]."))

/obj/item/clothing/shoes/cowboy/container_resist_act(mob/living/user)
	if(!do_after(user, 10, target = user))
		return
	user.forceMove(drop_location())

/obj/item/clothing/shoes/cowboy/white
	name = "white cowboy boots"
	icon_state = "cowboy_white"

/obj/item/clothing/shoes/cowboy/black
	name = "black cowboy boots"
	desc = "You get the feeling someone might have been hanged in these boots."
	icon_state = "cowboy_black"

/obj/item/clothing/shoes/cowboy/fancy
	name = "bilton wrangler boots"
	desc = "A pair of authentic haute couture boots from Japanifornia. You doubt they have ever been close to cattle."
	icon_state = "cowboy_fancy"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 95, FIRE = 0, ACID = 0)
