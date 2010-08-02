
snit::type Date {
    option -year -configuremethod SetOption
    option -month -configuremethod SetOption
    option -day -configuremethod SetOption

    constructor {args} {
	foreach {year month day} [split [clock format [clock seconds] -format "%Y/%m/%d"] /] {break;}
	foreach opt {year month day} {
	    set options(-$opt) [scan [set $opt] "%d"]
	}

	$self configurelist $args
	return
    }

    method SetOption {option value} {
	scan $value "%d" value

	switch -exact -- $option {
	    -year {
		if {[catch {clock scan "$value/$options(-month)/$options(-day)" -format "%Y/%m/%d/"} date]} {
		    return -code error "Invalid year \"$value\"."
		}
		set value [scan [clock format $date -format "%Y"] "%d"]
	    }

	    -month {
		if {[catch {clock scan "$options(-year)/$value/$options(-day)" -format "%Y/%m/%d"} date]} {
		    return -code error "Invalid month \"$value\"."
		}
		set value [scan [clock format $date -format "%m"] "%d"]
	    }

	    -day {
		if {[catch {clock scan "$options(-year)/$options(-month)/$value" -format "%Y/%m/%d"} date]} {
		    return -code error "Invalid day \"$value\"."
		}
		set value [scan [clock format $date -format "%d"] "%d"]
	    }
	}

	set options($option) $value
	return
    }

    method add {amount unit} {
	set date [clock scan "$options(-year)/$options(-month)/$options(-day)" -format "%Y/%m/%d"]
	set newdate [clock add $date $amount $unit]

	foreach {year month day} [split [clock format $newdate -format "%Y/%m/%d"] /] {break;}
	foreach opt {year month day} {
	    set options(-$opt) [scan [set $opt] "%d"]
	}

	return
    }

    method format {{fmt ""}} {
	if {$fmt eq ""} {
	    #set fmt "%m/%d/%Y"
	    set fmt "%D"
	}

	set date [clock scan "$options(-year)/$options(-month)/$options(-day)" -format "%Y/%m/%d"]
	return [clock format $date -format $fmt]
    }

    method timeval {args} {
	return [clock scan "$options(-year)/$options(-month)/$options(-day)" -format "%Y/%m/%d"]
    }
}

