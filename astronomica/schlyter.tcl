
# Based on algorithms by Paul Schlyter
# http://stjarnhimlen.se/comp/riset.html
#
# Code ideas from:
# http://stjarnhimlen.se/comp/sunriset.c

namespace eval ::Astro::Schlyter {
    namespace export SunRiseUT SunSetUT SunTransitUT
    namespace import ::Astro::*

    proc SunRiseUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	set d [DaysSince2000 $year $month $day]
	return [SunRiseSet $astro(typeRise) $d $longitude $latitude $altitude]
    }

    proc SunSetUT {year month day longitude latitude {altitude ""}} {
	namespace upvar ::Astro astro astro

	set d [DaysSince2000 $year $month $day]
	return [SunRiseSet $astro(typeSet) $d $longitude $latitude $altitude]
    }

    proc SunTransitUT {year month day longitude} {
	namespace upvar ::Astro astro astro

	set d [DaysSince2000 $year $month $day]
	return [SunRiseSet $astro(typeTransit) $d $longitude "" ""]
    }

    proc DaysSince2000 {Y M D} {
	set d [expr {367*$Y - (7*($Y+(($M+9)/12)))/4 + (275*$M)/9 + $D - 730530}]
	return $d
    }

    # Computes the Sun's ecliptic longitude and distance
    # at an instant given in d, number of days since
    # 2000 Jan 0.0.  The Sun's ecliptic latitude is not
    # computed, since it's always very near 0.
    #
    # M		Mean anomaly of the Sun
    # w		Mean longitude of perihelion
    #		Note: Sun's mean longitude = M + w
    # e		Eccentricity of Earth's orbit
    # E		Eccentric anomaly
    # x, y,	x, y coordinates in orbit
    # v		True anomaly
    # r		Solar distance (radius)
    # lon	True solar longitude

    proc SunLongitude {d} {
	set M [toRadians [normalize360 [expr {356.047 + 0.9856002585 * $d}]]]
	set w [toRadians [expr {282.9404 + 4.70935e-5 * $d}]]
	set e [expr {0.016709 - 1.151e-9 * $d}]

	set E [expr {$M + $e*sin($M) * (1.0 + $e*cos($M))}]
	set x [expr {cos($E) - $e}]
	set y [expr {sqrt(1.0 - $e**2) * sin($E)}]
	set v [expr {atan2($y, $x)}]
	set lon [expr {$v + $w}]

	return [normalize360 [toDegrees $lon]] ;# in degrees
    }

    proc SunDistance {d} {
	set M [toRadians [normalize360 [expr {356.047 + 0.9856002585 * $d}]]]
	set e [expr {0.016709 - 1.151e-9 * $d}]

	set E [expr {$M + $e*sin($M) * (1.0 + $e*cos($M))}]
	set x [expr {cos($E) - $e}]
	set y [expr {sqrt(1.0 - $e**2) * sin($E)}]
	set r [expr {sqrt($x**2 + $y**2)}]

	return $r ;# in AU
    }

    proc SunRA {d} {
	# Compute Sun's ecliptic coordinates
	set lon [toRadians [SunLongitude $d]]
	set r [SunDistance $d]

	# Compute ecliptic rectangular coordinates (z=0)
	set x [expr {$r * cos($lon)}]
	set y [expr {$r * sin($lon)}]

	# Computer obliquity of ecliptic (inclination of Earth's axis)
	set o [toRadians [expr {23.4393 - 3.563e-7 * $d}]]

	# Convert to equatorial rectangular coordinates - x is unchanged
	set y [expr {$y * cos($o)}]
	set z [expr {$y * sin($o)}]

	# Convert to spherical coordinates
	set RA [expr {atan2($y, $x)}]
	return [normalize360 [toDegrees $RA]] ;# in degrees
    }

    proc SunDec {d} {
	# Compute Sun's ecliptic coordinates
	set lon [toRadians [SunLongitude $d]]
	set r [SunDistance $d]

	# Compute ecliptic rectangular coordinates (z=0)
	set x [expr {$r * cos($lon)}]
	set y [expr {$r * sin($lon)}]

	# Computer obliquity of ecliptic (inclination of Earth's axis)
	set o [toRadians [expr {23.4393 - 3.563e-7 * $d}]]

	# Convert to equatorial rectangular coordinates - x is unchanged
	set y [expr {$y * cos($o)}]
	set z [expr {$y * sin($o)}]

	# Convert to spherical coordinates
	set dec [expr {atan2($z, sqrt($x**2 + $y**2))}]
	return [toDegrees $dec] ;# in degrees
    }

    # Computes GMST0, the Greenwich Mean Sidereal Time at 0h UT
    # (i.e. the sidereal time at the Greenwhich meridian at 0h UT).
    # GMST is then the sidereal time at Greenwich at any time of
    # the day.  I've generalized GMST0 as well, and define it as:
    # GMST0 = GMST - UT  --  this allows GMST0 to be computed at
    # other times than 0h UT as well.  While this sounds somewhat
    # contradictory, it is very practical:  instead of computing
    # GMST like:
    #
    #  GMST = (GMST0) + UT * (366.2422/365.2422)
    #
    # where (GMST0) is the GMST last time UT was 0 hours, one simply
    # computes:
    #
    #  GMST = GMST0 + UT
    #
    # where GMST0 is the GMST "at 0h UT" but at the current moment!
    # Defined in this way, GMST0 will increase with about 4 min a
    # day.  It also happens that GMST0 (in degrees, 1 hr = 15 degr)
    # is equal to the Sun's mean longitude plus/minus 180 degrees!
    # (if we neglect aberration, which amounts to 20 seconds of arc
    # or 1.33 seconds of time)

    proc GMST0 {d} {
	# Sidtime at 0h UT = L (Sun's mean longitude) + 180.0 degr
	# L = M + w, as defined in sunpos().  Since I'm too lazy to
	# add these numbers, I'll let the C compiler do it for me.
	# Any decent C compiler will add the constants at compile
	# time, imposing no runtime or code overhead.

	set sidtim0 [expr {(180.0 + 356.047 + 282.9404) +
			   (0.9856002585 + 4.70935e-5) * $d}]

	return [normalize360 $sidtim0] ;# in degrees
    }

    proc SunRiseSet {type d lon lat {altit ""}} {
	namespace upvar ::Astro astro astro

	# Compute d of 12h local mean solar time
	set d [expr {$d + 0.5 + $lon/360.0}]

	# Compute local sidereal time of this moment
	set sidtime [normalize360 [expr {[GMST0 $d] + 180.0 - $lon}]]

	# Computer Sun's RA and Decl at this moment
	set sRA [SunRA $d]
	set sdec [SunDec $d]

	# Compute time when Sun is at south - in hours UT
	set tsouth [expr {12.0 - [normalize180 [expr {$sidtime - $sRA}]] / 15.0}]

	if {$type == $astro(typeTransit)} {
	    return [normalize24 $tsouth]
	}

	if {$altit eq ""} {
	    # Compute the Sun's apparent radius, degrees
	    set sr [SunDistance $d]
	    set sradius [expr {$astro(solarRadius) / $sr}]

	    set altit [expr {$astro(horizon) - $astro(refraction) - $sradius}]
	}

	# Compute the diurnal arc that the Sun traverses to reach
	# the specified altitude altit:
	set cost [expr {(sin([toRadians $altit]) - sin([toRadians $lat]) * sin([toRadians $sdec])) /
			(cos([toRadians $lat]) * cos([toRadians $sdec]))}]
	set t [toDegrees [expr {acos($cost)}]]

	# Calculate rise and set times - in hours UT
	set trise [expr {$tsouth - $t/15.0}]
	set tset [expr {$tsouth + $t/15.0}]

	if {$type == $astro(typeRise)} {
	    return $trise
	} elseif {$type == $astro(typeSet)} {
	    return $tset
	}

	return 0
    }
}

# vim:syn=tcl:
