
package require Tcl 8.5
package require astronomica
package provide zmanim 1.0

namespace eval ::zmanim {
    namespace path {::tcl::mathfunc ::tcl::mathop}
    variable library [file dirname [file normalize [info script]]]

    variable zmanim
    set zmanim(seconds) no
    set zmanim(cache) [dict create]
    set zmanim(round) [dict create	\
	alos72			floor	\
	alos16.1		floor	\
	alosMinutes		floor	\
	alosDegrees		floor	\
	misheyakir10.2		ceil	\
	misheyakir11.0		ceil	\
	misheyakir11.5		ceil	\
	misheyakir45		ceil	\
	hanetz			ceil	\
	chatzos			floor	\
	shekiah			floor	\
	neiros18		floor	\
	tzeis45			ceil	\
	tzeis72			ceil	\
	tzeis8.5		ceil	\
	tzeis16.1		ceil	\
	tzeisMinutes		ceil	\
	tzeisDegrees		ceil	\
	sofTaanis6.45		ceil	\
	sofTaanis7.12		ceil	\
	shaahZmanisGRA		round	\
	sofZmanShemaGRA		floor	\
	sofZmanTefilahGRA	floor	\
	minchahGedolahGRA	ceil	\
	minchahKetanahGRA	floor	\
	plagHaminchahGRA	floor	\
	shaahZmanisMA72		round	\
	shaahZmanisMA16.1	round	\
	sofZmanShemaMA72	floor	\
	sofZmanShemaMA16.1	floor	\
	sofZmanTefilahMA72	floor	\
	sofZmanTefilahMA16.1	floor	\
	minchahGedolahMA72	ceil	\
	minchahGedolahMA16.1	ceil	\
	minchahKetanahMA72	floor	\
	minchahKetanahMA16.1	floor	\
	plagHaminchahMA72	floor	\
	plagHaminchahMA16.1	floor	\
    ]

    proc hanetz {year month day longitude latitude timezone {altitude ""}} {
	variable zmanim

	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y" -timezone $timezone]
	set tzoffset [TZoffset $year $month $day $timezone]

	# Consult cache for pre-calcualated sunrise
	if {[dict exists $zmanim(cache) $today $longitude $latitude $altitude sunrise]} {
	    set sunrise [dict get $zmanim(cache) $today $longitude $latitude $altitude sunrise]
	} else {
	    set sunrise [astronomica::sunriseUT $year $month $day $longitude $latitude $altitude]
	    set local [expr {$sunrise + $tzoffset}]

	    if {$local >= 24.0} {
		set sunrise [astronomica::sunriseUT $year $month [incr day -1] $longitude $latitude $altitude]
	    } elseif {$local < 0} {
		set sunrise [astronomica::sunriseUT $year $month [incr day +1] $longitude $latitude $altitude]
	    }

	    dict set zmanim(cache) $today $longitude $latitude $altitude sunrise $sunrise
	}

	set local [expr {$sunrise + $tzoffset}]
	if {$local < 0} {
	    set local [expr {$local + 24.0}]
	}

	return $local
    }

    proc shekiah {year month day longitude latitude timezone {altitude ""}} {
	variable zmanim

	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y" -timezone $timezone]
	set tzoffset [TZoffset $year $month $day $timezone]

	# Consult cache for pre-calcualated sunset
	if {[dict exists $zmanim(cache) $today $longitude $latitude $altitude sunset]} {
	    set sunset [dict get $zmanim(cache) $today $longitude $latitude $altitude sunset]
	} else {
	    set sunset [astronomica::sunsetUT $year $month $day $longitude $latitude $altitude]
	    set local [expr {$sunset + $tzoffset}]

	    if {$local >= 24.0} {
		set sunset [astronomica::sunsetUT $year $month [incr day -1] $longitude $latitude $altitude]
	    } elseif {$local < 0} {
		set sunset [astronomica::sunsetUT $year $month [incr day +1] $longitude $latitude $altitude]
	    }

	    dict set zmanim(cache) $today $longitude $latitude $altitude sunset $sunset
	}

	set local [expr {$sunset + $tzoffset}]
	if {$local < 0} {
	    set local [expr {$local + 24.0}]
	}

	return $local
    }

    proc chatzos {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 6.0)}]
    }

    proc alos72 {year month day longitude latitude timezone} {
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]
	return [expr {$hanetz - (72.0 / 60.0)}]
    }

    proc alos16.1 {year month day longitude latitude timezone} {
	set alos [hanetz $year $month $day $longitude $latitude $timezone -16.1]
	return $alos
    }

    proc alosMinutes {year month day longitude latitude timezone minutes} {
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]
	return [expr {$hanetz - ($minutes / 60.0)}]
    }

    proc alosDegrees {year month day longitude latitude timezone degrees} {
	set alos [hanetz $year $month $day $longitude $latitude $timezone -$degrees]
	return $alos
    }

    proc misheyakir45 {year month day longitude latitude timezone} {
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]
	return [expr {$hanetz - (45.0 / 60.0)}]
    }

    proc misheyakir10.2 {year month day longitude latitude timezone} {
	set misheyakir [hanetz $year $month $day $longitude $latitude $timezone -10.2]
	return $misheyakir
    }

    proc misheyakir11.0 {year month day longitude latitude timezone} {
	set misheyakir [hanetz $year $month $day $longitude $latitude $timezone -11.0]
	return $misheyakir
    }

    proc misheyakir11.5 {year month day longitude latitude timezone} {
	set misheyakir [hanetz $year $month $day $longitude $latitude $timezone -11.5]
	return $misheyakir
    }

    proc neiros18 {year month day longitude latitude timezone} {
	set shekiah [shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah - (18.0 / 60.0)}]
    }

    proc tzeis45 {year month day longitude latitude timezone} {
	set shekiah [shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah + (45.0 / 60.0)}]
    }

    proc tzeis72 {year month day longitude latitude timezone} {
	set shekiah [shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah + (72.0 / 60.0)}]
    }

    proc tzeis8.5 {year month day longitude latitude timezone} {
	set tzeis [shekiah $year $month $day $longitude $latitude $timezone -8.5]
	return $tzeis
    }

    proc tzeis16.1 {year month day longitude latitude timezone} {
	set tzeis [shekiah $year $month $day $longitude $latitude $timezone -16.1]
	return $tzeis
    }

    proc tzeisMinutes {year month day longitude latitude timezone minutes} {
	set shekiah [shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah + ($minutes / 60.0)}]
    }

    proc tzeisDegrees {year month day longitude latitude timezone degrees} {
	set tzeis [shekiah $year $month $day $longitude $latitude $timezone -$degrees]
	return $tzeis
    }

    proc sofTaanis6.45 {year month day longitude latitude timezone} {
	set tzeis [shekiah $year $month $day $longitude $latitude $timezone -6.45]
	return $tzeis
    }

    proc sofTaanis7.12 {year month day longitude latitude timezone} {
	set tzeis [shekiah $year $month $day $longitude $latitude $timezone -7.12]
	return $tzeis
    }

    proc shaahZmanisGRA {year month day longitude latitude timezone} {
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]
	set shekiah [shekiah $year $month $day $longitude $latitude $timezone]

	return [expr {($shekiah - $hanetz) / 12.0}]
    }

    proc sofZmanShemaGRA {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 3.0)}]
    }

    proc sofZmanTefilahGRA {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 4.0)}]
    }

    proc minchahGedolahGRA {year month day longitude latitude timezone {strict 0}} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	if {$strict && $zmanis < 1.0} {
	    return [expr {$hanetz + ($zmanis * 6.0) + 0.5}]
	}

	return [expr {$hanetz + ($zmanis * 6.5)}]
    }

    proc minchahKetanahGRA {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 9.5)}]
    }

    proc plagHaminchahGRA {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 10.75)}]
    }

    proc shaahZmanisMA72 {year month day longitude latitude timezone} {
	set alos [alos72 $year $month $day $longitude $latitude $timezone]
	set tzeis [tzeis72 $year $month $day $longitude $latitude $timezone]

	return [expr {($tzeis - $alos) / 12.0}]
    }

    proc shaahZmanisMA16.1 {year month day longitude latitude timezone} {
	set alos [alos16.1 $year $month $day $longitude $latitude $timezone]
	set tzeis [tzeis16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {($tzeis - $alos) / 12.0}]
    }

    proc sofZmanShemaMA72 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 3.0)}]
    }

    proc sofZmanShemaMA16.1 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA16.1 $year $month $day $longitude $latitude $timezone]
	set alos [alos16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 3.0)}]
    }

    proc sofZmanTefilahMA72 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 4.0)}]
    }

    proc sofZmanTefilahMA16.1 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA16.1 $year $month $day $longitude $latitude $timezone]
	set alos [alos16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 4.0)}]
    }

    proc minchahGedolahMA72 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 6.5)}]
    }

    proc minchahKetanahMA72 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 9.5)}]
    }

    proc plagHaminchahMA72 {year month day longitude latitude timezone} {
	set zmanis [shaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 10.75)}]
    }

    proc keepSeconds {{yesno ""}} {
	variable zmanim

	if {[string is boolean -strict $yesno]} {
	    set zmanim(seconds) $yesno
	}

	return $zmanim(seconds)
    }

    proc format {zman type year month day timezone {format ""}} {
	set seconds [ClockConvert $zman $type $year $month $day $timezone]

	if {$format eq ""} {
	    if {[string match {shaahZmanis*} $type]} {
		set format "%k:%M:%S"
	    } elseif {[keepSeconds]} {
		#set format "%l:%M:%S%P"
		set format "%k:%M:%S"
	    } else {
		#set format "%l:%M%P"
		set format "%k:%M"
	    }
	}

	return [string trim [clock format $seconds -format $format -timezone $timezone]]
    }

    #
    # Internal procs
    #

    proc RoundFunc {zman} {
	variable zmanim
	return [dict get $zmanim(round) $zman]
    }

    proc TZoffset {year month day timezone} {
	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y" -timezone $timezone]
	set tz [clock format $today -format "%z" -timezone $timezone]

	scan $tz "%3d%2d" tzh tzm
	set tzoffset [expr {$tzh + ($tzm / 60.0)}]

	return $tzoffset
    }

    proc ClockConvert {zman type year month day timezone} {
	#set caller [namespace tail [lindex [info level -1] 0]]
	set round [RoundFunc $type]

	if {[keepSeconds] || [string match {shaahZmanis*} $type]} {
	    # Round to nearest second
	    set zman [$round [expr {$zman * 3600}]]
	    set zman [expr {int($zman)}]
	} else {
	    # Round to nearest minute
	    set zman [$round [expr {$zman * 60}]]
	    set zman [expr {int($zman * 60)}]
	}

	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y" -timezone $timezone]
	set seconds [clock add $today $zman seconds -timezone $timezone]

	return $seconds
    }
}
