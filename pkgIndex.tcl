if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded maluach 1.0 [list apply {dir {
	uplevel #0 [list source [file join $dir maluach.tcl]]
	uplevel #0 [list source [file join $dir date.tcl]]
	uplevel #0 [list source [file join $dir calendar.tcl]]
	uplevel #0 [list source [file join $dir location.tcl]]
	package provide maluach 1.0
    }} $dir]
