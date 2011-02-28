
# Based on Astronomical Algorithms, Second Edition by Jean Meeus, 1998
# Code ideas from PJ Naughter (http://www.naughter.com/aa.html)

package require Tcl 8.5
package provide astronomica 1.0

namespace eval ::astronomica {
    variable library [file dirname [file normalize [info script]]]

    variable astro
    set astro(degPerHour) [expr {360.0 / 24.0}]
    set astro(refraction) [expr {34.0 / 60.0}] ;# in degrees
    set astro(solarRadius) [expr {16.0 / 60.0}] ;# in degrees
    set astro(lighttime) 0.0057755183 ;# days / AU
    set astro(horizon) 0.0 ;# in degrees
    #set astro(tolerance) [expr {1 / 86400.0}] ;# within 1 second
    set astro(tolerance) [expr {10e-6}] ;# 0.00001 = within 0.86 of a second

    set astro(typeRise) 0
    set astro(typeSet) 1
    set astro(typeTransit) 2


    proc sunriseUT {year month day longitude latitude {altitude ""}} {
	variable astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set jd [date::jd $year $month $day]

	#set d1 [sun::apparentDeclination [expr {$jd - 1}]]
	#set d2 [sun::apparentDeclination $jd]
	#set d3 [sun::apparentDeclination [expr {$jd + 1}]]
	#set ra1 [sun::apparentRightAscension [expr {$jd - 1}]]
	#set ra2 [sun::apparentRightAscension $jd]
	#set ra3 [sun::apparentRightAscension [expr {$jd + 1}]]

	set details1 [elliptical::details [expr {$jd - 1}] SUN]
	set details2 [elliptical::details $jd SUN]
	set details3 [elliptical::details [expr {$jd + 1}] SUN]

	set d1 [dict get $details1 apparentDeclination]
	set d2 [dict get $details2 apparentDeclination]
	set d3 [dict get $details3 apparentDeclination]
	set ra1 [dict get $details1 apparentRightAscension]
	set ra2 [dict get $details2 apparentRightAscension]
	set ra3 [dict get $details3 apparentRightAscension]

	return [riseTransitSet::riseSetUT $astro(typeRise) $jd $longitude $latitude $altitude $ra1 $ra2 $ra3 $d1 $d2 $d3]
    }

    proc sunsetUT {year month day longitude latitude {altitude ""}} {
	variable astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set jd [date::jd $year $month $day]

	#set d1 [sun::apparentDeclination [expr {$jd - 1}]]
	#set d2 [sun::apparentDeclination $jd]
	#set d3 [sun::apparentDeclination [expr {$jd + 1}]]
	#set ra1 [sun::apparentRightAscension [expr {$jd - 1}]]
	#set ra2 [sun::apparentRightAscension $jd]
	#set ra3 [sun::apparentRightAscension [expr {$jd + 1}]]

	set details1 [elliptical::details [expr {$jd - 1}] SUN]
	set details2 [elliptical::details $jd SUN]
	set details3 [elliptical::details [expr {$jd + 1}] SUN]

	set d1 [dict get $details1 apparentDeclination]
	set d2 [dict get $details2 apparentDeclination]
	set d3 [dict get $details3 apparentDeclination]
	set ra1 [dict get $details1 apparentRightAscension]
	set ra2 [dict get $details2 apparentRightAscension]
	set ra3 [dict get $details3 apparentRightAscension]

	return [riseTransitSet::riseSetUT $astro(typeSet) $jd $longitude $latitude $altitude $ra1 $ra2 $ra3 $d1 $d2 $d3]
    }

    proc suntransitUT {year month day longitude} {
	set jd [date::jd $year $month $day]

	#set ra1 [sun::apparentRightAscension [expr {$jd - 1}]]
	#set ra2 [sun::apparentRightAscension $jd]
	#set ra3 [sun::apparentRightAscension [expr {$jd + 1}]]

	set details1 [elliptical::details [expr {$jd - 1}] SUN]
	set details2 [elliptical::details $jd SUN]
	set details3 [elliptical::details [expr {$jd + 1}] SUN]

	set ra1 [dict get $details1 apparentRightAscension]
	set ra2 [dict get $details2 apparentRightAscension]
	set ra3 [dict get $details3 apparentRightAscension]

	return [riseTransitSet::transitUT $jd $longitude $ra1 $ra2 $ra3]
    }
}
