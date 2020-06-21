// maps: COG2 causes nornwalls, DESTINY causes gannetwalls, anything else doesn't get saved
//GOONSTATION CODE IN SEPERATE FOLDER FOR LICENSE AGREEMENT//
//Thanks NSV for the code that I ~~stole~~ ported from ye

/* =================================================== */
/* -------------------- SIMULATED -------------------- */
/* =================================================== */

/atom
	var/smoothing_d_state = 0 //Smoothing stuff

/turf/closed/wall/Initialize()
	. = ..()
	if(connect_universally)
		canSmoothWith += typecacheof(/turf/closed/wall)
		canSmoothWith += typecacheof(/obj/structure/window)
		canSmoothWith += typecacheof(/obj/machinery/door) //tg smoothing is finnicky

	// ty to somepotato for assistance with making this proc actually work right :I

/atom/proc/legacy_smooth() //overwrite the smoothing to use icon smooth SS
	cut_overlays()
	var/builtdir = 0
	var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, plane = FLOOR_PLANE)
	for (var/dir in GLOB.cardinals)
		var/turf/T = get_step(src, dir)
		if (T.type == src.type || (T.type in canSmoothWith))
			builtdir |= dir
			var/turned_dir = turn(dir, 180)
			var/turf/G = get_step(src, turned_dir)
			if(!G.get_smooth_underlay_icon(underlay_appearance, src, turned_dir) && !T.get_smooth_underlay_icon(underlay_appearance, src, turned_dir))
				underlay_appearance.icon = DEFAULT_UNDERLAY_ICON
				underlay_appearance.icon_state = DEFAULT_UNDERLAY_ICON_STATE
		else if (canSmoothWith)
			for (var/i=1, i <= canSmoothWith.len, i++)
				var/atom/A = locate(canSmoothWith[i]) in T
				if (!isnull(A))
					if (istype(A, /atom/movable))
						var/atom/movable/M = A
						if (!M.anchored)
							continue
					builtdir |= dir
					break
	add_overlay(underlay_appearance)

	src.icon_state = "[builtdir][src.smoothing_d_state ? "C" : null]"

	if(src.icon_state == "2" || src.icon_state == "0") //3/4ths perspective wall caps
		var/mutable_appearance/smooth_top_overlay = mutable_appearance(src.icon, "16[src.smoothing_d_state ? "C" : null]", ABOVE_ALL_MOB_LAYER)
		if(smooth_top_overlay)
			src.icon_state = "[builtdir + 1][src.smoothing_d_state ? "C" : null]" //If 2 then 3, if 0 then 1
			smooth_top_overlay.pixel_y = 32
			add_overlay(smooth_top_overlay)
