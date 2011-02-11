
namespace eval ::astronomica::math {

    variable math
    set math(pi) 3.1415926535897932384626433832795

    proc ::tcl::mathfunc::ifloor {n} {
	return [expr {int(floor($n))}]
    }
	
    # Convert degrees to radians
    proc toRadians {D} {
	variable math
	return [expr {$D * $math(pi) / 180.0}]
    }

    # Convert radians to degrees
    proc toDegrees {R} {
	variable math
	return [expr {$R * 180.0 / $math(pi)}]
    }

    # Normalize angle into range 0 <= a < 360
    proc normalize360 {a} {
	set w [expr {fmod($a,360.0)}]
	if {$w < 0.0} {
	    set w [expr {$w + 360.0}]
	}

	return $w
    }

    # Normalize angle into range -180 <= a < 180
    proc normalize180 {a} {
	set w [expr {fmod($a,360.0)}]
	if {abs($w) >= 180.0} {
	    set fix [expr {$a < 0.0 ? 360.0 : -360.0}]
	    set w [expr {$w + $fix}]
	}

	return $w
    }

    # Normalize hour into range 0 <= h < 24
    proc normalize24 {h} {
	set w [expr {fmod($h,24.0)}]
	if {$w < 0.0} {
	    set w [expr {$w + 24.0}]
	}

	return $w
    }
}
