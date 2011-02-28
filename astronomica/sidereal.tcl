
namespace eval ::astronomica::sidereal {
    namespace path [namespace parent]

    ###############
    # Chapter 12
    # Sidereal Time
    ###############

    # Formula 12.3
    proc meanGreenwichSiderealTime {jd} {
	variable [namespace parent]::astro

	;# Get jd at midnight
	lassign [date::ymd $jd] y m d
	set midnight [date::jd $y $m [expr {int($d)}]]

	set t [expr {($midnight - 2451545) / 36525.0}]
	set f [expr {$d - int($d)}]
	set theta [expr {100.46061837 + 36000.770053608*$t + 0.000387933*$t**2 - $t**3/38710000.0}]
	set theta [expr {$theta + ($f * 360 * 1.00273790935)}]
	set theta [expr {$theta / $astro(degPerHour)}] ;# convert to hours

	return [math::normalize24 $theta] ;# in hours
    }

    # Formula 12.4
    proc meanGreenwichSiderealTime-alt {jd} {
	variable [namespace parent]::astro

	set t [expr {($jd - 2451545) / 36525.0}]
	set theta [expr {280.46061837 + 360.98564736629*($jd - 2451545) + 0.000387933*$t**2 - $t**3/38710000.0}]
	set theta [expr {$theta / $astro(degPerHour)}] ;# convert to hours

	return [math::normalize24 $theta] ;# in hours
    }

    proc apparentGreenwichSiderealTime {jd} {
	set nutation [nutation::nutationInLongitude $jd]
	set obliquity [nutation::trueObliquityOfEcliptic $jd]

	set meanSidereal [meanGreenwichSiderealTime $jd]
	set apparentSidereal [expr {$meanSidereal + ($nutation * cos([math::toRadians $obliquity]) / 54000.0)}]

	return [math::normalize24 $apparentSidereal] ;# in hours
    }
}
