
snit::type Location {
    option -name
    option -latitude -configuremethod SetLatitude
    option -longitude -configuremethod SetLongitude
    option -timezone -configuremethod SetTimezone
    option -elevation -configuremethod SetElevation -default 0.0

    constructor {args} {
	if {! [llength $args]} {
	    # Set to Royal Observatory, Greenwich 51d28'38"N 0d00'00"W
	    $self configure -name "Royal Observatory, Greenwich"
	    $self configure -longitude "0 0 0 W"
	    $self configure -latitude "51 28 38 N"
	    $self configure -timezone ":GMT"
	} else {
	    $self configurelist $args
	}

	foreach opt [array names options] {
	    if {$options($opt) eq ""} {
		return -code error "Missing value for \"$opt\"."
	    }
	}

	return
    }

    typemethod dms2deg {deg min sec} {
	return [expr {$deg + (($min + ($sec / 60.0)) / 60.0)}]
    }

    typemethod deg2dms {deg} {
	set d [expr {int($deg)}]

	set min [expr {($deg - $d) * 60.0}]
	set m [expr {int($min)}]

	set sec [expr {($min - $m) * 60.0}]
	set s [expr {int(round($sec))}]

	# Cute trick found on Tcl Wiki that uses clock magic
	#return [concat [expr {int($deg)}]\u00B0 [clock format [expr {round($deg*3600)}] -format "%M' %S\"" -timezone :UTC]]

	return [list $d $m $s]
    }

    method getLongitudeDMS {} {
	foreach {d m s} [$type deg2dms $options(-longitude)] {break;}

	if {$options(-longitude) < 0} {
	    set dir E
	} else {
	    set dir W
	}

	return [format "%d\u00B0%d'%d\"%s" $d $m $s $dir]
    }

    method getLatitudeDMS {} {
	foreach {d m s} [$type deg2dms $options(-latitude)] {break;}

	if {$options(-latitude) < 0} {
	    set dir S
	} else {
	    set dir N
	}

	return [format "%d\u00B0%d'%d\"%s" $d $m $s $dir]
    }

    method SetLatitude {option value} {
	if {[llength $value] > 1} {
	    foreach {deg min sec dir} $value {break;}
	    set value [$type dms2deg {*}[scan "$deg $min $sec" "%d %d %d"]]

	    if {$value > 90 || $value < 0} {
		return -code error "Latitude must be between 0 and 90 degrees. Use S direction to indicate negative."
	    }

	    if {$dir eq "S"} {
		set value [expr {$value * -1}]
	    } elseif {$dir ne "N"} {
		return -code error "Latitude direction must be N or S."
	    }
	} else {
	    if {$value > 90 || $value < -90} {
		return -code error "Latitude must be between -90 and 90 degrees."
	    }
	}

	set options($option) $value
	return
    }

    method SetLongitude {option value} {
	if {[llength $value] > 1} {
	    foreach {deg min sec dir} $value {break;}
	    set value [$type dms2deg {*}[scan "$deg $min $sec" "%d %d %d"]]

	    if {$value > 180 || $value < 0} {
		return -code error "Longitude must be between 0 and 180 degrees. Use E direction to indicate negative."
	    }

	    if {$dir eq "E"} {
		set value [expr {$value * -1}]
	    } elseif {$dir ne "W"} {
		return -code error "Longitude direction must be E or W."
	    }
	} else {
	    if {$value > 90 || $value < -90} {
		return -code error "Longitude must be between -180 and 180 degrees."
	    }
	}

	set options($option) $value
	return
    }

    method SetTimezone {option value} {
	if {[catch {clock format [clock seconds] -format "%Z %z" -timezone $value} err]} {
	    return -code error "Invalid timezone \"$value\"."
	}

	set options($option) $value
	return
    }

    method SetElevation {option value} {
	if {$value < 0} {
	    return -code error "Elevation must be a positive value."
	}

	set options($option) $value
	return
    }
}
