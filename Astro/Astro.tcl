
package require Tcl 8.5
package provide Astro 1.0

namespace eval ::Astro {
    variable library [file dirname [info script]]

    namespace export toRadians toDegrees normalize360 normalize180 normalize24

    proc Init {{calc ""}} {
	variable astro

	set astro(pi) 3.1415926535897932384626433832795
	set astro(degPerHour) [expr {360.0 / 24.0}]
	set astro(refraction) [expr {34.0 / 60.0}] ;# in degrees
	set astro(solarRadius) [expr {16.0 / 60.0}] ;# in degrees
	set astro(lighttime) 0.0057755183 ;# days / AU
	set astro(horizon) 0.0 ;# in degrees
	set astro(tolerance) [expr {1.0 / 86400.0}] ;# within .5 seconds

	set astro(typeRise) 0
	set astro(typeSet) 1
	set astro(typeTransit) 2

	set astro(calcns) ""
	if {$calc eq ""} {
	    set calc "Meeus"
	}

	return [SetCalc $calc]
    }

    proc SetCalc {{calc ""}} {
	variable astro
	variable library

	if {$calc ne ""} {
	    set calcfile [file join $library calcs ${calc}.calc]

	    if {[file exists $calcfile]} {
		uplevel #0 [list ::source $calcfile]
		set astro(calcns) $calc
	    }
	}

	return $astro(calcns)
    }

    proc CalcList {} {
	variable astro
	variable library

	set calclist [list]
	set calcdir [file join $library calcs]
	set filelist [glob -nocomplain -tails -directory $calcdir *.calc]

	foreach file $filelist {
	    lappend calclist [file rootname $file]
	}

	return [lsort $calclist]
    }

    proc SunRiseUT {args} {
	variable astro
	return [$astro(calcns)::SunRiseUT {*}$args]
    }

    proc SunSetUT {args} {
	variable astro
	return [$astro(calcns)::SunSetUT {*}$args]
    }

    proc SunTransitUT {args} {
	variable astro
	return [$astro(calcns)::SunTransitUT {*}$args]
    }

    # Convert degrees to radians
    proc toRadians {D} {
	variable astro

	set R [expr {$D * $astro(pi) / 180.0}]
	return $R
    }

    # Convert radians to degrees
    proc toDegrees {R} {
	variable astro

	set D [expr {$R * 180.0 / $astro(pi)}]
	return $D
    }

    # Normalize angle into range 0 <= a < 360
    proc normalize360 {a} {
	set w [expr {fmod($a, 360.0)}]
	if {$w < 0.0} {
	    set w [expr {$w + 360.0}]
	}

	return $w
    }

    # Normalize angle into range -180 <= a < 180
    proc normalize180 {a} {
	set w [expr {fmod($a, 360.0)}]
	if {abs($w) >= 180.0} {
	    set fix [expr {$a < 0.0 ? 360.0 : -360.0}]
	    set w [expr {$w + $fix}]
	}

	return $w
    }

    # Normalize hour into range 0 <= h < 24
    proc normalize24 {h} {
	set w [expr {fmod($h, 24.0)}]
	if {$w < 0.0} {
	    set w [expr {$w + 24.0}]
	}

	return $w
    }
}

