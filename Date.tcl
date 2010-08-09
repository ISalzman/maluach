
snit::type Date {
    option -month -readonly 1
    option -day -readonly 1
    option -year -readonly 1

    variable timeval

    constructor {args} {
	if {! [llength $args]} {
	    set tval [clock seconds]
	} else {
	    set tval [lindex $args 0]
	}

	$self timeval $tval
	return
    }

    method timeval {args} {
	if {[llength $args]} {
	    set tval [lindex $args 0]

	    if {! [string is integer -strict $tval]} {
		return -code "Invalid timeval \"$tval\"."
	    }

	    set timeval $tval
	    $self SetOptions
	}

	return $timeval
    }

    method incr {amount unit} {
	set timeval [clock add $timeval $amount $unit]
	$self SetOptions

	return
    }

    method add {amount unit} {
	return [clock add $timeval $amount $unit]
    }

    method format {{fmt "%D"}} {
	return [clock format $timeval -format $fmt]
    }

    method SetOptions {} {
	foreach {year month day} [split [clock format $timeval -format "%Y/%m/%d"] /] {break;}
	foreach opt {year month day} {
	    set options(-$opt) [scan [set $opt] "%d"]
	}

	return
    }
}

