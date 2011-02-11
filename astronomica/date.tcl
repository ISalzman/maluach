
namespace eval ::astronomica::date {

    ############
    # Chapter 7
    # Julian Day
    ############

    # Formula 7.1
    proc jd {y m d} {
	if {$m == 1 || $m == 2} {
	    set y [expr {$y - 1}]
	    set m [expr {$m + 12}]
	}

	set b 0
	if {[isGregorian $y $m $d]} {
	    set a [expr {ifloor($y / 100.0)}]
	    set b [expr {2 - $a + ifloor($a / 4.0)}]
	}

	set jd [expr {ifloor(365.25 * ($y + 4716))
		    + ifloor(30.6001 * ($m + 1))
		    + $d + $b - 1524.5}]

	return $jd
    }

    proc ymd {jd} {
	set z [expr {ifloor($jd + 0.5)}]
	set f [expr {$jd + 0.5 - $z}]

	set a $z
	if {$z >= 2299161} {
	    set alpha [expr {ifloor(($z - 1867216.25) / 36524.25)}]
	    set a [expr {$z + 1 + $alpha - ifloor($alpha / 4.0)}]
	}

	set b [expr {$a + 1524}]
	set c [expr {ifloor(($b - 122.1) / 365.25)}]
	set d [expr {ifloor(365.25 * $c)}]
	set e [expr {ifloor(($b - $d) / 30.6001)}]

	set day [expr {$b - $d - ifloor(30.6001 * $e) + $f}]
	set month [expr {$e < 14 ? $e - 1 : $e - 13}]
	set year [expr {$month > 2 ? $c - 4716 : $c - 4715}]

	return [list $year $month $day]
    }

    proc isGregorian {y m d} {
	return [expr {($y > 1582)
		    || (($y == 1582) && ($m >  10))
		    || (($y == 1582) && ($m == 10) && ($d >= 15))}]
    }

    proc isLeap {y} {
	# Handle Gregorian leap rules
	if {$y > 1582} {
	    if {($y % 100) == 0} {
		return [expr {($y % 400) == 0}]
	    }
	}

	return [expr {($y % 4) == 0}]
    }

    # Sunday is 0
    proc dayOfWeek {y m d} {
	set jd [jd $y $m $d]
	set wd [expr {ifloor($jd + 1.5) % 7}]

	return $wd
    }

    proc dayOfYear {y m d} {
	set k [expr {[isLeap $y] ? 1 : 2}]
	set n [expr {ifloor(275 * $m / 9) - $k * ifloor(($m + 9) / 12) + $d - 30}]

	return $n
    }
}
