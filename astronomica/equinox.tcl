
namespace eval ::astronomica::equinox {
    namespace path [namespace parent]

    #########################
    # Chapter 27
    # Equinoxes and Solstices
    #########################

    proc march {y} {
	variable [namespace parent]::astro

	set y [expr {int($y)}]

	if {$y < 1000} {
	    set y [expr {$y / 1000.0}]
	    set jde [expr {1721139.29189 + 365242.13740*$y + 0.06134*$y**2 + 0.00111*$y**3 - 0.00071*$y**4}]
	} else {
	    set y [expr {($y - 2000) / 1000.0}]
	    set jde [expr {2451623.80984 + 365242.37404*$y + 0.05169*$y**2 - 0.00411*$y**3 - 0.00057*$y**4}]
	}

	while {1} {
	    set lon [sun::apparentLongitude $jde]
	    set rad [math::toRadians [expr {0 - $lon}]]
	    set corr [expr {58 * sin($rad)}]
	    set jde [expr {$jde + $corr}]

	    if {abs($corr) < $astro(tolerance)} {
		break
	    }
	}

	return $jde ;# in Dynamical Time
    }

    proc september {y} {
	variable [namespace parent]::astro

	set y [expr {int($y)}]

	if {$y < 1000} {
	    set y [expr {$y / 1000.0}]
	    set jde [expr {1721325.70455 + 365242.49558*$y - 0.11677*$y**2 - 0.00297*$y**3 + 0.00074*$y**4}]
	} else {
	    set y [expr {($y - 2000) / 1000.0}]
	    set jde [expr {2451810.21715 + 365242.01767*$y - 0.11575*$y**2 + 0.00337*$y**3 + 0.00078*$y**4}]
	}

	while {1} {
	    set lon [sun::apparentLongitude $jde]
	    set rad [math::toRadians [expr {180 - $lon}]]
	    set corr [expr {58 * sin($rad)}]
	    set jde [expr {$jde + $corr}]

	    if {abs($corr) < $astro(tolerance)} {
		break
	    }
	}

	return $jde ;# in Dynamical Time
    }
}
