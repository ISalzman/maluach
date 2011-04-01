if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded zmanim 1.0 [list apply {dir {
	uplevel #0 [list source [file join $dir zmanim.tcl]]
	uplevel #0 [list source [file join $dir cache.tcl]]
	package provide zmanim 1.0
    }} $dir]
