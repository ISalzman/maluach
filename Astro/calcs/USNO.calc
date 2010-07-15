
# Based on Explanatory Supplement to the Astronomical Almanac
# Edited by P. Kenneth Seidelmann, US Naval Observatory, 1992

namespace eval ::Astro::USNO {
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

    proc JD {Y M D} {
	set JD [expr {1461 * ($Y + 4800 + int(($M-14)/12.0)) / 4
		    + 367 * ($M - 2 - 12 * int(($M-14)/12.0)) / 12
		    - 3 * (($Y + 4900 + int(($M-14)/12.0)) / 100) / 4 + $D - 32075}]

	return $JD
    }

    proc Date {JD} {
	set Z [expr {int(floor($JD + 0.5))}]
	set F [expr {$JD + 0.5 - $Z}]

	set L [expr {$Z + 68569}]
	set N [expr {(4 * $L) / 146097}]
	set L [expr {$L - (146097 * $N + 3) / 4}]
	set I [expr {(4000 * ($L + 1)) / 1461001}]
	set L [expr {$L - (1461 * $I) / 4 + 31}]
	set J [expr {(80 * $L) / 2447}]
	set D [expr {$L - (2447 * $J) / 80}]
	set L [expr {$J / 11}]
	set M [expr {$J + 2 - 12 * $L}]
	set Y [expr {100 * ($N - 49) + $I + $L}]
	set D [expr {$D + $F}]

	return [list $Y $M $D]
    }

    proc DayOfWeek {Y M D} {
	set JD [JD $Y $M $D]
	set I [expr {int($JD) - 7 * ((int($JD) + 1) / 7) + 2}]

	return $I
    }

    proc ObliquityOfEcliptic {JD} {
	set T [expr {($JD - 2451545.0) / 36525.0}]
	set e [expr {23.4393 - 0.013*$T}]

	return $e ;# in degrees
    }

    proc MeanAnomalySun {JD} {
	set T [expr {($JD - 2451545.0) / 36525.0}]
	set G [expr {357.528 + 35999.050*$T}]

	return $G ;# in degrees
    }

    proc MeanLongitudeSun {JD} {
	set T [expr {($JD - 2451545.0) / 36525.0}]
	set L [expr {280.460 + 36000.770*$T}]

	return [normalize360 $L] ;# in degrees
    }

    proc EclipticLongitudeSun {JD} {
	set T [expr {($JD - 2451545.0) / 36525.0}]
	set G [toRadians [MeanAnomalySun $JD]]
	set L [MeanLongitudeSun $JD]

	set EL [expr {$L + 1.915*sin($G) + 0.020*sin(2.0*$G)}]
	return [normalize360 $EL] ;# in degrees
    }

    proc DeclinationSun {JD} {
	set e [toRadians [ObliquityOfEcliptic $JD]]
	set L [toRadians [EclipticLongitudeSun $JD]]

	set D [toDegrees [expr {asin(sin($e) * sin($L))}]]
	return $D ;# in degrees
    }

    proc EquationOfTime {JD} {
	set G [toRadians [MeanAnomalySun $JD]]
	set L [toRadians [EclipticLongitudeSun $JD]]

	set E [expr {-1.915*sin($G) - 0.020*sin(2.0*$G) + 2.466*sin(2.0*$L) - 0.053*sin(4.0*$L)}]
	return $E ;# in degrees
    }

    proc GreenwichHourAngle {JD UT} {
	set E [EquationOfTime $JD]
	set GHA [expr {15.0*$UT - 180 + $E}]

	return $GHA ;# in degrees
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

###

    proc LocalMeanTime {HA RA t} {
	namespace upvar ::Astro astro astro

	set HA [expr {$HA / $astro(degPerHour)}]
	set RA [expr {$RA / $astro(degPerHour)}]
	set T [expr {$HA + $RA - 0.06571*$t - 6.622}]

	return [normalize24 $T] ;# in hours
    }

    proc RiseSetSunUT {type DOY longitude latitude altitude} {
	namespace upvar ::Astro astro astro

	set t [ApproximateTime $DOY $longitude $type]
	set M [MeanAnomalySun $t]
	set L [TrueLongitudeSun $M]
	set D [DeclinationSun $L]
	set RA [RightAscensionSun $L]

	if {$type == $astro(typeRise)} {
	    set HA [HourAngle $latitude $D $altitude]
	    set LHA [expr {360.0 - $HA}]
	} elseif {$type == $astro(typeTransit)} {
	    set HA 0.0
	    set LHA 360.0
	} elseif {$type == $astro(typeSet)} {
	    set HA [HourAngle $latitude $D $altitude]
	    set LHA $HA
	}

	set T [LocalMeanTime $LHA $RA $t]
	set UT [expr {$T + $longitude / $astro(degPerHour)}]

	return $UT
    }
}

# vim:syn=tcl:
