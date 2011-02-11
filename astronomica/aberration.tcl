
namespace eval ::astronomica::aberration {
    namespace path [namespace parent]

    ########################
    # Chapter 23
    # Apparent Place of Star
    ########################

    # Formula 23.2
    proc aberrationInLongitude {jd longitude latitude} {
	set k 20.49552
	set lonRad [math::toRadians $longitude]
	set latRad [math::toRadians $latitude]
	set t [expr {($jd - 2451545) / 36525.0}]
	set e [expr {0.016708634 - 0.000042037*$t - 0.0000001267*$t**2}]
	set pi [math::toRadians [expr {102.93735 + 1.71946*$t + 0.00046*$t**2}]]
	set lonSun [math::toRadians [sun::geometricLongitude $jd]]

	set aberration [expr {(-$k*cos($lonSun-$lonRad) + $e*$k*cos($pi-$lonRad)) / cos($latRad)}]
	return $aberration ;# in arc seconds
    }

    # Formula 23.2
    proc aberrationInLatitude {jd longitude latitude} {
	set k 20.49552
	set lonRad [math::toRadians $longitude]
	set latRad [math::toRadians $latitude]
	set t [expr {($jd - 2451545) / 36525.0}]
	set e [expr {0.016708634 - 0.000042037*$t - 0.0000001267*$t**2}]
	set pi [math::toRadians [expr {102.93735 + 1.71946*$t + 0.00046*$t**2}]]
	set lonSun [math::toRadians [sun::geometricLongitude $jd]]

	set aberration [expr {-$k*sin($latRad) * (sin($lonSun-$lonRad) - $e*sin($pi-$lonRad))}]
	return $aberration ;# in arc seconds
    }
}
