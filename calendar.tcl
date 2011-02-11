
snit::type Calendar {
    option -date -configuremethod SetOption
    option -location -configuremethod SetOption

    variable internal -array {-date 0 -location 0}

    constructor {args} {
	$self configurelist $args

	if {$options(-date) eq ""} {
	    $self configure -date [Date create %AUTO%]
	    set internal(-date) 1
	}
	if {$options(-location) eq ""} {
	    $self configure -location [Location create %AUTO%]
	    set internal(-location) 1
	}

	return
    }

    destructor {
	if {$internal(-date)} {
	    catch {$options(-date) destroy}
	}
	if {$internal(-location)} {
	    catch {$options(-location) destroy}
	}

	return
    }

    method zman {zmanName args} {
	if {[info proc ::zmanim::$zmanName] eq ""} {
	    return -code error "Invalid zman \"$zmanName\"."
	}

	set year [$options(-date) cget -year]
	set month [$options(-date) cget -month]
	set day [$options(-date) cget -day]
	set longitude [$options(-location) cget -longitude]
	set latitude [$options(-location) cget -latitude]
	set timezone [$options(-location) cget -timezone]

	set arglist [list $year $month $day $longitude $latitude $timezone]
	if {$zmanName eq "minchahGedolahGRA" && [lindex $args 0] eq "strict"} {
	    lappend arglist 1
	}

	set zmanhr [::zmanim::$zmanName {*}$arglist]
	return [::zmanim::format $zmanhr $zmanName $year $month $day $timezone]
    }

    method dafyomi {args} {
	set year [$options(-date) cget -year]
	set month [$options(-date) cget -month]
	set day [$options(-date) cget -day]

	return [::dafyomi::daf $year $month $day]
    }

    method SetOption {option value} {
	if {[catch {$value info type} err]} {
	    return -code error "$option must be a valid snit object."
	}

	if {$internal($option)} {
	    catch {$options($option) destroy}
	    set interal($options) 0
	}

	set options($option) $value
	return
    }
}
