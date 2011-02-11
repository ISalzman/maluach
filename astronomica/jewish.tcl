
namespace eval ::astronomica::jewish {
    namespace path [namespace parent]

    #################
    # Chapter 9
    # Jewish Calendar
    #################

    # Date of Pesach in civil year y
    proc pesach {y} {
	set c [expr {ifloor($y / 100.0)}]
	set s [expr {$y < 1583 ? 0 : ifloor((3 * $c - 5) / 4.0)}]

	set a [expr {(12 * $y + 12) % 19}]
	set b [expr {$y % 4}]
	set q [expr {-1.904412361576 + 1.554241796621 * $a
		    + 0.25 * $b - 0.003177794022 * $y + $s}]
	set iq [expr {ifloor($q)}]

	set j [expr {($iq + 3 * $y + 5 * $b + 2 - $s) % 7}]
	set r [expr {$q - $iq}]

	if {($j == 2) || ($j == 4) || ($j == 6)} {
	    set d [expr {$iq + 23}]
	} elseif {($j == 1) && ($a > 6) && ($r >= 0.632870370)} {
	    set d [expr {$iq + 24}]
	} elseif {($j == 0) && ($a > 11) && ($r >= 0.897723765)} {
	    set d [expr {$iq + 23}]
	} else {
	    set d [expr {$iq + 22}]
	}

	set m 3
	if {$d > 31} {
	    set m 4
	    set d [expr {$d - 31}]
	}

	return [list $m $d]
    }

    # Date of Rosh Hashana in civil year y
    proc roshHashanah {y} {
	set p [pesach $y]
	set pjd [date::jd $y {*}$p]
	set rjd [expr {$pjd + 163}]
	lassign [date::ymd $rjd] y m d

	return [list $m [expr {int($d)}]]
    }

    # Convert civil to jewish year
    proc year {y} {
	# At Rosh Hashanah
	return [expr {$y + 3761}]
    }

    proc isLeap {y} {
	return [expr {($y % 19) in {0 3 6 8 11 14 17}}]
    }

    # Number of days in jewish year y
    proc days {y} {
	set c [expr {$y - 3761}]
	set rh [roshHashanah $c]
	set jd0 [date::jd $c {*}$rh]

	incr c
	set rh [roshHashanah $c]
	set jd1 [date::jd $c {*}$rh]

	return [expr {$jd1 - $jd0}]
    }
}
