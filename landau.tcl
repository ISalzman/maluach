#!/bin/env tclsh

package require Tcl 8.5

proc Init {} {
    set appdir [file normalize [file dirname [info script]]]
    lappend ::auto_path $appdir

    package require csv
    package require snit
    package require Astro
    package require DafYomi
    package require Zmanim

    source [file join $appdir Date.tcl]
    source [file join $appdir Location.tcl]
    source [file join $appdir Calendar.tcl]

    Astro::Init
    Zmanim::Init
    DafYomi::Init
    #Astro::SetCalc Meeus

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

Init

set header [list \
    Sunday \
    Saturday \
    ZmanisG1 \
    ZmanisG2 \
    ZmanisG3 \
    ZmanisG4 \
    ZmanisG5 \
    ZmanisG6 \
    ZmanisG7 \
    ZmanisM1 \
    ZmanisM2 \
    ZmanisM3 \
    ZmanisM4 \
    ZmanisM5 \
    ZmanisM6 \
    ZmanisM7 \
    AlosD1 \
    AlosD2 \
    AlosD3 \
    AlosD4 \
    AlosD5 \
    AlosD6 \
    AlosD7 \
    Alos1 \
    Alos2 \
    Alos3 \
    Alos4 \
    Alos5 \
    Alos6 \
    Alos7 \
    Tallis11D1 \
    Tallis11D2 \
    Tallis11D3 \
    Tallis11D4 \
    Tallis11D5 \
    Tallis11D6 \
    Tallis11D7 \
    TallisD1 \
    TallisD2 \
    TallisD3 \
    TallisD4 \
    TallisD5 \
    TallisD6 \
    TallisD7 \
    Tallis1 \
    Tallis2 \
    Tallis3 \
    Tallis4 \
    Tallis5 \
    Tallis6 \
    Tallis7 \
    Hanetz1 \
    Hanetz2 \
    Hanetz3 \
    Hanetz4 \
    Hanetz5 \
    Hanetz6 \
    Hanetz7 \
    ShemaMD0 \
    ShemaMD1 \
    ShemaMD2 \
    ShemaMD3 \
    ShemaMD4 \
    ShemaMD5 \
    ShemaMD6 \
    ShemaMD7 \
    ShemaM0 \
    ShemaM1 \
    ShemaM2 \
    ShemaM3 \
    ShemaM4 \
    ShemaM5 \
    ShemaM6 \
    ShemaM7 \
    ShemaG0 \
    ShemaG1 \
    ShemaG2 \
    ShemaG3 \
    ShemaG4 \
    ShemaG5 \
    ShemaG6 \
    ShemaG7 \
    TefilaMD0 \
    TefilaMD1 \
    TefilaMD2 \
    TefilaMD3 \
    TefilaMD4 \
    TefilaMD5 \
    TefilaMD6 \
    TefilaMD7 \
    TefilaM0 \
    TefilaM1 \
    TefilaM2 \
    TefilaM3 \
    TefilaM4 \
    TefilaM5 \
    TefilaM6 \
    TefilaM7 \
    TefilaG0 \
    TefilaG1 \
    TefilaG2 \
    TefilaG3 \
    TefilaG4 \
    TefilaG5 \
    TefilaG6 \
    TefilaG7 \
    Chatzos1 \
    Chatzos2 \
    Chatzos3 \
    Chatzos4 \
    Chatzos5 \
    Chatzos6 \
    Chatzos7 \
    GedolaG1 \
    GedolaG2 \
    GedolaG3 \
    GedolaG4 \
    GedolaG5 \
    GedolaG6 \
    GedolaG7 \
    GedolaS1 \
    GedolaS2 \
    GedolaS3 \
    GedolaS4 \
    GedolaS5 \
    GedolaS6 \
    GedolaS7 \
    GedolaM1 \
    GedolaM2 \
    GedolaM3 \
    GedolaM4 \
    GedolaM5 \
    GedolaM6 \
    GedolaM7 \
    KetanaG1 \
    KetanaG2 \
    KetanaG3 \
    KetanaG4 \
    KetanaG5 \
    KetanaG6 \
    KetanaG7 \
    KetanaM1 \
    KetanaM2 \
    KetanaM3 \
    KetanaM4 \
    KetanaM5 \
    KetanaM6 \
    KetanaM7 \
    PlagG1 \
    PlagG2 \
    PlagG3 \
    PlagG4 \
    PlagG5 \
    PlagG6 \
    PlagG7 \
    PlagM1 \
    PlagM2 \
    PlagM3 \
    PlagM4 \
    PlagM5 \
    PlagM6 \
    PlagM7 \
    Neiros1 \
    Neiros2 \
    Neiros3 \
    Neiros4 \
    Neiros5 \
    Neiros6 \
    Neiros7 \
    Shekia1 \
    Shekia2 \
    Shekia3 \
    Shekia4 \
    Shekia5 \
    Shekia6 \
    Shekia7 \
    TzeisD1 \
    TzeisD2 \
    TzeisD3 \
    TzeisD4 \
    TzeisD5 \
    TzeisD6 \
    TzeisD7 \
    Tzeis1 \
    Tzeis2 \
    Tzeis3 \
    Tzeis4 \
    Tzeis5 \
    Tzeis6 \
    Tzeis7 \
    Tam1 \
    Tam2 \
    Tam3 \
    Tam4 \
    Tam5 \
    Tam6 \
    Tam7 \
    TamD1 \
    TamD2 \
    TamD3 \
    TamD4 \
    TamD5 \
    TamD6 \
    TamD7 \
    Community \
    Coords \
]

set zmanNameList [list \
    ShaahZmanisGRA \
    ShaahZmanisMA72 \
    Alos16.1 \
    Alos72 \
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
set beg "09/26/2010"
set end "10/22/2011"

set neiroslist [list]
set neirosdates [list \
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
    return -code error "Start date must be a Saturday."
}

set loc [Location create %AUTO% \
    -name "La Brea / Beverly" \
    -longitude "118 20 39 W" \
    -latitude "34 4 34 N" \
    -timezone "America/Los_Angeles" \
]

#set loc [Location create %AUTO% \
    -name "Pico / Robertson" \
    -longitude "118 23 1 W" \
    -latitude "34 3 17 N" \
    -timezone "America/Los_Angeles" \
]

set day [Date create %AUTO% [clock scan $beg -format "%m/%d/%Y"]]
set cal [Calendar create %AUTO% -date $day -location $loc]

puts stdout [csv::join $header]
flush stdout

while {[$day timeval] <= [clock scan $end -format "%m/%d/%Y"]} {
    set week [list]
    lappend week [string map {" " ""} [$day format "%N/%e/%Y"]]
    lappend week [string map {" " ""} [clock format [clock add [$day timeval] 6 days] -format "%N/%e/%Y"]]

    foreach zmanName $zmanNameList {
	set zmanlist [list]

	for {set dow 1} {$dow <= 7} {incr dow} {
	    ;# Only generate Neiros for Friday and Erev Yom Tov
	    if {$zmanName eq "Neiros18" && $dow != 6 && [$day timeval] ni $neiroslist} {
		lappend zmanlist {}
	    } else {
		lappend zmanlist [$cal zman $zmanName]
	    }

	    $day add 1 days
	}

	;# Calculate minimum for SofZman*
	if {[string match SofZman* $zmanName]} {
	    set min [lindex [lsort -increasing -command TimeCompare $zmanlist] 0]
	    set zmanlist [concat $min $zmanlist]
	}

	;# Add MinchahGedolahGRA lechumrah
	if {$zmanName eq "MinchahGedolahGRA"} {
	    $day add -7 days
	    for {set dow 1} {$dow <= 7} {incr dow} {
		lappend zmanlist [$cal zman $zmanName strict]
		$day add 1 days
	    }
	}

	lappend week {*}$zmanlist
	$day add -7 days
    }

    lappend week [$loc cget -name]
    lappend week "[$loc getLatitudeDMS], [$loc getLongitudeDMS]"

    puts stdout [csv::join $week]
    flush stdout

    $day add 7 days
}

