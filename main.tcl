#!/bin/env tclsh

package require Tcl 8.5
package require starkit

switch -exact -- [starkit::startup] {
    sourced {return}

    unwrapped {
	starkit::autoextend [file normalize [file dirname [info script]]]
    }

    starkit -
    starpack {}

    default {}
}

package require app-maluach
