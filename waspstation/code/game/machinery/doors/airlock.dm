/obj/machinery/door/airlock/Initialize()
	. = ..()
	set_smooth_dir()

/obj/machinery/door/airlock/proc/set_smooth_dir() //I fucking hate this code and so should you :) thank you I hate it :)
//	for(var/atom/obstacle in view(1, src)) //Ghetto ass icon smooth
	var/odir = 0
	var/atom/found = null
	var/turf/north = get_turf(get_step(src,NORTH))
	if(north.density)
		found = north
		odir = NORTH
	var/turf/south = get_turf(get_step(src,SOUTH))
	if(south.density)
		found = south
		odir = SOUTH
	var/turf/east = get_turf(get_step(src,EAST))
	if(east.density)
		found = east
		odir = EAST
	var/turf/west = get_turf(get_step(src,WEST))
	if(west.density)
		found = west
		odir = WEST
	wall_border = found ? null : found.name
	if(!found) //AAAAAAAAAAAAAAA WHY GOD WHY
		for(var/atom/foo in get_step(src,NORTH))
			if(foo?.density)
				found = foo
				odir = NORTH
				break
		for(var/atom/foo in get_step(src,SOUTH))
			if(foo?.density)
				found = foo
				odir = SOUTH
				break
		for(var/atom/foo in get_step(src,EAST))
			if(foo?.density)
				found = foo
				odir = EAST
				break
		for(var/atom/foo in get_step(src,WEST))
			if(foo?.density)
				found = foo
				odir = WEST
				break
	if(odir == NORTH || odir == SOUTH)
		dir = EAST
	else
		dir = SOUTH
	return odir
