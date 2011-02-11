if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded dafyomi 1.0 [list apply {dir {
	uplevel #0 [list source [file join $dir dafyomi.tcl]]
	package provide dafyomi 1.0
    }} $dir]
