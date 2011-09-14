#!/bin/env tclsh

set topdir [file dirname [file dirname [file normalize [info script]]]]
lappend ::auto_path $topdir
::tcl::tm::roots [list $topdir]

package require Tcl 8.5
package require astronomica
package require dafyomi
package require zmanim
package require snit
package require csv

source [file join $topdir date.tcl]
source [file join $topdir location.tcl]
source [file join $topdir calendar.tcl]

proc timeCompare {time1 time2} {
    set timeval1 [clock scan $time1 -format "%H:%M"]
    set timeval2 [clock scan $time2 -format "%H:%M"]

    if {$timeval1 < $timeval2} {
	return -1
    } elseif {$timeval1 > $timeval2} {
	return 1
    } else {
	return 0
    }
}

proc header {} {
    set header [list]
    set zerolist [list \
	ShemaMD ShemaM ShemaG \
	TefilaMD TefilaM TefilaG \
    ]
    set columns [list \
	ZmanisG ZmanisM \
	AlosD Alos \
	Tallis115D Tallis11D TallisD Tallis \
	Hanetz \
	ShemaMD ShemaM ShemaG \
	TefilaMD TefilaM TefilaG \
	Chatzos \
	GedolaG GedolaS GedolaM \
	KetanaG KetanaM \
	PlagG PlagM \
	Neiros \
	Shekia \
	TzeisD Tzeis Tam TamD \
    ]

    lappend header Sunday Saturday

    foreach col $columns {
	set start 1
	if {$col in $zerolist} {
	    set start 0
	}

	for {set dow $start} {$dow <= 7} {incr dow} {
	    lappend header ${col}${dow}
	}
    }

    lappend header Community Coords
    return $header
}

### MAIN ###

#dafyomi::locale he

set zmanNameList [list \
    shaahZmanisGRA \
    shaahZmanisMA72 \
    alos16.1 \
    alos72 \
    misheyakir11.5 \
    misheyakir11.0 \
    misheyakir10.2 \
    misheyakir45 \
    hanetz \
    sofZmanShemaMA16.1 \
    sofZmanShemaMA72 \
    sofZmanShemaGRA \
    sofZmanTefilahMA16.1 \
    sofZmanTefilahMA72 \
    sofZmanTefilahGRA \
    chatzos \
    minchahGedolahGRA \
    minchahGedolahS \
    minchahGedolahMA72 \
    minchahKetanahGRA \
    minchahKetanahMA72 \
    plagHaminchahGRA \
    plagHaminchahMA72 \
    neiros18 \
    shekiah \
    tzeis8.5 \
    tzeis45 \
    tzeis72 \
    tzeis16.1 \
]

#set beg "10/11/2009"
#set end "10/02/2010"
#set beg "09/05/2010"
#set end "10/22/2011"
set beg "10/16/2011"
set end "10/13/2012"

# List of extra Neiros dates
# for Erev Yom Tov
set neiroslist [list]
set neirosdates [list \
    10/19/2011 \
    04/12/2012 \
    09/16/2012 \
    09/25/2012 \
    09/30/2012 \
    10/07/2012
]
foreach neirosdate $neirosdates {
    lappend neiroslist [clock scan $neirosdate -format "%m/%d/%Y"]
}

if {[clock format [clock scan $beg -format "%m/%d/%Y"] -format "%w"] != 0} {
    return -code error "Start date must be a Sunday."
}
if {[clock format [clock scan $end -format "%m/%d/%Y"] -format "%w"] != 6} {
    return -code error "End date must be a Saturday."
}

set loc [Location create %AUTO% \
    -name "Beverly / La Brea" \
    -latitude "34 4 34 N" \
    -longitude "118 20 39 W" \
    -timezone ":America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "Pico / Robertson" \
    -latitude "34 3 17 N" \
    -longitude "118 23 1 W" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "City of Hope" \
    -latitude "34 7 46 N" \
    -longitude "117 58 15 W" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "Valley Village" \
    -latitude "34 9 54 N" \
    -longitude "118 23 47 W" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "Taft Correctional Institution" \
    -latitude "35 6 42 N" \
    -longitude "119 23 8 W" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "Manning Beef" \
    -latitude "34 0 19 N" \
    -longitude "118 4 18 W" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "WorldMark Indio" \
    -latitude "33 44 36 N" \
    -longitude "116 11 13 W" \
    -timezone ":America/Los_Angeles" \
]

set day [Date create %AUTO% [clock scan $beg -format "%m/%d/%Y"]]
set cal [Calendar create %AUTO% -date $day -location $loc]

puts stdout [csv::join [header]]
flush stdout

while {[$day timeval] <= [clock scan $end -format "%m/%d/%Y"]} {
    set week [list]

    # :TODO: Add Parsha

    # English dates
    lappend week [string map {" " ""} [$day format "%N/%e/%Y"]]
    lappend week [string map {" " ""} [clock format [$day add 6 days] -format "%N/%e/%Y"]]

    # :TODO: Add Hebrew dates

    # :TODO: Add Daf Yomi

    foreach zmanName $zmanNameList {
	set zmanlist [list]

	for {set dow 1} {$dow <= 7} {incr dow} {
	    ;# Only generate Neiros for Friday and Erev Yom Tov
	    if {$zmanName eq "neiros18" && $dow != 6 && [$day timeval] ni $neiroslist} {
		lappend zmanlist {}
	    } elseif {$zmanName eq "minchahGedolahS"} {
		lappend zmanlist [$cal zman minchahGedolahGRA strict]
	    } else {
		lappend zmanlist [$cal zman $zmanName]
	    }

	    $day incr 1 days
	}

	;# Calculate minimum for sofZman*
	if {[string match sofZman* $zmanName]} {
	    set min [lindex [lsort -increasing -command timeCompare $zmanlist] 0]
	    set zmanlist [concat $min $zmanlist]
	}

	lappend week {*}$zmanlist
	$day incr -7 days
    }

    lappend week [$loc cget -name]
    lappend week "[$loc getLatitudeDMS], [$loc getLongitudeDMS]"

    puts stdout [csv::join $week]
    flush stdout

    $day incr 7 days
}

exit 0

