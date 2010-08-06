#!/bin/env tclsh

package require Tcl 8.5

set appdir [file normalize [file dirname [info script]]]
lappend ::auto_path $appdir

package require DafYomi
DafYomi::Init he

set beg "09/26/2010"
set end "10/22/2011"

set daflist [list]
set maslist [list]
set day [clock scan $beg -format %D]

while {$day <= [clock scan $end -format %D]} {
    set yomi [DafYomi::Daf {*}[clock format $day -format "%Y %N %e"]]
    set daf [lindex [split $yomi] end]
    set mas [lrange [split $yomi] 0 end-1]

    lappend daflist $daf
    if {$mas ni $maslist} {
	lappend maslist $mas
    }

    if {[clock format $day -format "%a"] eq "Sat"} {
	puts "[join $maslist -],[join $daflist ,]"
	set maslist [list]
	set daflist [list]
    }

    set day [clock add $day 1 days]
}

exit 0
