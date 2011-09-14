#!/bin/env tclsh

set topdir [file dirname [file dirname [file normalize [info script]]]]
lappend ::auto_path $topdir
::tcl::tm::roots [list $topdir]

package require Tcl 8.5
package require csv
package require snit
package require dafyomi

source [file join $topdir Date.tcl]
source [file join $topdir Location.tcl]
source [file join $topdir Calendar.tcl]

proc header {} {
    set header [list]

    lappend header Sunday Saturday

    for {set dow 0} {$dow <= 7} {incr dow} {
	lappend header Daf${dow}
    }

    return $header
}

### MAIN ###

dafyomi::locale he

#set beg "09/05/2010"
#set end "10/22/2011"
set beg "10/16/2011"
set end "10/13/2012"

if {[clock format [clock scan $beg -format "%m/%d/%Y"] -format "%w"] != 0} {
        return -code error "Start date must be a Sunday."
}
if {[clock format [clock scan $end -format "%m/%d/%Y"] -format "%w"] != 6} {
        return -code error "End date must be a Saturday."
}

set day [Date create %AUTO% [clock scan $beg -format "%m/%d/%Y"]]
set cal [Calendar create %AUTO% -date $day]

puts stdout [csv::join [header]]
flush stdout

while {[$day timeval] <= [clock scan $end -format "%m/%d/%Y"]} {
    set week [list]
    set daflist [list]
    set maslist [list]

    lappend week [string map {" " ""} [$day format "%N/%e/%Y"]]
    lappend week [string map {" " ""} [clock format [$day add 6 days] -format "%N/%e/%Y"]]

    for {set dow 1} {$dow <= 7} {incr dow} {
	set yomi [$cal dafyomi]
	set daf [lindex [split $yomi] end]
	set mas [lrange [split $yomi] 0 end-1]

	lappend daflist $daf
	if {$mas ni $maslist} {
	    lappend maslist $mas
	}

	$day incr 1 days
    }

    lappend week [join $maslist -] {*}$daflist

    puts stdout [csv::join $week]
    flush stdout
}

exit 0
