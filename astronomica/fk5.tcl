
namespace eval ::astronomica::fk5 {
    namespace path [namespace parent]

    ######################
    # Chapter 32
    # Positions of Planets
    ######################

    # Forumula 32.3
    proc longitudeCorrection {jd longitude latitude} {
	set t [expr {($jd - 2451545) / 36525.0}]
	set b [math::toRadians $latitude]
	set lp [math::toRadians [expr {$longitude - 1.397*$t - 0.00031*$t**2}]]

	set dlon [expr {-0.09033 + 0.03916 * (cos($lp) + sin($lp)) * tan($b)}]
	return $dlon ;# in arc seconds
    }

    proc latitudeCorrection {jd longitude} {
	set t [expr {($jd - 2451545) / 36525.0}]
	set lp [math::toRadians [expr {$longitude - 1.397*$t - 0.00031*$t**2}]]

	set dlat [expr {0.03916 * (cos($lp) - sin($lp))}]
	return $dlat ;# in arc seconds
    }
}
