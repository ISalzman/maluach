package provide app-maluach 1.0

namespace eval ::Maluach {

    proc Init {} {
	package require Astro

	Astro::Init
	Astro::SetCalc Meeus

	return
    }
}

::Maluach::Init
