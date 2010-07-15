
# Based on Almanac for Computers, 1991
# Nautical Almanac Office, US Naval Observatory
# see: http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
#
# Also found in Astronomical Formulas by Martin Zombeck, 1997
# see: http://www.adeptscience.co.uk/products/mathsim/mathcad/add-ons/free_ebooks/astro_form_samp.htm
#
# Code ideas from Ken Bloom (http://zmanim.sourceforge.net/)
# and Kevin Boone (SunTimes Java class)

namespace eval ::Astro::Zombeck {
    namespace export SunRiseUT SunSetUT SunTransitUT
    namespace import ::Astro::*

    proc SunRiseUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set DOY [DayOfYear $year $month $day]
	return [RiseSetSunUT $astro(typeRise) $DOY $longitude $latitude $altitude]
    }

    proc SunSetUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set DOY [DayOfYear $year $month $day]
	return [RiseSetSunUT $astro(typeSet) $DOY $longitude $latitude $altitude]
    }

    proc SunTransitUT {year month day longitude} {
	namespace upvar ::Astro astro astro

	set DOY [DayOfYear $year $month $day]
	return [RiseSetSunUT $astro(typeTransit) $DOY $longitude "" ""]
    }

    proc isLeapYear {Y} {
	if {($Y%4 == 0) && ($Y%400 ni [list 100 200 300])} {
	    return true
	}
	return false
    }

    proc DayOfYear {Y M D} {
	#set mult [expr {1 + ($Y%4 + 2)/3}]
	set mult [expr {[isLeapYear $Y] ? 1 : 2}]
	set DOY [expr {275*$M/9 - $mult*($M+9)/12 + $D - 30}]

	return $DOY
    }

    proc MeanAnomalySun {t} {
	set M [expr {0.9856*$t - 3.289}]
	return $M ;# in degrees
    }

    proc TrueLongitudeSun {M} {
	set Mrad [toRadians $M]
	set L [expr {$M + 1.916*sin($Mrad) + 0.020*sin(2.0*$Mrad) + 282.634}]

	return [normalize360 $L] ;# in degrees
    }

    proc RightAscensionSun {L} {
	set Lrad [toRadians $L]
	set RA [toDegrees [expr {atan2(0.91746 * sin($Lrad), cos($Lrad))}]]

	return [normalize360 $RA] ;# in degrees
    }

    proc DeclinationSun {L} {
	set sinD [expr {0.39782 * sin([toRadians $L])}]
	set D [toDegrees [expr {asin($sinD)}]]

	return $D ;# in degrees
    }

    proc HourAngle {latitude declination altitude} {
	set latRad [toRadians $latitude]
	set decRad [toRadians $declination]
	set altRad [toRadians $altitude]

	set cosH [expr {(sin($altRad) - sin($decRad) * sin($latRad))
			/ (cos($decRad) * cos($latRad))}]
	set HA [toDegrees [expr {acos($cosH)}]]

	return $HA ;# in degrees
    }

    proc LocalMeanTime {HA RA t} {
	namespace upvar ::Astro astro astro

	set HA [expr {$HA / $astro(degPerHour)}]
	set RA [expr {$RA / $astro(degPerHour)}]
	set T [expr {$HA + $RA - 0.06571*$t - 6.622}]

	return [normalize24 $T] ;# in hours
    }

    proc RiseSetSunUT {type DOY longitude latitude altitude} {
	namespace upvar ::Astro astro astro

	set lhr [expr {$longitude / $astro(degPerHour)}]

	# Approximate time
	if {$type == $astro(typeRise)} {
	    set t [expr {$DOY + (6.0 + $lhr) / 24.0}]
	} elseif {$type == $astro(typeTransit)} {
	    set t [expr {$DOY + (12.0 + $lhr) / 24.0}]
	} elseif {$type == $astro(typeSet)} {
	    set t [expr {$DOY + (18.0 + $lhr) / 24.0}]
	}

	set M [MeanAnomalySun $t]
	set L [TrueLongitudeSun $M]
	set D [DeclinationSun $L]
	set RA [RightAscensionSun $L]

	if {$type == $astro(typeRise)} {
	    set HA [HourAngle $latitude $D $altitude]
	    set LHA [expr {360.0 - $HA}]
	} elseif {$type == $astro(typeTransit)} {
	    set HA 0.0
	    set LHA 0.0
	} elseif {$type == $astro(typeSet)} {
	    set HA [HourAngle $latitude $D $altitude]
	    set LHA $HA
	}

	set T [LocalMeanTime $LHA $RA $t]
	set UT [expr {$T + $lhr}]

	return $UT
    }
}

# vim:syn=tcl:
