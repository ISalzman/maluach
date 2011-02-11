if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded astronomica 1.0 [list apply {dir {
	uplevel #0 [list source [file join $dir astronomica.tcl]]
	uplevel #0 [list source [file join $dir aberration.tcl]]
	uplevel #0 [list source [file join $dir date.tcl]]
	uplevel #0 [list source [file join $dir deltat.tcl]]
	uplevel #0 [list source [file join $dir earth.tcl]]
	uplevel #0 [list source [file join $dir elliptical.tcl]]
	uplevel #0 [list source [file join $dir fk5.tcl]]
	uplevel #0 [list source [file join $dir interpolate.tcl]]
	uplevel #0 [list source [file join $dir jewish.tcl]]
	uplevel #0 [list source [file join $dir math.tcl]]
	uplevel #0 [list source [file join $dir nutation.tcl]]
	uplevel #0 [list source [file join $dir riseset.tcl]]
	uplevel #0 [list source [file join $dir sidereal.tcl]]
	uplevel #0 [list source [file join $dir sun.tcl]]
	uplevel #0 [list source [file join $dir transform.tcl]]
	package provide astronomica 1.0
    }} $dir]
