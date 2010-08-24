#!/bin/env tclsh

package require Tcl 8.5

proc Init {} {
    set topdir [file dirname [file dirname [file normalize [info script]]]]
    lappend ::auto_path $topdir

    package require csv
    package require snit
    package require Astro
    package require Zmanim
    package require DafYomi

    source [file join $topdir Date.tcl]
    source [file join $topdir Location.tcl]
    source [file join $topdir Calendar.tcl]

    Astro::Init
    Zmanim::Init
    DafYomi::Init

    #Astro::SetCalc Meeus
    #DafYomi::SetLocale he

    return
}

proc TimeCompare {time1 time2} {
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

proc Header {} {
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

Init

set zmanNameList [list \
    ShaahZmanisGRA \
    ShaahZmanisMA72 \
    Alos16.1 \
    Alos72 \
    Misheyakir11.5 \
    Misheyakir11.0 \
    Misheyakir10.2 \
    Misheyakir45 \
    Hanetz \
    SofZmanShemaMA16.1 \
    SofZmanShemaMA72 \
    SofZmanShemaGRA \
    SofZmanTefilahMA16.1 \
    SofZmanTefilahMA72 \
    SofZmanTefilahGRA \
    Chatzos \
    MinchahGedolahGRA \
    MinchahGedolahS \
    MinchahGedolahMA72 \
    MinchahKetanahGRA \
    MinchahKetanahMA72 \
    PlagHaminchahGRA \
    PlagHaminchahMA72 \
    Neiros18 \
    Shekiah \
    Tzeis8.5 \
    Tzeis45 \
    Tzeis72 \
    Tzeis16.1 \
]

#set beg "10/11/2009"
#set end "10/02/2010"
set beg "09/05/2010"
set end "10/22/2011"

# List of extra Neiros dates
# for Erev Yom Tov
set neiroslist [list]
set neirosdates [list \
    09/08/2010 \
    09/22/2010 \
    09/29/2010 \
    04/18/2011 \
    04/24/2011 \
    06/07/2011 \
    09/28/2011 \
    10/12/2011 \
    10/19/2011 \
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
    -name "La Brea / Beverly" \
    -latitude "34 4 34 N" \
    -longitude "118 20 39 W" \
    -timezone "America/Los_Angeles" \
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

set day [Date create %AUTO% [clock scan $beg -format "%m/%d/%Y"]]
set cal [Calendar create %AUTO% -date $day -location $loc]

puts stdout [csv::join [Header]]
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
	    if {$zmanName eq "Neiros18" && $dow != 6 && [$day timeval] ni $neiroslist} {
		lappend zmanlist {}
	    } elseif {$zmanName eq "MinchahGedolahS"} {
		lappend zmanlist [$cal zman MinchahGedolahGRA strict]
	    } else {
		lappend zmanlist [$cal zman $zmanName]
	    }

	    $day incr 1 days
	}

	;# Calculate minimum for SofZman*
	if {[string match SofZman* $zmanName]} {
	    set min [lindex [lsort -increasing -command TimeCompare $zmanlist] 0]
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

