
/*
BASIC BROAD PART PARADIGMS:
" gun " : the reciever - determines whether it's single or double action, basic capacity (bolt or revolver), and DRM types
Barrels : largely handle how a shot behaves after leaving your gun. Spread, muzzle flash, silencing, damage modifiers.
Stocks  : everything to do with holding and interfacing the gun. Crankhandles, extra capacity, 2-handedness, and (on rare occasions) power cells go here
Mags    : entirely optional component that adds ammo capacity, but also increases jamming frequency. May affect action type by autoloading?
accssry : mall ninja bullshit. optics. gadgets. flashlights. horns. sexy nude men figurines. your pick.
*/





ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	icon = 'icons/obj/items/cet_guns/accessory.dmi'
	var/name_addition = ""
	var/part_type = null
	var/overlay_x = 0
	var/overlay_y = 0
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null
	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		var/image/I = image(icon, icon_state)
		I.pixel_x = overlay_x
		I.pixel_y = overlay_y
		my_gun.UpdateOverlays(I, part_type)
		return 1

	proc/remove_part_from_gun() // should safely un-do all of add_part_to_gun()
		RETURN_TYPE(/obj/item/gun_parts/)
		my_gun.name = my_gun.real_name
		my_gun = null
		return src

	//barrel vars
	var/spread_angle = 0 // modifier, added to stock
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"
	var/lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	var/jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	var/scatter = 0
	var/length = 0 // centimetres

	//stock vars
	var/can_dual_wield = 1
	//var/spread_angle = 0 // modifier, added to stock // repeat of barrel
	var/max_ammo_capacity = 0 //modifier
	var/flashbulb_only = 0 // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	var/stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	var/jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.

	// mag vars
	// max_ammo_capacity = 0 //modifier
	// jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.

	buildTooltipContent()
		. = ..()
		if(part_DRM)
			. += "<div><span>DRM REQUIREMENTS: </span>"
			if(part_DRM & GUN_NANO)
				. += "<img src='[resource("images/tooltips/temp_nano.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_FOSS)
				. += "<img src='[resource("images/tooltips/temp_foss.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_JUICE)
				. += "<img src='[resource("images/tooltips/temp_juice.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_SOVIET)
				. += "<img src='[resource("images/tooltips/temp_soviet.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_ITALIAN)
				. += "<img src='[resource("images/tooltips/temp_italian.png")]' alt='' class='icon' />"
			. += "</div>"
		if(scatter)
			. += "<div><img src='[resource("images/tooltips/temp_scatter.png")]' alt='' class='icon' /></div>"
		if(spread_angle)
			. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread Modifier: [src.spread_angle] </span></div>"
		if(lensing)
			. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Optical Lens: [src.lensing] </span></div>"
		if(length)
			. += "<div><span>Barrel length: [src.length] </span></div>"
		if(jam_frequency_fire || jam_frequency_reload)
			. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jam Probability: [src.jam_frequency_reload + src.jam_frequency_fire] </span></div>"
		if(max_ammo_capacity)
			. += "<div> <span>Capacity Modifier: [src.max_ammo_capacity] </span></div>"
		lastTooltipContent = .



ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
// useful vars
	part_type = "barrel"
	spread_angle = -BARREL_PENALTY // remove barrel penalty
	silenced = 0
	muzzle_flash = "muzzle_flash"
	lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	scatter = 0
	icon = 'icons/obj/items/cet_guns/barrels.dmi'
	icon_state = "it_revolver"
	length = STANDARD_BARREL_LEN
	overlay_x = 10
	overlay_y = 4

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.barrel = src
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.silenced = src.silenced
		my_gun.muzzle_flash = src.muzzle_flash
		my_gun.lensing = src.lensing
		my_gun.scatter = src.scatter
		my_gun.jam_frequency_fire += src.jam_frequency_fire
		my_gun.name = my_gun.name + " " + src.name_addition
		//Icon! :)



	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.barrel = null
		my_gun.spread_angle = initial(my_gun.spread_angle)
		my_gun.silenced = 0
		my_gun.muzzle_flash = 0
		my_gun.lensing = 0
		my_gun.scatter = 0
		my_gun.jam_frequency_fire = initial(my_gun.jam_frequency_fire)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/stock)
/obj/item/gun_parts/stock/
	//add a var for a power cell later
	part_type = "stock"
	can_dual_wield = 1
	spread_angle = -GRIP_PENALTY // modifier, added to stock
	max_ammo_capacity = 0 //modifier
	flashbulb_only = 0 // FOSS guns only
	max_crank_level = 0 // FOSS guns only
	stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the stock when removed
	icon_state = "nt_wire_alt"
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	overlay_x = -10



	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.stock = src
		my_gun.can_dual_wield = src.can_dual_wield
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.two_handed |= src.stock_two_handed // if either the stock or the gun design is 2-handed, so is the assy.
		my_gun.can_dual_wield &= src.stock_dual_wield
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.ammo_list += src.ammo_list
		my_gun.name = src.name_addition + " " + my_gun.name
		if(flashbulb_only)
			my_gun.flashbulb_only = src.flashbulb_only
			my_gun.max_crank_level = src.max_crank_level
		else
			my_gun.flashbulb_only = 0
			my_gun.max_crank_level = 0

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.stock = null
		my_gun.can_dual_wield = initial(my_gun.can_dual_wield)
		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		my_gun.max_crank_level = 0
		my_gun.spread_angle = initial(my_gun.spread_angle)
		my_gun.two_handed = initial(my_gun.two_handed)
		my_gun.can_dual_wield = initial(my_gun.can_dual_wield)
		my_gun.jam_frequency_reload = initial(my_gun.jam_frequency_reload)
		my_gun.flashbulb_only = 0
		my_gun.max_crank_level = 0
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	part_type = "magazine"
	max_ammo_capacity = 0 //modifier
	jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the mag when removed

	icon_state = "generic_magazine"
	contraband = 1

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.magazine = src
		my_gun.ammo_list += src.ammo_list
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.name = my_gun.name + " " + src.name_addition

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))

		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		my_gun.jam_frequency_reload = initial(my_gun.jam_frequency_reload)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps?
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?
	part_type = "accessory"
	icon_state = "generic_magazine"
	overlay_y = 10

	proc/alt_fire()
		return alt_fire

	proc/on_fire()
		return call_on_fire

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.accessory = src
		my_gun.accessory_alt = alt_fire
		my_gun.accessory_on_fire = call_on_fire
		my_gun.name = src.name_addition + " " + my_gun.name



	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.accessory = null
		my_gun.accessory_alt = 0
		my_gun.accessory_on_fire = 0
		. = ..()



// THIS NEXT PART MIGHT B STUPID
/*
ABSTRACT_TYPE(/obj/item/storage/gun_workbench/)
/obj/item/storage/gun_workbench/
	slots = 1
	var/part = null
	var/gun_DRM = 0
	var/partname = "nothing"
	max_wclass = 4

	barrel
		part = /obj/item/gun_parts/barrel/
		partname = "barrel"
	stock
		part = /obj/item/gun_parts/stock/
		partname = "stock"
	magazine
		part = /obj/item/gun_parts/magazine/
		partname = "magazine"
	accessory
		part = /obj/item/gun_parts/accessory/
		partname = "doodad"

	check_can_hold(obj/item/W)
		if(!istype(W,part))
			boutput(usr, "You can only place a [src.partname] here!")
			return
		else
			var/obj/item/gun_parts/new_part = W
			if(new_part.part_DRM & gun_DRM)
				..()
			else
				boutput(usr, "That part isn't compatible with your gun!")
				return
*/
//told u
/obj/item/gun_exploder/
	name = "gunsmithing anvil"
	desc = "hit it with a gun 'till the gun falls apart lmao"
	var/obj/item/gun_parts/part = null
	anchored = 1
	density = 1
	icon = 'icons/obj/dojo.dmi'
	icon_state = "anvil"

	attackby(obj/item/W as obj, mob/user as mob, params)
		if(!istype(W,/obj/item/gun/modular/) || prob(70))
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			..()
			return
		var/obj/item/gun/modular/new_gun = W
		if(!new_gun.built)
			boutput(user, "<span class='notice'>You smash the pieces of the gun into place!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			new_gun.build_gun()
			return
		else
			boutput(user, "<span class='notice'>You smash the pieces of the gun apart!</span>")
			playsound(src.loc, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			user.u_equip(W)
			W.dropped(user)
			W.set_loc(src.loc)
			if(new_gun.barrel)
				src.part = new_gun.barrel.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.stock)
				src.part = new_gun.stock.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.magazine)
				src.part = new_gun.magazine.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.accessory)
				src.part = new_gun.accessory.remove_part_from_gun()
				src.part.set_loc(src.loc)
			src.part = null
			new_gun.buildTooltipContent()
			new_gun.built = 0
			new_gun.ClearAllOverlays(1) // clear the part overlays but keep cache? idk if thats better or worse.




/obj/table/gun_workbench/
	name = "gunsmithing workbench"
	desc = "lay down a rifle and start swappin bits"

	var/list/obj/item/gun_parts/parts = list()
	var/obj/item/gun/modular/gun = null
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/gun_DRM = 0

	New()
		..()


	attackby(obj/item/W as obj, mob/user as mob, params)
		if(gun)
			boutput(user, "<span class='notice'>There's already a gun on [src].</span>")
			return
		if(!istype(W,/obj/item/gun/modular/))
			boutput(user, "<span class='notice'>You should probably only use this for guns.</span>")
			return
		else
			boutput(user, "<span class='notice'>You secure [W] on [src].</span>")
			//ok its a modular gun!
			//open the gunsmithing menu (cross-shaped inventory thing) and let the user swap parts around in it
			// when they're done, put the parts back in the gun's slots and call gun.build_gun()
			load_gun(W)
			return

	attack_hand(mob/user)
		if(!gun)
			boutput(user, "<span class='notice'>You need to put a gun on [src] first.</span>")
			return
		else
			//open gunsmithing menu
			return

	proc/load_gun(var/obj/item/gun/modular/new_gun)
		src.gun = new_gun
		src.parts = new_gun.parts

		//update DRM for the storage slots.
		src.gun_DRM = new_gun.gun_DRM

		//place parts in the storage slots
		if(new_gun.barrel)
			src.barrel = new_gun.barrel.remove_part_from_gun()
		if(new_gun.stock)
			src.stock = new_gun.stock.remove_part_from_gun()
		if(new_gun.magazine)
			src.magazine = new_gun.magazine.remove_part_from_gun()
		if(new_gun.accessory)
			src.accessory = new_gun.accessory.remove_part_from_gun()

		//update icon
//real stupid
	proc/open_gunsmithing_menu()
		//dear smart people please do
		return

	proc/remove_gun(mob/user as mob)
		//add parts to gun // this is gonna runtime you dipshit
		gun.barrel = src.barrel
		gun.stock = src.stock
		gun.magazine = src.magazine
		gun.accessory = src.accessory

		//dispense gun
		gun.build_gun()
		user.put_in_hand_or_drop(gun)

		//clear table
		gun = null
		barrel.contents = null
		stock.contents = null
		magazine.contents = null
		accessory = null


// NOW WE HAVE THE INSTANCIBLE TYPES

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = -13 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	icon_state = "nt_blue_short"
	length = 16

/obj/item/gun_parts/barrel/NT/long
	name = "standard long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = -15
	name_addition = "longarm"
	icon_state = "nt_blue"
	length = 35

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS lensed barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = -16
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_JUICE
	name_addition = "lenser"
	icon = 'icons/obj/items/cet_guns/fossgun.dmi'
	icon_state = "barrel_short"
	contraband = 1
	length = 17
	overlay_x = 15

/obj/item/gun_parts/barrel/foss/long
	name = "\improper FOSS lensed long barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = -17
	lensing = 1
	name_addition = "focuser"
	icon_state = "barrel_long"
	length = 39

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLUNDA Barrel"
	desc = "A cheaply-built shotgun barrel. Not great."
	spread_angle = -3
	scatter = 1
	jam_frequency_fire = 5 //but very poorly built
	part_DRM = GUN_JUICE | GUN_NANO | GUN_FOSS
	name_addition = "BLUNDER"
	icon_state = "juicer_blunderbuss"
	length = 12

/obj/item/gun_parts/barrel/juicer/longer
	name = "\improper SNIPA Barrel"
	desc = "A cheaply-built extended rifled shotgun barrel. Not good."
	spread_angle = -17 // accurate??
	jam_frequency_fire = 15 //but very!!!!!!! poorly built
	name_addition = "BLITZER"
	icon_state = "juicer_long"
	length = 40

/obj/item/gun_parts/barrel/soviet
	name = "soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle = -14
	lensing = 1.2
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_ITALIAN
	name_addition = "comrade"
	icon_state = "soviet_lens"
	length = 16

/obj/item/gun_parts/barrel/soviet/long
	name = "long soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle = -14
	lensing = 1.4
	name_addition = "tovarisch"
	icon_state = "soviet_lens_long"
	length = 22

/obj/item/gun_parts/barrel/italian
	name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	spread_angle = -11 // "alta qualità"
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	name_addition = "paisan"
	icon_state = "it_revolver_short"
	length = 13

/obj/item/gun_parts/barrel/luna/zunar
	name = "Zunar mk8 barrel"
	desc = "A somewhat short barrel that has trumpet buttons on it with a 0 and 1. Some sort of lens shutter too."
	spread_angle = 5
	scatter = 2
	name_addition = "Inaba"
	icon = 'icons/obj/tselaguns/specialparts.dmi'
	lenght = 15
	icon_state = "zungunbarrel"

// BASIC STOCKS
/obj/item/gun_parts/stock/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -2 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	name_addition = "trusty"
	icon = 'icons/obj/items/cet_guns/grips.dmi'
	icon_state = "nt_blue"

/obj/item/gun_parts/stock/NT/shoulder
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -5 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 2 // a little more jammy
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	name_addition = "sturdy"
	icon_state = "nt_blue"

/obj/item/gun_parts/stock/NT/arm_brace
	name = "standard brace"
	desc = "A comfortable NT forearm brace"
	spread_angle = -7 // quite better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 3 // a little more jammy
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	name_addition = "capable"
	icon_state = "nt_wire"
	overlay_x = -15

/obj/item/gun_parts/stock/foss
	name = "\improper FOSS laser stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring."
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_JUICE
	flashbulb_only = 1
	max_crank_level = 2

	name_addition = "vicious"
	icon = 'icons/obj/items/cet_guns/fossgun.dmi'
	icon_state = "stock_single"
	overlay_x = -15

/obj/item/gun_parts/stock/foss/long
	name = "\improper FOSS laser rifle stock"
	spread_angle = -6 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_crank_level = 3 // for syndicate ops
	name_addition = "monstrous"

/obj/item/gun_parts/stock/foss/loader
	name = "\improper FOSS laser loader stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring. This one's kind of hard to hold."
	spread_angle = 1 // A POSITIVE SPREAD? O NO
	max_ammo_capacity = 2 // two more bulbs in the pocket
	jam_frequency_reload = 10
	name_addition = "reckless"
	icon_state = "stock_double"

/obj/item/gun_parts/stock/foss/longer
	name = "\improper FOSS laser punt gun stock"
	spread_angle = -1 // poor stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_crank_level = 4 // for syndicate ops
	jam_frequency_reload = 5 // a little more jammy
	name_addition = "disastrous"
	icon_state = "stock_double_alt"

/obj/item/gun_parts/stock/italian
	name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = -1
	max_ammo_capacity = 1 // to make that revolver revolve!
	jam_frequency_reload = 5 // a lot  more jammy!!
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	icon = 'icons/obj/items/cet_guns/grips.dmi'
	icon_state = "it_plain"
	name_addition = "quality"

/obj/item/gun_parts/stock/italian/bigger
	name = "impugnatura a pistola piu larga"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = -3
	max_ammo_capacity = 3 // to make that revolver revolve!
	jam_frequency_reload = 9 // a lot  more jammy!!
	icon_state = "it_fancy"
	name_addition = "jovial"

/obj/item/gun_parts/stock/luna/zunar
	name = "Zunar Mk8 grip"
	desc = "The trigger looks to be taken from a game controller"
	spread_angle = -2
	max_ammo_capacity = 5
	jam_frequency_reload = 1 //should work?
	icon = 'icons/obj/tselaguns/specialparts.dmi'
	icon_state = "zungunstock"
	name_addition = "Udon"

// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!
/obj/item/gun_parts/accessory/horn
	name = "Tactical Alerter"
	desc = "Efficiently alerts your squadron within miliseconds of target engagement, using cutting edge over-the-airwaves technology"
	call_on_fire = 1
	name_addition = "tactical"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bike_horn"

	on_fire()
		playsound(src.my_gun.loc, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)

/obj/item/gun_parts/accessory/trumpetnoiser
	name = "Front of a Trumpet"
	desc = "HEY YOU GOT A LISCENES FOR THAT????"
	call_on_fire = 1
	name_addition = "Musical"
	icon = 'icons/obj/tselaguns/specialparts.dmi'
	icon_state = "trumpet"

		on_fire()
		playsound(src.my_gun.loc, pick('sound/musical_instruments/sax_bonk1.ogg', 'sound/musical_instruments/sax_bonk2.ogg'), 50, 1, -1)

obj/item/gun_parts/accessory/zupressor
	name = "Inba Zupressor" // I am so proud of this pun
	desc = "the bullets are preparing, please wait warmly."
	call_on_fire = 1
	name_addition = "Zupressed"
	icon = 'icons/obj/tselaguns/specialparts.dmi'
	icon_state = "zungunzunpressor"

		on_fire()
		playsound(src.my_gun.loc, pick('sound/weapons/Zunpet_attack.ogg'), 50, 1, -1)

// No such thing as a basic magazine! they're all bullshit!!
/obj/item/gun_parts/magazine/juicer
	name = "HOTT SHOTTS MAG"
	desc = "Holds 3 rounds, and 30,000 followers."
	max_ammo_capacity = 3
	jam_frequency_reload = 8
	name_addition = "LARGE"
	icon_state = "juicer_drum"
	overlay_y = 10

