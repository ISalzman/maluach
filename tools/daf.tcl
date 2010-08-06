#!/bin/env tclsh

package require Tcl 8.5

set topdir [file dirname [file dirname [file normalize [info script]]]]
lappend ::auto_path $topdir

package require csv
package require DafYomi
DafYomi::Init he

set header [list \
    Sunday \
    Saturday \
    Daf0 \
    Daf1 \
    Daf2 \
    Daf3 \
    Daf4 \
    Daf5 \
    Daf6 \
    Daf7 \
]

set beg "09/05/2010"
set end "10/22/2011"

if {[clock format [clock scan $beg -format "%m/%d/%Y"] -format "%w"] != 0} {
        return -code error "Start date must be a Sunday."
}
if {[clock format [clock scan $end -format "%m/%d/%Y"] -format "%w"] != 6} {
        return -code error "Start date must be a Saturday."
}

set daflist [list]
set maslist [list]
set day [clock scan $beg -format %D]

puts stdout [csv::join $header]
flush stdout

while {$day <= [clock scan $end -format %D]} {
    set yomi [DafYomi::Daf {*}[clock format $day -format "%Y %N %e"]]
    set daf [lindex [split $yomi] end]
    set mas [lrange [split $yomi] 0 end-1]

    lappend daflist $daf
    if {$mas ni $maslist} {
	lappend maslist $mas
    }

    if {[clock format $day -format "%a"] eq "Sat"} {
	set datelist [list [string map {" " ""} [clock format [clock add $day -6 days] -format "%N/%e/%Y"]]]
	lappend datelist [string map {" " ""} [clock format $day -format "%N/%e/%Y"]]

	puts stdout [csv::join [list {*}$datelist [join $maslist -] {*}$daflist]]
	flush stdout

	set maslist [list]
	set daflist [list]
    }

    set day [clock add $day 1 days]
}

exit 0
