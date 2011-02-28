
namespace eval ::astronomica::solstice {
    namespace path [namespace parent]

    #########################
    # Chapter 27
    # Equinoxes and Solstices
    #########################

    proc summer {y} {
	variable [namespace parent]::astro

	set y [expr {int($y)}]

	if {$y < 1000} {
	    set y [expr {$y / 1000.0}]
	    set jde [expr {1721233.25401 + 365241.72562*$y - 0.05323*$y**2 + 0.00907*$y**3 + 0.00025*$y**4}]
	} else {
	    set y [expr {($y - 2000) / 1000.0}]
	    set jde [expr {2451716.56767 + 365241.62603*$y + 0.00325*$y**2 + 0.00888*$y**3 - 0.00030*$y**4}]
	}

	while {1} {
	    set lon [sun::apparentLongitude $jde]
	    set rad [math::toRadians [expr {90 - $lon}]]
	    set corr [expr {58 * sin($rad)}]
	    set jde [expr {$jde + $corr}]

	    if {abs($corr) < $astro(tolerance)} {
		break
	    }
	}

	return $jde ;# in Dynamical Time
    }

    proc winter {y} {
	variable [namespace parent]::astro

	set y [expr {int($y)}]

	if {$y < 1000} {
	    set y [expr {$y / 1000.0}]
	    set jde [expr {1721414.39987 + 365242.88257*$y - 0.00769*$y**2 - 0.00933*$y**3 - 0.00006*$y**4}]
	} else {
	    set y [expr {($y - 2000) / 1000.0}]
	    set jde [expr {2451900.05952 + 365242.74049*$y - 0.06223*$y**2 - 0.00823*$y**3 + 0.00032*$y**4}]
	}

	while {1} {
	    set lon [sun::apparentLongitude $jde]
	    set rad [math::toRadians [expr {270 - $lon}]]
	    set corr [expr {58 * sin($rad)}]
	    set jde [expr {$jde + $corr}]

	    if {abs($corr) < $astro(tolerance)} {
		break
	    }
	}

	return $jde ;# in Dynamical Time
    }
}
