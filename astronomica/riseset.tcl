
namespace eval ::astronomica::riseTransitSet {
    namespace path [namespace parent]

    ####################
    # Chapter 15
    # Rise, Transit, Set
    ####################

    # Formula 15.1
    proc hourAngle {latitude altitude declination} {
	set latRad [math::toRadians $latitude]
	set altRad [math::toRadians $altitude]
	set decRad [math::toRadians $declination]

	set cosH [expr {(sin($altRad) - sin($latRad) * sin($decRad))
			/ (cos($latRad) * cos($decRad))}]

	if {($cosH < -1) || ($cosH > 1)} {
	    # Circumpolar - never rises or sets
	    # :TODO: Return appropriate error
	}

	return [math::toDegrees [expr {acos($cosH)}]] ;# in degrees
    }

    proc Transit0 {jd longitude ra} {
	namespace upvar [namespace parent] astro astro

	set theta0 [sidereal::apparentGreenwichSiderealTime $jd]
	set m0 [expr {($ra + $longitude - $theta0 * $astro(degPerHour)) / 360.0}]

	while {$m0 < 0 || $m0 > 1} {
	    set fix [expr {$m0 < 0 ? 1 : -1}]
	    set m0 [expr {$m0 + $fix}]
	}

	return $m0
    }

    proc transitUT {jd longitude ra1 ra2 ra3} {
	namespace upvar [namespace parent] astro astro

	set dt [deltaT::deltaT $jd]
	set m [Transit0 $jd $longitude $ra2]
	set theta0 [sidereal::apparentGreenwichSiderealTime $jd]

	# Correct right ascension values for interpolation
	# See Important Remark 2 in Chapter 13 (p. 30)
	if {($ra2 - $ra1) > 180} {
	    set ra1 [expr {$ra1 + 360}]
	} elseif {($ra2 - $ra1) < -180} {
	    set ra2 [expr {$ra2 + 360}]
	}
	if {($ra3 - $ra2) > 180} {
	    set ra2 [expr {$ra2 + 360}]
	} elseif {($ra3 - $ra2) < -180} {
	    set ra3 [expr {$ra3 + 360}]
	}

	while {1} {
	    set n [expr {$m + $dt / 86400.0}]
	    set ra [interpolate::interpolate3 $ra1 $ra2 $ra3 $n]
	    set th [expr {$theta0 * $astro(degPerHour) + 360.985647 * $m}]
	    set H [expr {$th - $longitude - $ra}]
	    set dm [expr {[math::normalize180 $H] / -360.0}]

	    if {abs($dm) < $astro(tolerance)} {
		break
	    }

	    set m [expr {$m + $dm}]
	}

	return [expr {$m * 24}]
    }

    proc RiseSet0 {type jd longitude latitude altitude ra decl} {
	namespace upvar [namespace parent] astro astro

	if {$type == $astro(typeRise)} {
	    set sign -1
	} elseif {$type == $astro(typeSet)} {
	    set sign 1
	}

	set m0 [Transit0 $jd $longitude $ra]
	set H0 [hourAngle $latitude $altitude $decl]
	set m1 [expr {$m0 + $H0 / 360.0 * $sign}]

	while {$m1 < 0 || $m1 > 1} {
	    set fix [expr {$m1 < 0 ? 1 : -1}]
	    set m1 [expr {$m1 + $fix}]
	}

	return $m1
    }

    proc riseSetUT {type jd longitude latitude altitude ra1 ra2 ra3 d1 d2 d3} {
	namespace upvar [namespace parent] astro astro

	set dt [deltaT::deltaT $jd]
	set m [RiseSet0 $type $jd $longitude $latitude $altitude $ra2 $d2]
	set theta0 [sidereal::apparentGreenwichSiderealTime $jd]

	# Correct right ascension values for interpolation
	# See Important Remark 2 in Chapter 13 (p. 30)
	if {($ra2 - $ra1) > 180} {
	    set ra1 [expr {$ra1 + 360}]
	} elseif {($ra2 - $ra1) < -180} {
	    set ra2 [expr {$ra2 + 360}]
	}
	if {($ra3 - $ra2) > 180} {
	    set ra2 [expr {$ra2 + 360}]
	} elseif {($ra3 - $ra2) < -180} {
	    set ra3 [expr {$ra3 + 360}]
	}

	while {1} {
	    set n [expr {$m + $dt / 86400.0}]
	    set d [interpolate::interpolate3 $d1 $d2 $d3 $n]
	    set ra [interpolate::interpolate3 $ra1 $ra2 $ra3 $n]
	    set th [expr {$theta0 * $astro(degPerHour) + 360.985647 * $m}]
	    set H [expr {$th - $longitude - $ra}]
	    set h [transform::equitorial2altitude $H $d $latitude]
	    set dm [expr {($h - $altitude) / 360 * cos([math::toRadians $d])
			* cos([math::toRadians $latitude]) * sin([math::toRadians $H])}]

	    if {abs($dm) < $astro(tolerance)} {
		break
	    }

	    set m [expr {$m + $dm}]
	}

	return [expr {$m * 24.0}]
    }
}
