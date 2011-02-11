
package require Tcl 8.5
package require Tk 8.5
package require astronomica
package require dafyomi
package require zmanim
package require snit
package require csv
package provide maluach 1.0

namespace eval ::maluach {
    variable library [file dirname [file normalize [info script]]]

    proc main {args} {
	#dafyomi::locale he

	return
    }
}

