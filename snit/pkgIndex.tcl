if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded snit 2.3.2 [list source [file join $dir snit2.tcl]]
