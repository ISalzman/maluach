
snit::type Calendar {
    option -date -configuremethod SetOption
    option -location -configuremethod SetOption

    variable internalDate 0
    variable internalLocation 0

    constructor {args} {
	$self configurelist $args

	if {$options(-date) eq ""} {
	    $self configure -date [Date create %AUTO%]
	    set internalDate 1
	}
	if {$options(-location) eq ""} {
	    $self configure -location [Location create %AUTO%]
	    set internalLocation 1
	}

	return
    }

    destructor {
	if {$internalDate} {
	    catch {$options(-date) destroy}
	}
	if {$internalLocation} {
	    catch {$options(-location) destroy}
	}
    }

    method SetOption {option value} {
	if {[catch {$value info type} err]} {
	    return -code error "$option must be a valid snit object."
	}

	set options($option) $value
	return
    }

    method zman {zmanName args} {
	if {[info proc ::Zmanim::$zmanName] eq ""} {
	    return -code error "Invalid zman \"$zmanName\"."
	}

	set year [$options(-date) cget -year]
	set month [$options(-date) cget -month]
	set day [$options(-date) cget -day]
	set longitude [$options(-location) cget -longitude]
	set latitude [$options(-location) cget -latitude]
	set timezone [$options(-location) cget -timezone]

	set arglist [list $year $month $day $longitude $latitude $timezone]
	if {$zmanName eq "MinchahGedolahGRA" && [lindex $args 0] eq "strict"} {
	    lappend arglist 1
	}

	set zmanhr [::Zmanim::$zmanName {*}$arglist]
	return [::Zmanim::Format $zmanhr $zmanName $year $month $day $timezone]
    }

    method dafyomi {args} {
	set year [$options(-date) cget -year]
	set month [$options(-date) cget -month]
	set day [$options(-date) cget -day]

	return [::DafYomi::Daf $year $month $day]
    }
}
