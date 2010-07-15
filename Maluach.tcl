package require Tcl 8.5
package provide app-maluach 1.0

namespace eval ::Maluach {

    proc Init {} {
	package require Astro

	Astro::Init
	Astro::CalcSet Meeus

	return
    }
}

::Maluach::Init
