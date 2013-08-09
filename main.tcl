#!/bin/env tclsh

package require Tcl 8.5
package require starkit

::starkit::startup

switch -exact -- $::starkit::mode {
    sourced {return}
    starkit {::tcl::tm::roots [list [file join $::starkit::topdir lib]]}
    starpack {}

    unwrapped {
	::starkit::autoextend $::starkit::topdir
        ::tcl::tm::roots [list $::starkit::topdir]
    }


    default {return}
}

package require maluach
::maluach::main $::argv

exit 0
