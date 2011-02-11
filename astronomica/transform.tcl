
namespace eval ::astronomica::transform {
    namespace path [namespace parent]

    ###############################
    # Chapter 13
    # Transformation of Coordinates
    ###############################

    # Formula 13.1
    # Equatorial coordinates to ecliptical longitude
    proc equatorial2longitude {ra dec obliquity} {
	set raRad [math::toRadians $ra]
	set decRad [math::toRadians $dec]
	set oblRad [math::toRadians $obliquity]

	set longitude [expr {atan2((sin($raRad)*cos($oblRad) + tan($decRad)*sin($oblRad)),cos($raRad))}]
	return [math::normalize360 [math::toDegrees $longitude]]
    }

    # Formula 13.2
    # Equatorial coordinates to ecliptical latitude
    proc equatorial2latitude {ra dec obliquity} {
	set raRad [math::toRadians $ra]
	set decRad [math::toRadians $dec]
	set oblRad [math::toRadians $obliquity]

	set latitude [expr {asin(sin($decRad)*cos($oblRad) - cos($decRad)*sin($oblRad)*sin($raRad))}]
	return [math::toDegrees $latitude]
    }

    # Formula 13.3
    # Ecliptical coordinates to equitorial right ascension
    proc ecliptical2rightAscension {longitude latitude obliquity} {
	set lonRad [math::toRadians $longitude]
	set latRad [math::toRadians $latitude]
	set oblRad [math::toRadians $obliquity]

	set ra [expr {atan2((sin($lonRad)*cos($oblRad) - tan($latRad)*sin($oblRad)),cos($lonRad))}]
	return [math::normalize360 [math::toDegrees $ra]]
    }

    # Formula 13.4
    # Ecliptical coordinates to equitorial declination
    proc ecliptical2declination {longitude latitude obliquity} {
	set lonRad [math::toRadians $longitude]
	set latRad [math::toRadians $latitude]
	set oblRad [math::toRadians $obliquity]

	set dec [expr {asin(sin($latRad)*cos($oblRad) + cos($latRad)*sin($oblRad)*sin($lonRad))}]
	return [math::toDegrees $dec]
    }

    # Forumula 13.5
    # Equitorial coordinates to local horizontal azimuth
    proc equitorial2azimuth {lha dec latitude} {
	set lhaRad [math::toRadians $lha]
	set decRad [math::toRadians $dec]
	set latRad [math::toRadians $latitude]

	set azimuth [expr {atan2(sin($lhaRad),(cos($lhaRad)*sin($latRad) - tan($decRad)*cos($latRad)))}]
	return [math::normalize360 [math::toDegrees $azimuth]]
    }

    # Forumula 13.6
    # Equitorial coordinates to local horizontal altitude
    proc equitorial2altitude {lha dec latitude} {
	set lhaRad [math::toRadians $lha]
	set decRad [math::toRadians $dec]
	set latRad [math::toRadians $latitude]

	set altitude [expr {asin(sin($latRad)*sin($decRad) + cos($latRad)*cos($decRad)*cos($lhaRad))}]
	return [math::toDegrees $altitude]
    }

    # Horizontal coordinates to equitorial local hour angle
    proc horizontal2localHourAngle {azimuth altitude latitude} {
	set azRad [math::toRadians $azimuth]
	set altRad [math::toRadians $altitude]
	set latRad [math::toRadians $latitude]

	set lha [expr {atan2(sin($azRad),(cos($azRad)*sin($latRad) + tan($altRad)*cos($latRad)))}]
	return [math::normalize360 [math::toDegrees $lha]]
    }

    # Horizontal coordinates to equitorial declination
    proc horizontal2declination {azimuth altitude latitude} {
	set azRad [math::toRadians $azimuth]
	set altRad [math::toRadians $altitude]
	set latRad [math::toRadians $latitude]

	set dec [expr {asin(sin($latRad)*sin($altRad) - cos($latRad)*cos($altRad)*cos($azRad))}]
	return [math::toDegrees $dec]
    }
}
