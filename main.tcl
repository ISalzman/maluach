#!/bin/env tclsh

package require Tcl 8.5
package require starkit

switch -exact -- [starkit::startup] {
    sourced {return}

    unwrapped {
	starkit::autoextend $::starkit::topdir
        ::tcl::tm::roots [list $::starkit::topdir]
    }

    starkit {
        ::tcl::tm::roots [list [file join $::starkit::topdir lib]]
    }

    starpack {}

    default {}
}

package require maluach
::maluach::main $::argv

exit 0
