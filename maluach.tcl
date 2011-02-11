
package require snit
package require Astro
package require Zmanim
package require DafYomi

package provide app-maluach 1.0

namespace eval ::Maluach {
    variable library [file dirname [file normalize [info script]]]

    proc Init {} {
	variable library

	source [file join $library Date.tcl]
	source [file join $library Location.tcl]
	source [file join $library Calendar.tcl]

	Astro::Init
	Zmanim::Init
	DafYomi::Init

	#Astro::SetCalc Meeus
	#DafYomi::SetLocale he

	return
    }

    proc Main {} {
	Init

	return
    }
}

