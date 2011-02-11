
# Based on Astronomical Algorithms, Second Edition by Jean Meeus, 1998
# Code ideas from PJ Naughter (http://www.naughter.com/aa.html)

namespace eval ::Astro::Meeus {
    namespace export SunRiseUT SunSetUT SunTransitUT
    namespace import ::Astro::*

    proc SunRiseUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set JD [Date::JD $year $month $day]
	return [Sun::RiseSetUT $astro(typeRise) $JD $longitude $latitude $altitude]
    }

    proc SunSetUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	if {$altitude eq ""} {
	    set altitude [expr {$astro(horizon) - $astro(refraction) - $astro(solarRadius)}]
	}

	set JD [Date::JD $year $month $day]
	return [Sun::RiseSetUT $astro(typeSet) $JD $longitude $latitude $altitude]
    }

    proc SunTransitUT {year month day longitude} {
	set JD [Date::JD $year $month $day]
	return [Sun::TransitUT $JD $longitude]
    }

    namespace eval Interpolate {

	###############
	# Chapter 3
	# Interpolation
	###############

	# Formula 3.3
	proc Interpolate {y1 y2 y3 n} {
	    set a [expr {$y2 - $y1}]
	    set b [expr {$y3 - $y2}]
	    set c [expr {$y1 + $y3 - 2.0 * $y2}]
	    set y [expr {$y2 + ($n / 2.0) * ($a + $b + $n * $c)}]

	    return $y
	}
    }

    namespace eval Date {

	############
	# Chapter 7
	# Julian Day
	############

	# Formula 7.1
	proc JD {Y M D} {
	    if {$M == 1 || $M == 2} {
		set Y [expr {$Y - 1}]
		set M [expr {$M + 12}]
	    }

	    set B 0
	    if {[isGregorian $Y $M $D]} {
		set A [expr {int(floor($Y / 100.0))}]
		set B [expr {2 - $A + int(floor($A / 4.0))}]
	    }

	    set JD [expr {int(floor(365.25 * ($Y + 4716)))
			+ int(floor(30.6001 * ($M + 1)))
			+ $D + $B - 1524.5}]

	    return $JD
	}

	proc DateFromJD {JD} {
	    set Z [expr {int(floor($JD + 0.5))}]
	    set F [expr {$JD + 0.5 - $Z}]

	    set A $Z
	    if {$Z >= 2299161} {
		set a [expr {int(floor(($Z - 1867216.25) / 36524.25))}]
		set A [expr {$Z + 1 + $a - int(floor($a / 4.0))}]
	    }

	    set B [expr {$A + 1524}]
	    set C [expr {int(floor(($B - 122.1) / 365.25))}]
	    set D [expr {int(floor(365.25 * $C))}]
	    set E [expr {int(floor(($B - $D) / 30.6001))}]

	    set d [expr {$B - $D - int(floor(30.6001 * $E)) + $F}]
	    set m [expr {$E < 14 ? $E - 1 : $E - 13}]
	    set y [expr {$m > 2 ? $C - 4716 : $C - 4715}]

	    return [list $y $m $d]
	}

	proc isGregorian {Y M D} {
	    if {$Y >  1582
		    || $Y == 1582 && $M >  10
		    || $Y == 1582 && $M == 10 && $D >= 15.0} {
		return true
	    }

	    return false
	}

	proc isLeapYear {Y} {
	    if {$Y % 4} {
		return false
	    }
	    if {$Y % 100} {
		return true
	    }
	    if {$Y % 400} {
		return false
	    }
	    return true
	}

	proc DayOfWeek {Y M D} {
	    set JD [JD $Y $M $D]
	    set WD [expr {int(floor($JD + 1.5)) % 7 + 1}]

	    return $WD
	}

	proc DayOfYear {Y M D} {
	    set K [expr {[isLeapYear $Y] ? 1 : 2}]
	    set N [expr {int(floor(275 * $M / 9)) - $K * int(floor(($M + 9) / 12)) + $D - 30}]

	    return $N
	}

	proc FractionalYear {JD} {
	    foreach {y m d} [DateFromJD $JD] {break;}
	    set JD0 [JD $y 1 1]
	    set days [expr {[isLeapYear $y] ? 366 : 365}]
	    set fraction [expr {($JD - $JD0) / $days}]

	    return [expr {$y + $fraction}]
	}
    }

    namespace eval JewishDate {

	#################
	# Chapter 9
	# Jewish Calendar
	#################

	namespace path [namespace parent]

	proc Pesach {X} {
	    set C [expr {int(floor($X / 100.0))}]
	    set S [expr {$X < 1583 ? 0 : int(floor((3 * $C - 5) / 4.0))}]

	    set A [expr {$X + 3760}]
	    set a [expr {(12 * $X + 12) % 19}]
	    set b [expr {$X % 4}]
	    set Q [expr {-1.904412361576 + 1.554241796621 * $a
			+ 0.25 * $b - 0.003177794022 * $X + $S}]

	    set j [expr {(int(floor($Q)) + 3 * $X + 5 * $b + 2 - $S) % 7}]
	    set r [expr {$Q - int(floor($Q))}]

	    if {$j == 2 || $j == 4 || $j == 6} {
		set D [expr {int(floor($Q)) + 23}]
	    } elseif {$j == 1 && $a > 6 && $r >= 0.632870370} {
		set D [expr {int(floor($Q)) + 24}]
	    } elseif {$j == 0 && $a > 11 && $r >= 0.897723765} {
		set D [expr {int(floor($Q)) + 23}]
	    } else {
		set D [expr {int(floor($Q)) + 22}]
	    }

	    set M 3
	    if {$D > 31} {
		set M 4
		set D [expr {$D - 31}]
	    }

	    return [list $X $M $D]
	}

	proc RoshHashanah {X} {
	    set P [Pesach $X]
	    set Pjd [Date::JD {*}$P]
	    set Rjd [expr {$Pjd + 163}]

	    foreach {Y M D} [Date::DateFromJD $Rjd] {break;}

	    return [list $Y $M [expr {int($D)}]]
	}

	proc JewishYear {X} {
	    # At Rosh Hashanah
	    set A [expr {$X + 3761}]
	    return $A
	}

	proc isLeapYear {A} {
	    if {$A%19 in [list 0 3 6 8 11 14 17]} {
		return true
	    }
	    return false
	}
    }

    namespace eval DynamicalTime {

	################
	# Chapter 10
	# Dynamical Time
	################

	# Data taken from:
	# ftp://maia.usno.navy.mil/ser7/deltat.data
	# ftp://maia.usno.navy.mil/ser7/deltat.preds
	# ftp://maia.usno.navy.mil/ser7/historic_deltat.data

	namespace path [namespace parent]

	variable deltaTdata {
	    1900 -2.70
	    1901 -1.48
	    1902 -0.08
	    1903  1.26
	    1904  2.59
	    1905  3.92
	    1906  5.20
	    1907  6.29
	    1908  7.68
	    1909  9.13
	    1910 10.38
	    1911 11.64
	    1912 13.23
	    1913 14.69
	    1914 16.00
	    1915 17.19
	    1916 18.19
	    1917 19.13
	    1918 20.14
	    1919 20.86
	    1920 21.41
	    1921 22.06
	    1922 22.51
	    1923 23.01
	    1924 23.46
	    1925 23.63
	    1926 23.95
	    1927 24.39
	    1928 24.34
	    1929 24.10
	    1930 24.02
	    1931 23.98
	    1932 23.89
	    1933 23.93
	    1934 23.88
	    1935 23.91
	    1936 23.76
	    1937 23.91
	    1938 23.96
	    1939 24.04
	    1940 24.35
	    1941 24.82
	    1942 25.30
	    1943 25.77
	    1944 26.27
	    1945 26.76
	    1946 27.27
	    1947 27.77
	    1948 28.25
	    1949 28.70
	    1950 29.15
	    1951 29.57
	    1952 29.97
	    1953 30.36
	    1954 30.72
	    1955 31.07
	    1956 31.349
	    1957 31.677
	    1958 32.166
	    1959 32.671
	    1960 33.150
	    1961 33.584
	    1962 33.992
	    1963 34.466
	    1964 35.030
	    1965 35.738
	    1966 36.546
	    1967 37.429
	    1968 38.291
	    1969 39.204
	    1970 40.182
	    1971 41.170
	    1972 42.227
	    1973 43.373
	    1974 44.484
	    1975 45.476
	    1976 46.457
	    1977 47.521
	    1978 48.534
	    1979 49.586
	    1980 50.539
	    1981 51.381
	    1982 52.167
	    1983 52.957
	    1984 53.788
	    1985 54.343
	    1986 54.871
	    1987 55.322
	    1988 55.820
	    1989 56.300
	    1990 56.855
	    1991 57.565
	    1992 58.309
	    1993 59.122
	    1994 59.985
	    1995 60.785
	    1996 61.629
	    1997 62.295
	    1998 62.966
	    1999 63.467
	    2000 63.829
	    2001 64.091
	    2002 64.300
	    2003 64.473
	    2004 64.574
	    2005 64.688
	    2006 64.845
	    2007 65.146
	    2008 65.457
	    2009 65.777
	    2010 66.070

	    # Future predictions
	    2011 67.1
	    2012 68.0
	    2013 68.0
	    2014 69.0
	    2015 69.0
	    2016 70.0
	    2017 70.0
	}

	proc Init {} {
	    variable deltaTdict
	    variable deltaTdata

	    set deltaTdict [dict create]

	    foreach line [split $deltaTdata "\n"] {
		set line [string trim $line]
		if {$line eq ""} {
		    continue
		}

		if {[string index $line 0] eq "#"} {
		    continue
		}

		foreach {y dt} $line {
		    dict set deltaTdict $y $dt
		}
	    }

	    return
	}

	proc DeltaT {JD} {
	    variable deltaTdict

	    if {! [info exists deltaTdict] || [dict size $deltaTdict] == 0} {
		Init
	    }

	    set y [Date::FractionalYear $JD]
	    set Y [expr {int($y)}]
	    set t [expr {($y - 2000.0) / 100.0}]

	    if {[dict exists $deltaTdict $Y]} {
		set dT [dict get $deltaTdict $Y]
	    } elseif {$y < 948} {
		set dT [expr {2177.0 + 497.0*$t + 44.1*$t**2}]
	    } elseif {$y < 2000} {
		set dT [expr {102.0 + 102.0*$t + 25.3*$t**2}]
	    } elseif {$y < 2100} {
		set dT [expr {102.0 + 102.0*$t + 25.3*$t**2 + 0.37*($y - 2100.0)}]
	    }

	    return $dT
	}
    }

    namespace eval Sidereal {

	###############
	# Chapter 12
	# Sidereal Time
	###############

	namespace path [namespace parent]

	proc MeanGreenwichSiderealTime {JD} {
	    namespace upvar ::Astro astro astro

	    ;# Get JD at midnight
	    foreach {Y M D} [Date::DateFromJD $JD] {break;}
	    set JDMidnight [Date::JD $Y $M [expr {int($D)}]]

	    set T [expr {($JDMidnight - 2451545.0) / 36525.0}]
	    set F [expr {$D - int($D)}]
	    set Theta [expr {100.46061837 + (36000.770053608*$T) + (0.000387933*$T**2) - ($T**3/38710000.0)}]
	    set theta [expr {$Theta + ($F * 360.0 * 1.00273790935)}]
	    set theta [expr {$theta / $astro(degPerHour)}] ;# convert to hours

	    return [normalize24 $theta] ;# in hours
	}

	proc ApparentGreenwichSiderealTime {JD} {
	    set nutation [Nutation::NutationInLongitude $JD]
	    set obliquity [Nutation::TrueObliquityOfEcliptic $JD]

	    set MeanSidereal [MeanGreenwichSiderealTime $JD]
	    set ApparentSidereal [expr {$MeanSidereal + ($nutation * cos([toRadians $obliquity]) / 54000.0)}]

	    return [normalize24 $ApparentSidereal] ;# in hours
	}
    }

    namespace eval RiseTransitSet {

	####################
	# Chapter 15
	# Rise, Transit, Set
	####################

	namespace path [namespace parent]

	proc HourAngle {latitude altitude declination} {
	    set latRad [toRadians $latitude]
	    set altRad [toRadians $altitude]
	    set decRad [toRadians $declination]

	    set cosH [expr {(sin($altRad) - sin($latRad) * sin($decRad))
			    / (cos($latRad) * cos($decRad))}]

	    if {($cosH < -1) || ($cosH > 1)} {
		# Circumpolar - never rises or sets
		# :TODO: Return appropriate error
	    }

	    set H [toDegrees [expr {acos($cosH)}]]

	    return $H ;# in degrees
	}

	proc Transit0 {JD longitude ra} {
	    namespace upvar ::Astro astro astro

	    set theta0 [Sidereal::ApparentGreenwichSiderealTime $JD]
	    set m0 [expr {($ra + $longitude - $theta0 * $astro(degPerHour)) / 360.0}]

	    if {$m0 < 0.0 || $m0 > 1.0} {
		set fix [expr {$m0 < 0.0 ? 1.0 : -1.0}]
		set m0 [expr {$m0 + $fix}]
	    }

	    return $m0
	}

	proc TransitUT {JD longitude ra1 ra2 ra3} {
	    namespace upvar ::Astro astro astro

	    set dT [DynamicalTime::DeltaT $JD]
	    set m [Transit0 $JD $longitude $ra2]
	    set theta0 [Sidereal::ApparentGreenwichSiderealTime $JD]

	    # Correct RA values for interpolation
	    if {($ra2 - $ra1) > 180.0} {
		set ra1 [expr {$ra1 + 360.0}]
	    } elseif {($ra2 - $ra1) < -180.0} {
		set ra2 [expr {$ra2 + 360.0}]
	    }
	    if {($ra3 - $ra2) > 180.0} {
		set ra2 [expr {$ra2 + 360.0}]
	    } elseif {($ra3 - $ra2) < -180.0} {
		set ra3 [expr {$ra3 + 360.0}]
	    }

	    while {1} {
		set n [expr {$m + $dT / 86400.0}]
		set ra [Interpolate::Interpolate $ra1 $ra2 $ra3 $n]
		set th [expr {$theta0 * $astro(degPerHour) + 360.985647 * $m}]
		set H [expr {$th - $longitude - $ra}]
		set dm [expr {[normalize180 $H] / -360.0}]

		if {abs($dm) < $astro(tolerance)} {
		    break
		}

		set m [expr {$m + $dm}]
	    }

	    set m [expr {$m * 24.0}]
	    return $m
	}

	proc RiseSet0 {type JD longitude latitude altitude ra decl} {
	    namespace upvar ::Astro astro astro

	    if {$type == $astro(typeRise)} {
		set sign -1
	    } elseif {$type == $astro(typeSet)} {
		set sign 1
	    }

	    set m0 [Transit0 $JD $longitude $ra]
	    set H0 [HourAngle $latitude $altitude $decl]
	    set m1 [expr {$m0 + $H0 / 360.0 * $sign}]

	    if {$m1 < 0.0 || $m1 > 1.0} {
		set fix [expr {$m1 < 0.0 ? 1.0 : -1.0}]
		set m1 [expr {$m1 + $fix}]
	    }

	    return $m1
	}

	proc RiseSetUT {type JD longitude latitude altitude ra1 ra2 ra3 d1 d2 d3} {
	    namespace upvar ::Astro astro astro

	    set dT [DynamicalTime::DeltaT $JD]
	    set m [RiseSet0 $type $JD $longitude $latitude $altitude $ra2 $d2]
	    set theta0 [Sidereal::ApparentGreenwichSiderealTime $JD]

	    # Correct RA values for interpolation
	    if {($ra2 - $ra1) > 180.0} {
		set ra1 [expr {$ra1 + 360.0}]
	    } elseif {($ra2 - $ra1) < -180.0} {
		set ra2 [expr {$ra2 + 360.0}]
	    }
	    if {($ra3 - $ra2) > 180.0} {
		set ra2 [expr {$ra2 + 360.0}]
	    } elseif {($ra3 - $ra2) < -180.0} {
		set ra3 [expr {$ra3 + 360.0}]
	    }

	    while {1} {
		set n [expr {$m + $dT / 86400.0}]
		set d [Interpolate::Interpolate $d1 $d2 $d3 $n]
		set ra [Interpolate::Interpolate $ra1 $ra2 $ra3 $n]
		set th [expr {$theta0 * $astro(degPerHour) + 360.985647 * $m}]
		set H [expr {$th - $longitude - $ra}]

		# Formula 13.6
		set sinh [expr {sin([toRadians $latitude]) * sin([toRadians $d])
			    + cos([toRadians $latitude]) * cos([toRadians $d]) * cos([toRadians $H])}]
		set h [toDegrees [expr {asin($sinh)}]]

		set dm [expr {($h - $altitude)
			    / 360.0 * cos([toRadians $d]) * cos([toRadians $latitude]) * sin([toRadians $H])}]

		if {abs($dm) < $astro(tolerance)} {
		    break
		}

		set m [expr {$m + $dm}]
	    }

	    set m [expr {$m * 24.0}]
	    return $m
	}
    }

    namespace eval Nutation {

	########################
	# Chapter 22
	# Nutation and Obliquity
	########################

	namespace path [namespace parent]

	variable NutationCoefficients {
	    0.0  0.0  0.0  0.0  1.0 -171996.0 -174.2 92025.0  8.9
	   -2.0  0.0  0.0  2.0  2.0  -13187.0   -1.6  5736.0 -3.1
	    0.0  0.0  0.0  2.0  2.0   -2274.0   -0.2   977.0 -0.5
	    0.0  0.0  0.0  0.0  2.0    2062.0    0.2  -895.0  0.5
	    0.0  1.0  0.0  0.0  0.0    1426.0   -3.4    54.0 -0.1
	    0.0  0.0  1.0  0.0  0.0     712.0    0.1    -7.0  0.0
	   -2.0  1.0  0.0  2.0  2.0    -517.0    1.2   224.0 -0.6
	    0.0  0.0  0.0  2.0  1.0    -386.0   -0.4   200.0  0.0
	    0.0  0.0  1.0  2.0  2.0    -301.0    0.0   129.0 -0.1
	   -2.0 -1.0  0.0  2.0  2.0     217.0   -0.5   -95.0  0.3
	   -2.0  0.0  1.0  0.0  0.0    -158.0    0.0     0.0  0.0
	   -2.0  0.0  0.0  2.0  1.0     129.0    0.1   -70.0  0.0
	    0.0  0.0 -1.0  2.0  2.0     123.0    0.0   -53.0  0.0
	    2.0  0.0  0.0  0.0  0.0      63.0    0.0     0.0  0.0
	    0.0  0.0  1.0  0.0  1.0      63.0    0.1   -33.0  0.0
	    2.0  0.0 -1.0  2.0  2.0     -59.0    0.0    26.0  0.0
	    0.0  0.0 -1.0  0.0  1.0     -58.0   -0.1    32.0  0.0
	    0.0  0.0  1.0  2.0  1.0     -51.0    0.0    27.0  0.0
	   -2.0  0.0  2.0  0.0  0.0      48.0    0.0     0.0  0.0
	    0.0  0.0 -2.0  2.0  1.0      46.0    0.0   -24.0  0.0
	    2.0  0.0  0.0  2.0  2.0     -38.0    0.0    16.0  0.0
	    0.0  0.0  2.0  2.0  2.0     -31.0    0.0    13.0  0.0
	    0.0  0.0  2.0  0.0  0.0      29.0    0.0     0.0  0.0
	   -2.0  0.0  1.0  2.0  2.0      29.0    0.0   -12.0  0.0
	    0.0  0.0  0.0  2.0  0.0      26.0    0.0     0.0  0.0
	   -2.0  0.0  0.0  2.0  0.0     -22.0    0.0     0.0  0.0
	    0.0  0.0 -1.0  2.0  1.0      21.0    0.0   -10.0  0.0
	    0.0  2.0  0.0  0.0  0.0      17.0   -0.1     0.0  0.0
	    2.0  0.0 -1.0  0.0  1.0      16.0    0.0    -8.0  0.0
	   -2.0  2.0  0.0  2.0  2.0     -16.0    0.1     7.0  0.0
	    0.0  1.0  0.0  0.0  1.0     -15.0    0.0     9.0  0.0
	   -2.0  0.0  1.0  0.0  1.0     -13.0    0.0     7.0  0.0
	    0.0 -1.0  0.0  0.0  1.0     -12.0    0.0     6.0  0.0
	    0.0  0.0  2.0 -2.0  0.0      11.0    0.0     0.0  0.0
	    2.0  0.0 -1.0  2.0  1.0     -10.0    0.0     5.0  0.0
	    2.0  0.0  1.0  2.0  2.0      -8.0    0.0     3.0  0.0
	    0.0  1.0  0.0  2.0  2.0       7.0    0.0    -3.0  0.0
	   -2.0  1.0  1.0  0.0  0.0      -7.0    0.0     0.0  0.0
	    0.0 -1.0  0.0  2.0  2.0      -7.0    0.0     3.0  0.0
	    2.0  0.0  0.0  2.0  1.0      -7.0    0.0     3.0  0.0
	    2.0  0.0  1.0  0.0  0.0       6.0    0.0     0.0  0.0
	   -2.0  0.0  2.0  2.0  2.0       6.0    0.0    -3.0  0.0
	   -2.0  0.0  1.0  2.0  1.0       6.0    0.0    -3.0  0.0
	    2.0  0.0 -2.0  0.0  1.0      -6.0    0.0     3.0  0.0
	    2.0  0.0  0.0  0.0  1.0      -6.0    0.0     3.0  0.0
	    0.0 -1.0  1.0  0.0  0.0       5.0    0.0     0.0  0.0
	   -2.0 -1.0  0.0  2.0  1.0      -5.0    0.0     3.0  0.0
	   -2.0  0.0  0.0  0.0  1.0      -5.0    0.0     3.0  0.0
	    0.0  0.0  2.0  2.0  1.0      -5.0    0.0     3.0  0.0
	   -2.0  0.0  2.0  0.0  1.0       4.0    0.0     0.0  0.0
	   -2.0  1.0  0.0  2.0  1.0       4.0    0.0     0.0  0.0
	    0.0  0.0  1.0 -2.0  0.0       4.0    0.0     0.0  0.0
	   -1.0  0.0  1.0  0.0  0.0      -4.0    0.0     0.0  0.0
	   -2.0  1.0  0.0  0.0  0.0      -4.0    0.0     0.0  0.0
	    1.0  0.0  0.0  0.0  0.0      -4.0    0.0     0.0  0.0
	    0.0  0.0  1.0  2.0  0.0       3.0    0.0     0.0  0.0
	    0.0  0.0 -2.0  2.0  2.0      -3.0    0.0     0.0  0.0
	   -1.0 -1.0  1.0  0.0  0.0      -3.0    0.0     0.0  0.0
	    0.0  1.0  1.0  0.0  0.0      -3.0    0.0     0.0  0.0
	    0.0 -1.0  1.0  2.0  2.0      -3.0    0.0     0.0  0.0
	    2.0 -1.0 -1.0  2.0  2.0      -3.0    0.0     0.0  0.0
	    0.0  0.0  3.0  2.0  2.0      -3.0    0.0     0.0  0.0
	    2.0 -1.0  0.0  2.0  2.0      -3.0    0.0     0.0  0.0
	}

	proc NutationInLongitude {JD} {
	    variable NutationCoefficients

	    set T [expr {($JD - 2451545.0) / 36525.0}]

	    set D [expr {297.85036 + 445267.111480*$T - 0.0019142*$T**2 + $T**3/189474.0}]
	    set D [normalize360 $D]

	    set M [expr {357.52772 + 35999.050340*$T - 0.0001603*$T**2 - $T**3/300000.0}]
	    set M [normalize360 $M]

	    set Mprime [expr {134.96298 + 477198.867398*$T + 0.0086972*$T**2 + $T**3/56250.0}]
	    set Mprime [normalize360 $Mprime]

	    set F [expr {93.27191 + 483202.017538*$T - 0.0036825*$T**2 + $T**3/327270.0}]
	    set F [normalize360 $F]

	    set Omega [expr {125.04452 - 1934.136261*$T + 0.0020708*$T**2 + $T**3/450000.0}]
	    set Omega [normalize360 $Omega]

	    set nutation 0.0
	    foreach {Dcoeff Mcoeff Mpcoeff Fcoeff Ocoeff sincoeff1 sincoeff2 coscoeff1 coscoeff2} $NutationCoefficients {
		set arg [expr {$Dcoeff*$D + $Mcoeff*$M + $Mpcoeff*$Mprime + $Fcoeff*$F + $Ocoeff*$Omega}]
		set nutation [expr {$nutation + ($sincoeff1 + $sincoeff2*$T) * sin([toRadians $arg]) * 0.0001}]
	    }

	    return $nutation ;# in arc seconds
	}

	proc NutationInObliquity {JD} {
	    variable NutationCoefficients

	    set T [expr {($JD - 2451545.0) / 36525.0}]

	    set D [expr {297.85036 + 445267.111480*$T - 0.0019142*$T**2 + $T**3/189474.0}]
	    set D [normalize360 $D]

	    set M [expr {357.52772 + 35999.050340*$T - 0.0001603*$T**2 - $T**3/300000.0}]
	    set M [normalize360 $M]

	    set Mprime [expr {134.96298 + 477198.867398*$T + 0.0086972*$T**2 + $T**3/56250.0}]
	    set Mprime [normalize360 $Mprime]

	    set F [expr {93.27191 + 483202.017538*$T - 0.0036825*$T**2 + $T**3/327270.0}]
	    set F [normalize360 $F]

	    set Omega [expr {125.04452 - 1934.136261*$T + 0.0020708*$T**2 + $T**3/450000.0}]
	    set Omega [normalize360 $Omega]

	    set nutation 0.0
	    foreach {Dcoeff Mcoeff Mpcoeff Fcoeff Ocoeff sincoeff1 sincoeff2 coscoeff1 coscoeff2} $NutationCoefficients {
		set arg [expr {$Dcoeff*$D + $Mcoeff*$M + $Mpcoeff*$Mprime + $Fcoeff*$F + $Ocoeff*$Omega}]
		set nutation [expr {$nutation + ($coscoeff1 + $coscoeff2*$T) * cos([toRadians $arg]) * 0.0001}]
	    }

	    return $nutation ;# in arc seconds
	}

	proc MeanObliquityOfEcliptic {JD} {
	    set U [expr {($JD - 2451545.0) / 3652500.0}]
	    set seconds [expr {21.448 - 4680.93*$U
				      - 1.55*$U**2
				      + 1999.25*$U**3
				      - 51.38*$U**4
				      - 249.67*$U**5
				      - 39.05*$U**6
				      + 7.12*$U**7
				      + 27.87*$U**8
				      + 5.79*$U**9
				      + 2.45*$U**10}]

	    set obliquity [expr {23.0 + (26.0 / 60.0) + ($seconds / 3600.0)}]
	    return $obliquity ;# in degrees
	}

	proc TrueObliquityOfEcliptic {JD} {
	    set MeanObliquity [MeanObliquityOfEcliptic $JD]
	    set NutationInObliquity [NutationInObliquity $JD]
	    set obliquity [expr {$MeanObliquity + $NutationInObliquity / 3600.0}]

	    return $obliquity ;# in degrees
	}
    }

    namespace eval Aberration {

	########################
	# Chapter 23
	# Apparent Place of Star
	########################

	namespace path [namespace parent]

	proc AberrationInLongitude {JD longitude latitude} {
	    set k 20.49552
	    set lonRad [toRadians $longitude]
	    set latRad [toRadians $latitude]
	    set T [expr {($JD - 2451545.0) / 36525.0}]
	    set e [expr {0.016708634 - 0.000042037*$T - 0.0000001267*$T**2}]
	    set pi [toRadians [expr {102.93735 + 1.71946*$T + 0.00046*$T**2}]]
	    set lonSun [toRadians [Sun::GeometricLongitude $JD]]

	    set aberration [expr {(-$k*cos($lonSun-$lonRad) + $e*$k*cos($pi-$lonRad)) / cos($latRad)}]
	    return $aberration ;# in arc seconds
	}

	proc AberrationInLatitude {JD longitude latitude} {
	    set k 20.49552
	    set lonRad [toRadians $longitude]
	    set latRad [toRadians $latitude]
	    set T [expr {($JD - 2451545.0) / 36525.0}]
	    set e [expr {0.016708634 - 0.000042037*$T - 0.0000001267*$T**2}]
	    set pi [toRadians [expr {102.93735 + 1.71946*$T + 0.00046*$T**2}]]
	    set lonSun [toRadians [Sun::GeometricLongitude $JD]]

	    set aberration [expr {-$k*sin($latRad) * (sin($lonSun-$lonRad) - $e*sin($pi-$lonRad))}]
	    return $aberration ;# in arc seconds
	}
    }

    namespace eval Sun {

	###################
	# Chapter 25
	# Solar Coordinates
	###################

	namespace path [namespace parent]

	proc GeometricLongitude {JD} {
	    set longitude [expr {[Earth::EclipticLongitude $JD] + 180.0}]
	    return [normalize360 $longitude] ;# in degrees
	}

	proc GeometricLatitude {JD} {
	    set latitude [expr {-[Earth::EclipticLatitude $JD]}]
	    return $latitude ;# in degrees
	}

	proc ApparentLongitude {JD} {
	    set longitude [GeometricLongitude $JD]
	    set latitude [GeometricLatitude $JD]
	    set radius [Earth::RadiusVector $JD]
	    set fk5correction [FK5::LongitudeCorrection $JD $longitude $latitude]
	    set nutation [Nutation::NutationInLongitude $JD]
	    set aberration [expr {-20.4898 / $radius}]

	    set longitude [expr {$longitude + ($fk5correction + $nutation + $aberration) / 3600.0}]
	    return $longitude ;# in degrees
	}

	proc ApparentLatitude {JD} {
	    set longitude [GeometricLongitude $JD]
	    set latitude [GeometricLatitude $JD]
	    set fk5correction [FK5::LatitudeCorrection $JD $longitude]

	    set latitude [expr {$latitude + $fk5correction / 3600.0}]
	    return $latitude ;# in degrees
	}

	proc ApparentRightAscension {JD} {
	    set longitude [toRadians [ApparentLongitude $JD]]
	    set latitude [toRadians [ApparentLatitude $JD]]
	    set obliquity [toRadians [Nutation::TrueObliquityOfEcliptic $JD]]

	    # Formula 13.3
	    set RA [expr {atan2(sin($longitude)*cos($obliquity) - tan($latitude)*sin($obliquity), cos($longitude))}]
	    return [normalize360 [toDegrees $RA]] ;# in degrees
	}

	proc ApparentDeclination {JD} {
	    set longitude [toRadians [ApparentLongitude $JD]]
	    set latitude [toRadians [ApparentLatitude $JD]]
	    set obliquity [toRadians [Nutation::TrueObliquityOfEcliptic $JD]]

	    # Formula 13.4
	    set D [expr {asin(sin($latitude)*cos($obliquity) + cos($latitude)*sin($obliquity)*sin($longitude))}]
	    return [toDegrees $D] ;# in degrees
	}

	# Method described in Chapter 33
	proc Details {JD} {
	    namespace upvar ::Astro astro astro

	    set JD0 $JD
	    set Lpre 0.0
	    set Bpre 0.0
	    set Rpre 0.0
	    
	    # Adjust JD for the effect of light-time
	    while {1} {
		set L [toRadians [GeometricLongitude $JD0]]
		set B [toRadians [GeometricLatitude $JD0]]
		set R [Earth::RadiusVector $JD0]

		set tau [expr {$R * $astro(lighttime)}]
		set JD0 [expr {$JD - $tau}]

		if {abs($L - $Lpre) < 0.00001
		    && abs($B - $Bpre) < 0.00001
		    && abs($R - $Rpre) < 0.000001} {
		    break
		}

		set Lpre $L
		set Bpre $B
		set Rpre $R
	    }

	    set x [expr {$R * cos($B) * cos($L)}]
	    set y [expr {$R * cos($B) * sin($L)}]
	    set z [expr {$R * sin($B)}]

	    set distance [expr {sqrt($x**2 + $y**2 + $z**2)}]
	    set lighttime [expr {$distance * $astro(lighttime)}]
	    set longitude [normalize360 [toDegrees [expr {atan2($y, $x)}]]]
	    set latitude [toDegrees [expr {atan2($z, sqrt($x**2 + $y**2))}]]

	    # Adjust for Aberration
	    set aberrationX [Aberration::AberrationInLongitude $JD $longitude $latitude]
	    set aberrationY [Aberration::AberrationInLatitude $JD $longitude $latitude]
	    set longitude [expr {$longitude + $aberrationX / 3600.0}]
	    set latitude [expr {$latitude + $aberrationY / 3600.0}]

	    # Convert to the FK5 system
	    set correctionX [FK5::LongitudeCorrection $JD $longitude $latitude]
	    set correctionY [FK5::LatitudeCorrection $JD $longitude]
	    set longitude [expr {$longitude + $correctionX / 3600.0}]
	    set latitude [expr {$latitude + $correctionY / 3600.0}]

	    # Correct for nutation
	    set nutation [Nutation::NutationInLongitude $JD]
	    set longitude [expr {$longitude + $nutation / 3600.0}]

	    # Convert to RA and Dec
	    set lonRad [toRadians $longitude]
	    set latRad [toRadians $latitude]
	    set obliquity [toRadians [Nutation::TrueObliquityOfEcliptic $JD]]

	    # Formula 13.3
	    set RA [expr {atan2(sin($lonRad)*cos($obliquity) - tan($latRad)*sin($obliquity), cos($lonRad))}]
	    set RA [normalize360 [toDegrees $RA]]

	    # Formula 13.4
	    set Dec [expr {asin(sin($latRad)*cos($obliquity) + cos($latRad)*sin($obliquity)*sin($lonRad))}]
	    set Dec [toDegrees $Dec]

	    set details [dict create]
	    dict set details ApparentDistance $distance
	    dict set details ApparentLightTime $lighttime
	    dict set details ApparentLongitude $longitude
	    dict set details ApparentLatitude $latitude
	    dict set details ApparentRightAscension $RA
	    dict set details ApparentDeclination $Dec

	    return $details
	}

	proc TransitUT {JD longitude} {
	    #set RA1 [ApparentRightAscension [expr {$JD - 1}]]
	    #set RA2 [ApparentRightAscension $JD]
	    #set RA3 [ApparentRightAscension [expr {$JD + 1}]]

	    set details1 [Details [expr {$JD - 1}]]
	    set details2 [Details $JD]
	    set details3 [Details [expr {$JD + 1}]]

	    set RA1 [dict get $details1 ApparentRightAscension]
	    set RA2 [dict get $details2 ApparentRightAscension]
	    set RA3 [dict get $details3 ApparentRightAscension]

	    return [RiseTransitSet::TransitUT $JD $longitude $RA1 $RA2 $RA3]
	}

	proc RiseSetUT {type JD longitude latitude altitude} {
	    #set D1 [ApparentDeclination [expr {$JD - 1}]]
	    #set D2 [ApparentDeclination $JD]
	    #set D3 [ApparentDeclination [expr {$JD + 1}]]
	    #set RA1 [ApparentRightAscension [expr {$JD - 1}]]
	    #set RA2 [ApparentRightAscension $JD]
	    #set RA3 [ApparentRightAscension [expr {$JD + 1}]]

	    set details1 [Details [expr {$JD - 1}]]
	    set details2 [Details $JD]
	    set details3 [Details [expr {$JD + 1}]]

	    set D1 [dict get $details1 ApparentDeclination]
	    set D2 [dict get $details2 ApparentDeclination]
	    set D3 [dict get $details3 ApparentDeclination]
	    set RA1 [dict get $details1 ApparentRightAscension]
	    set RA2 [dict get $details2 ApparentRightAscension]
	    set RA3 [dict get $details3 ApparentRightAscension]

	    return [RiseTransitSet::RiseSetUT $type $JD $longitude $latitude $altitude $RA1 $RA2 $RA3 $D1 $D2 $D3]
	}
    }

    namespace eval Earth {

	#####################
	# Chapter 32
	# Appendix III
	# Position of Planets
	#####################

	namespace path [namespace parent]

	variable L0EarthCoefficients {
	    175347046.0 0.0       0.0
	    3341656.0   4.6692568 6283.0758500
	    34894.0     4.62610   12566.15170
	    3497.0      2.7441    5753.3849
	    3418.0      2.8289    3.5231
	    3136.0      3.6277    77713.7715
	    2676.0      4.4181    7860.4194
	    2343.0      6.1352    3930.2097
	    1324.0      0.7425    11506.7698
	    1273.0      2.0371    529.6910
	    1199.0      1.1096    1577.3435
	    990.0       5.233     5884.927
	    902.0       2.045     26.298
	    857.0       3.508     398.149
	    780.0       1.179     5223.694
	    753.0       2.533     5507.553
	    505.0       4.583     18849.228
	    492.0       4.205     775.523
	    357.0       2.920     0.067
	    317.0       5.849     11790.629
	    284.0       1.899     796.288
	    271.0       0.315     10977.079
	    243.0       0.345     5486.778
	    206.0       4.806     2544.314
	    205.0       1.869     5573.143
	    202.0       2.458     6069.777
	    156.0       0.833     213.299
	    132.0       3.411     2942.463
	    126.0       1.083     20.775
	    115.0       0.645     0.980
	    103.0       0.636     4694.003
	    102.0       0.976     15720.839
	    102.0       4.267     7.114
	    99.0        6.21      2146.17
	    98.0        0.68      155.42
	    86.0        5.98      161000.69
	    85.0        1.30      6275.96
	    85.0        3.67      71430.70
	    80.0        1.81      17260.15
	    79.0        3.04      12036.46
	    75.0        1.76      5088.63
	    74.0        3.50      3154.69
	    74.0        4.68      801.82
	    70.0        0.83      9437.76
	    62.0        3.98      8827.39
	    61.0        1.82      7084.90
	    57.0        2.78      6286.60
	    56.0        4.39      14143.50
	    56.0        3.47      6279.55
	    52.0        0.19      12139.55
	    52.0        1.33      1748.02
	    51.0        0.28      5856.48
	    49.0        0.49      1194.45
	    41.0        5.37      8429.24
	    41.0        2.40      19651.05
	    39.0        6.17      10447.39
	    37.0        6.04      10213.29
	    37.0        2.57      1059.38
	    36.0        1.71      2352.87
	    36.0        1.78      6812.77
	    33.0        0.59      17789.85
	    30.0        0.44      83996.85
	    30.0        2.74      1349.87
	    25.0        3.16      4690.48
	}

	variable L1EarthCoefficients {
	    628331966747.0 0.0      0.0
	    206059.0       2.678235 6283.075850
	    4303.0         2.6351   12566.1517
	    425.0          1.590    3.523
	    119.0          5.796    26.298
	    109.0          2.966    1577.344
	    93.0           2.59     18849.23
	    72.0           1.14     529.69
	    68.0           1.87     398.15
	    67.0           4.41     5507.55
	    59.0           2.89     5223.69
	    56.0           2.17     155.42
	    45.0           0.40     796.30
	    36.0           0.47     775.52
	    29.0           2.65     7.11
	    21.0           5.43     0.98
	    19.0           1.85     5486.78
	    19.0           4.97     213.30
	    17.0           2.99     6275.96
	    16.0           0.03     2544.31
	    16.0           1.43     2146.17
	    15.0           1.21     10977.08
	    12.0           2.83     1748.02
	    12.0           3.26     5088.63
	    12.0           5.27     1194.45
	    12.0           2.08     4694.00
	    11.0           0.77     553.57
	    10.0           1.30     6286.60
	    10.0           4.24     1349.87
	    9.0            2.70     242.73
	    9.0            5.64     951.72
	    8.0            5.30     2352.87
	    6.0            2.65     9437.76
	    6.0            4.67     4690.48
	}

	variable L2EarthCoefficients {
	    52919.0 0.0    0.0
	    8720.0  1.0721 6283.0758
	    309.0   0.867  12566.152
	    27.0    0.05   3.52
	    16.0    5.19   26.30
	    16.0    3.68   155.42
	    10.0    0.76   18849.23
	    9.0     2.06   77713.77
	    7.0     0.83   775.52
	    5.0     4.66   1577.34
	    4.0     1.03   7.11
	    4.0     3.44   5573.14
	    3.0     5.14   796.30
	    3.0     6.05   5507.55
	    3.0     1.19   242.73
	    3.0     6.12   529.69
	    3.0     0.31   398.15
	    3.0     2.28   553.57
	    2.0     4.38   5223.69
	    2.0     3.75   0.98
	}

	variable L3EarthCoefficients {
	    289.0 5.844 6283.076
	    35.0  0.0   0.0
	    17.0  5.49  12566.15
	    3.0   5.20  155.42
	    1.0   4.72  3.52
	    1.0   5.30  18849.23
	    1.0   5.97  242.73
	}

	variable L4EarthCoefficients {
	    114.0 3.142 0.0
	    8.0   4.13  6283.08
	    1.0   3.84  12566.15
	}

	variable L5EarthCoefficients {
	    1.0 3.14 0.0
	}

	variable B0EarthCoefficients {
	    280.0 3.199 84334.662
	    102.0 5.422 5507.553
	    80.0  3.88  5223.69
	    44.0  3.70  2352.87
	    32.0  4.00  1577.34
	}

	variable B1EarthCoefficients {
	    9.0 3.90 5507.55
	    6.0 1.73 5223.69
	}

	variable R0EarthCoefficients {
	    100013989.0 0.0       0.0
	    1670700.0   3.0984635 6283.0758500
	    13956.0     3.05525   12566.15170
	    3084.0      5.1985    77713.7715
	    1628.0      1.1739    5753.3849
	    1576.0      2.8469    7860.4194
	    925.0       5.453     11506.770
	    542.0       4.564     3930.210
	    472.0       3.661     5884.927
	    346.0       0.964     5507.553
	    329.0       5.900     5223.694
	    307.0       0.299     5573.143
	    243.0       4.273     11790.629
	    212.0       5.847     1577.344
	    186.0       5.022     10977.079
	    175.0       3.012     18849.228
	    110.0       5.055     5486.778
	    98.0        0.89      6069.78
	    86.0        5.69      15720.84
	    86.0        1.27      161000.69
	    65.0        0.27      17260.15
	    63.0        0.92      529.69
	    57.0        2.01      83996.85
	    56.0        5.24      71430.70
	    49.0        3.25      2544.31
	    47.0        2.58      775.52
	    45.0        5.54      9437.76
	    43.0        6.01      6275.96
	    39.0        5.36      4694.00
	    38.0        2.39      8827.39
	    37.0        0.83      19651.05
	    37.0        4.90      12139.55
	    36.0        1.67      12036.46
	    35.0        1.84      2942.46
	    33.0        0.24      7084.90
	    32.0        0.18      5088.63
	    32.0        1.78      398.15
	    28.0        1.21      6286.60
	    28.0        1.90      6279.55
	    26.0        4.59      10447.39
	}

	variable R1EarthCoefficients {
	    103019.0 1.107490 6283.075850
	    1721.0   1.0644   12566.1517
	    702.0    3.142    0.0
	    32.0     1.02     18849.23
	    31.0     2.84     5507.55
	    25.0     1.32     5223.69
	    18.0     1.42     1577.34
	    10.0     5.91     10977.08
	    9.0      1.42     6275.96
	    9.0      0.27     5486.78
	}

	variable R2EarthCoefficients {
	    4359.0 5.7846 6283.0758
	    124.0  5.579  12566.152
	    12.0   3.14   0.0
	    9.0    3.63   77713.77
	    6.0    1.87   5573.14
	    3.0    5.47   18849.23
	}

	variable R3EarthCoefficients {
	    145.0 4.273 6283.076
	    7.0   3.92  12566.15
	}

	variable R4EarthCoefficients {
	    4 2.56 6283.08
	}

	proc EclipticLongitude {JD} {
	    variable L0EarthCoefficients
	    variable L1EarthCoefficients
	    variable L2EarthCoefficients
	    variable L3EarthCoefficients
	    variable L4EarthCoefficients
	    variable L5EarthCoefficients

	    set tau [expr {($JD - 2451545.0) / 365250.0}]

	    set L0 0
	    foreach {A B C} $L0EarthCoefficients {
		set L0 [expr {$L0 + $A * cos($B + $C*$tau)}]
	    }

	    set L1 0
	    foreach {A B C} $L1EarthCoefficients {
		set L1 [expr {$L1 + $A * cos($B + $C*$tau)}]
	    }

	    set L2 0
	    foreach {A B C} $L2EarthCoefficients {
		set L2 [expr {$L2 + $A * cos($B + $C*$tau)}]
	    }

	    set L3 0
	    foreach {A B C} $L3EarthCoefficients {
		set L3 [expr {$L3 + $A * cos($B + $C*$tau)}]
	    }

	    set L4 0
	    foreach {A B C} $L4EarthCoefficients {
		set L4 [expr {$L4 + $A * cos($B + $C*$tau)}]
	    }

	    set L5 0
	    foreach {A B C} $L5EarthCoefficients {
		set L5 [expr {$L5 + $A * cos($B + $C*$tau)}]
	    }

	    set longitude [expr {($L0 + $L1*$tau + $L2*$tau**2 + $L3*$tau**3 + $L4*$tau**4 + $L5*$tau**5) / 100000000}]
	    return [normalize360 [toDegrees $longitude]]
	}

	proc EclipticLatitude {JD} {
	    variable B0EarthCoefficients
	    variable B1EarthCoefficients

	    set tau [expr {($JD - 2451545.0) / 365250.0}]

	    set B0 0
	    foreach {A B C} $B0EarthCoefficients {
		set B0 [expr {$B0 + $A * cos($B + $C*$tau)}]
	    }

	    set B1 0
	    foreach {A B C} $B1EarthCoefficients {
		set B1 [expr {$B1 + $A * cos($B + $C*$tau)}]
	    }

	    set latitude [expr {($B0 + $B1*$tau) / 100000000.0}]
	    return [toDegrees $latitude]
	}

	proc RadiusVector {JD} {
	    variable R0EarthCoefficients
	    variable R1EarthCoefficients
	    variable R2EarthCoefficients
	    variable R3EarthCoefficients
	    variable R4EarthCoefficients

	    set tau [expr {($JD - 2451545.0) / 365250.0}]

	    set R0 0
	    foreach {A B C} $R0EarthCoefficients {
		set R0 [expr {$R0 + $A * cos($B + $C*$tau)}]
	    }

	    set R1 0
	    foreach {A B C} $R1EarthCoefficients {
		set R1 [expr {$R1 + $A * cos($B + $C*$tau)}]
	    }

	    set R2 0
	    foreach {A B C} $R2EarthCoefficients {
		set R2 [expr {$R2 + $A * cos($B + $C*$tau)}]
	    }

	    set R3 0
	    foreach {A B C} $R3EarthCoefficients {
		set R3 [expr {$R3 + $A * cos($B + $C*$tau)}]
	    }

	    set R4 0
	    foreach {A B C} $R4EarthCoefficients {
		set R4 [expr {$R4 + $A * cos($B + $C*$tau)}]
	    }

	    set radius [expr {($R0 + $R1*$tau + $R2*$tau**2 + $R3*$tau**3 + $R4*$tau**4) / 100000000.0}]
	    return $radius
	}
    }

    namespace eval FK5 {

	#####################
	# Chapter 32
	# Position of Planets
	#####################

	namespace path [namespace parent]

	proc LongitudeCorrection {JD longitude latitude} {
	    set T [expr {($JD - 2451545.0) / 36525.0}]
	    set B [toRadians $latitude]
	    set Lp [toRadians [expr {$longitude - 1.397*$T - 0.00031*$T**2}]]

	    set deltaL [expr {-0.09033 + 0.03916 * (cos($Lp) + sin($Lp)) * tan($B)}]
	    return $deltaL ;# in arc seconds
	}

	proc LatitudeCorrection {JD longitude} {
	    set T [expr {($JD - 2451545.0) / 36525.0}]
	    set Lp [toRadians [expr {$longitude - 1.397*$T - 0.00031*$T**2}]]

	    set deltaB [expr {0.03916 * (cos($Lp) - sin($Lp))}]
	    return $deltaB ;# in arc seconds
	}
    }
}

# vim:syn=tcl:
