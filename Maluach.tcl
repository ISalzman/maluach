package provide app-maluach 1.0

namespace eval ::Maluach {

    proc Init {} {
	set appdir [file normalize [file dirname [info script]]]

	package require snit
	package require Astro
	package require Zmanim
	package require DafYomi

	source [file join $appdir Date.tcl]
	source [file join $appdir Location.tcl]
	source [file join $appdir Calendar.tcl]

	Astro::Init
	Zmanim::Init
	DafYomi::Init

	#Astro::SetCalc Meeus
	#DafYomi::SetLocale he

	return
    }
}

::Maluach::Init
