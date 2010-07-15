#!/bin/env tclsh

package require starkit

if {[starkit::startup] eq "sourced"} {return}
if {[starkit::startup] eq "unwrapped"} {
    lappend ::auto_path [file normalize .]
}

package require app-maluach
