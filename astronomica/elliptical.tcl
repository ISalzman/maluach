
namespace eval ::astronomica::elliptical {
    namespace path [namespace parent]

    #################
    # Chapter 33
    # Elliptic Motion
    #################

    proc details {jd object} {
	variable [namespace parent]::astro

	set lp 0
	set bp 0
	set rp 0
	set l0 0
	set b0 0
	set r0 0
	set jd0 $jd

	if {$object ne "SUN"} {
	    set l0 [math::toRadians [earth::eclipticLongitude $jd0]]
	    set b0 [math::toRadians [earth::eclipticLatitude $jd0]]
	    set r0 [earth::radiusVector $jd0]
	}

	# Adjust jd for the effect of light-time
	while {1} {
	    switch -exact -- $object {
		SUN {
		    set l [math::toRadians [sun::geometricLongitude $jd0]]
		    set b [math::toRadians [sun::geometricLatitude $jd0]]
		    set r [earth::radiusVector $jd0]
		}

		default {
		    # :TODO: Return appropriate error
		}
	    }

	    set x [expr {$r*cos($b)*cos($l) - $r0*cos($b0)*cos($l0)}]
	    set y [expr {$r*cos($b)*sin($l) - $r0*cos($b0)*sin($l0)}]
	    set z [expr {$r*sin($b) - $r0*sin($b0)}]
	    set distance [expr {sqrt($x**2 + $y**2 + $z**2)}]

	    if {$object eq "SUN"} {
		# Distance to the sun from earth
		# is in fact the radius vector
		#set distance $r
	    }

	    set lighttime [expr {$distance * $astro(lighttime)}]
	    set jd0 [expr {$jd - $lighttime}]

	    if {(abs($l - $lp) < 0.00001)
		    && (abs($b - $bp) < 0.00001)
		    && (abs($r - $rp) < 0.000001)} {
		break
	    }

	    set lp $l
	    set bp $b
	    set rp $r
	}

	set longitude [math::normalize360 [math::toDegrees [expr {atan2($y,$x)}]]]
	set latitude [math::toDegrees [expr {atan2($z,sqrt($x**2 + $y**2))}]]

	# Adjust for Aberration
	set aberrationX [aberration::aberrationInLongitude $jd $longitude $latitude]
	set aberrationY [aberration::aberrationInLatitude $jd $longitude $latitude]
	set longitude [expr {$longitude + $aberrationX / 3600.0}]
	set latitude [expr {$latitude + $aberrationY / 3600.0}]

	# Convert to the FK5 system
	set correctionX [fk5::longitudeCorrection $jd $longitude $latitude]
	set correctionY [fk5::latitudeCorrection $jd $longitude]
	set longitude [expr {$longitude + $correctionX / 3600.0}]
	set latitude [expr {$latitude + $correctionY / 3600.0}]

	# Correct for nutation
	set nutation [nutation::nutationInLongitude $jd]
	set longitude [expr {$longitude + $nutation / 3600.0}]

	# Convert to RA and Dec
	set obliquity [nutation::trueObliquityOfEcliptic $jd]
	set ra [transform::ecliptical2rightAscension $longitude $latitude $obliquity]
	set dec [transform::ecliptical2declination $longitude $latitude $obliquity]

	set details [dict create]
	dict set details apparentDistance $distance
	dict set details apparentLightTime $lighttime
	dict set details apparentLongitude $longitude
	dict set details apparentLatitude $latitude
	dict set details apparentRightAscension $ra
	dict set details apparentDeclination $dec

	return $details
    }
}
