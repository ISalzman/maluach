
namespace eval ::astronomica::sun {
    namespace path [namespace parent]

    ###################
    # Chapter 25
    # Solar Coordinates
    ###################

    proc geometricLongitude {jd} {
	set longitude [expr {[earth::eclipticLongitude $jd] + 180}]
	return [math::normalize360 $longitude] ;# in degrees
    }

    proc geometricLatitude {jd} {
	set latitude [expr {- [earth::eclipticLatitude $jd]}]
	return $latitude ;# in degrees
    }

    proc apparentLongitude {jd} {
	set longitude [geometricLongitude $jd]
	set latitude [geometricLatitude $jd]
	set radius [earth::radiusVector $jd]
	set fk5correction [fk5::longitudeCorrection $jd $longitude $latitude]
	set nutation [nutation::nutationInLongitude $jd]
	set aberration [expr {-20.4898 / $radius}]

	set longitude [expr {$longitude + ($fk5correction + $nutation + $aberration) / 3600.0}]
	return $longitude ;# in degrees
    }

    proc apparentLatitude {jd} {
	set longitude [geometricLongitude $jd]
	set latitude [geometricLatitude $jd]
	set fk5correction [fk5::latitudeCorrection $jd $longitude]

	set latitude [expr {$latitude + $fk5correction / 3600.0}]
	return $latitude ;# in degrees
    }

    proc apparentRightAscension {jd} {
	set longitude [apparentLongitude $jd]
	set latitude [apparentLatitude $jd]
	set obliquity [nutation::trueObliquityOfEcliptic $jd]

	set ra [transform::ecliptical2rightAscension $longitude $latitude $obliquity]
	return $ra ;# in degrees
    }

    proc apparentDeclination {jd} {
	set longitude [apparentLongitude $jd]
	set latitude [apparentLatitude $jd]
	set obliquity [nutation::trueObliquityOfEcliptic $jd]

	set dec [transform::ecliptical2declination $longitude $latitude $obliquity]
	return $dec ;# in degrees
    }
}
