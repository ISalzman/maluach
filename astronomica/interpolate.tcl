
namespace eval ::astronomica::interpolate {

    ###############
    # Chapter 3
    # Interpolation
    ###############

    # Formula 3.3
    proc interpolate3 {y1 y2 y3 n} {
	set a [expr {$y2 - $y1}]
	set b [expr {$y3 - $y2}]
	set c [expr {$y1 + $y3 - 2*$y2}]

	return [expr {$y2 + ($n / 2.0) * ($a + $b + $n * $c)}]
    }

    # Formula 3.8
    proc interpolate5 {y1 y2 y3 y4 y5 n} {
	set a [expr {$y2 - $y1}]
	set b [expr {$y3 - $y2}]
	set c [expr {$y4 - $y3}]
	set d [expr {$y5 - $y4}]
	set e [expr {$y1 + $y3 - 2*$y2}]
	set f [expr {$y2 + $y4 - 2*$y3}]
	set g [expr {$y3 + $y5 - 2*$y4}]
	set h [expr {$y4 - $y1 + 3*$y2 - 3*$y3}]
	set j [expr {$y5 - $y2 + 3*$y3 - 3*$y4}]
	set k [expr {$y1 - 4*$y2 + 6*$y3 - 4*$y4 + $y5}]

	return [expr {$y3 + (($b+$c)/2.0 - ($h+$j)/12.0)*$n + ($f/2.0 - $k/24.0)*$n**2 + (($h+$j)/12.0)*$n**3 + ($k/24.0)*$n**4}]
    }
}
