
package require Tcl 8.5
package require Astro
package provide Zmanim 1.0

namespace eval ::Zmanim {

    proc Init {} {
	variable zmanim

	set zmanim(seconds) no
	set zmanim(round) [dict create		\
	    Alos72			floor	\
	    Alos16.1			floor	\
	    Misheyakir10.2		ceil	\
	    Misheyakir11.0		ceil	\
	    Misheyakir11.5		ceil	\
	    Misheyakir45		ceil	\
	    Hanetz			ceil	\
	    Chatzos			floor	\
	    Shekiah			floor	\
	    Neiros18			floor	\
	    Tzeis45			ceil	\
	    Tzeis72			ceil	\
	    Tzeis8.5			ceil	\
	    Tzeis16.1			ceil	\
	    SofTaanis6.45		ceil	\
	    SofTaanis7.12		ceil	\
	    ShaahZmanisGRA		round	\
	    SofZmanShemaGRA		floor	\
	    SofZmanTefilahGRA		floor	\
	    MinchahGedolahGRA		ceil	\
	    MinchahKetanahGRA		floor	\
	    PlagHaminchahGRA		floor	\
	    ShaahZmanisMA72		round	\
	    ShaahZmanisMA16.1		round	\
	    SofZmanShemaMA72		floor	\
	    SofZmanShemaMA16.1		floor	\
	    SofZmanTefilahMA72		floor	\
	    SofZmanTefilahMA16.1	floor	\
	    MinchahGedolahMA72		ceil	\
	    MinchahGedolahMA16.1	ceil	\
	    MinchahKetanahMA72		floor	\
	    MinchahKetanahMA16.1	floor	\
	    PlagHaminchahMA72		floor	\
	    PlagHaminchahMA16.1		floor	\
	]

	Astro::Init
	return
    }

    proc KeepSeconds {{yesno ""}} {
	variable zmanim

	if {$yesno ne ""} {
	    set zmanim(seconds) $yesno
	}

	return $zmanim(seconds)
    }

    proc RoundFunc {zman} {
	variable zmanim
	return [dict get $zmanim(round) $zman]
    }

    proc Hanetz {year month day longitude latitude timezone {altitude ""}} {
	set sunrise [Astro::SunRiseUT $year $month $day $longitude $latitude $altitude]

	set tzoffset [TZoffset $year $month $day $timezone]
	set local [expr {$sunrise + $tzoffset}]

	if {$local >= 24.0} {
	    set sunrise [Astro::SunRiseUT $year $month [incr day -1] $longitude $latitude $altitude]
	} elseif {$local < 0.0} {
	    set sunrise [Astro::SunRiseUT $year $month [incr day +1] $longitude $latitude $altitude]
	}

	set local [expr {$sunrise + $tzoffset}]
	if {$local < 0.0} {
	    set local [expr {$local + 24.0}]
	}

	return $local
    }

    proc Shekiah {year month day longitude latitude timezone {altitude ""}} {
	set sunset [Astro::SunSetUT $year $month $day $longitude $latitude $altitude]

	set tzoffset [TZoffset $year $month $day $timezone]
	set local [expr {$sunset + $tzoffset}]

	if {$local >= 24.0} {
	    set sunset [Astro::SunSetUT $year $month [incr day -1] $longitude $latitude $altitude]
	} elseif {$local < 0.0} {
	    set sunset [Astro::SunSetUT $year $month [incr day +1] $longitude $latitude $altitude]
	}

	set local [expr {$sunset + $tzoffset}]
	if {$local < 0.0} {
	    set local [expr {$local + 24.0}]
	}

	return $local
    }

    proc Chatzos {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 6.0)}]
    }

    proc Alos72 {year month day longitude latitude timezone} {
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]
	return [expr {$hanetz - (72.0 / 60.0)}]
    }

    proc Alos16.1 {year month day longitude latitude timezone} {
	set alos [Hanetz $year $month $day $longitude $latitude $timezone -16.1]
	return $alos
    }

    proc Misheyakir45 {year month day longitude latitude timezone} {
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]
	return [expr {$hanetz - (45.0 / 60.0)}]
    }

    proc Misheyakir10.2 {year month day longitude latitude timezone} {
	set misheyakir [Hanetz $year $month $day $longitude $latitude $timezone -10.2]
	return $misheyakir
    }

    proc Misheyakir11.0 {year month day longitude latitude timezone} {
	set misheyakir [Hanetz $year $month $day $longitude $latitude $timezone -11.0]
	return $misheyakir
    }

    proc Misheyakir11.5 {year month day longitude latitude timezone} {
	set misheyakir [Hanetz $year $month $day $longitude $latitude $timezone -11.5]
	return $misheyakir
    }

    proc Neiros18 {year month day longitude latitude timezone} {
	set shekiah [Shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah - (18.0 / 60.0)}]
    }

    proc Tzeis45 {year month day longitude latitude timezone} {
	set shekiah [Shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah + (45.0 / 60.0)}]
    }

    proc Tzeis72 {year month day longitude latitude timezone} {
	set shekiah [Shekiah $year $month $day $longitude $latitude $timezone]
	return [expr {$shekiah + (72.0 / 60.0)}]
    }

    proc Tzeis8.5 {year month day longitude latitude timezone} {
	set tzeis [Shekiah $year $month $day $longitude $latitude $timezone -8.5]
	return $tzeis
    }

    proc Tzeis16.1 {year month day longitude latitude timezone} {
	set tzeis [Shekiah $year $month $day $longitude $latitude $timezone -16.1]
	return $tzeis
    }

    proc SofTaanis6.45 {year month day longitude latitude timezone} {
	set tzeis [Shekiah $year $month $day $longitude $latitude $timezone -6.45]
	return $tzeis
    }

    proc SofTaanis7.12 {year month day longitude latitude timezone} {
	set tzeis [Shekiah $year $month $day $longitude $latitude $timezone -7.12]
	return $tzeis
    }

    proc ShaahZmanisGRA {year month day longitude latitude timezone} {
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]
	set shekiah [Shekiah $year $month $day $longitude $latitude $timezone]

	return [expr {($shekiah - $hanetz) / 12.0}]
    }

    proc SofZmanShemaGRA {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 3.0)}]
    }

    proc SofZmanTefilahGRA {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 4.0)}]
    }

    proc MinchahGedolahGRA {year month day longitude latitude timezone {strict 0}} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	if {$strict && $zmanis < 1.0} {
	    return [expr {$hanetz + ($zmanis * 6.0) + 0.5}]
	}

	return [expr {$hanetz + ($zmanis * 6.5)}]
    }

    proc MinchahKetanahGRA {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 9.5)}]
    }

    proc PlagHaminchahGRA {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisGRA $year $month $day $longitude $latitude $timezone]
	set hanetz [Hanetz $year $month $day $longitude $latitude $timezone]

	return [expr {$hanetz + ($zmanis * 10.75)}]
    }

    proc ShaahZmanisMA72 {year month day longitude latitude timezone} {
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]
	set tzeis [Tzeis72 $year $month $day $longitude $latitude $timezone]

	return [expr {($tzeis - $alos) / 12.0}]
    }

    proc ShaahZmanisMA16.1 {year month day longitude latitude timezone} {
	set alos [Alos16.1 $year $month $day $longitude $latitude $timezone]
	set tzeis [Tzeis16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {($tzeis - $alos) / 12.0}]
    }

    proc SofZmanShemaMA72 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 3.0)}]
    }

    proc SofZmanShemaMA16.1 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA16.1 $year $month $day $longitude $latitude $timezone]
	set alos [Alos16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 3.0)}]
    }

    proc SofZmanTefilahMA72 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 4.0)}]
    }

    proc SofZmanTefilahMA16.1 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA16.1 $year $month $day $longitude $latitude $timezone]
	set alos [Alos16.1 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 4.0)}]
    }

    proc MinchahGedolahMA72 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 6.5)}]
    }

    proc MinchahKetanahMA72 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 9.5)}]
    }

    proc PlagHaminchahMA72 {year month day longitude latitude timezone} {
	set zmanis [ShaahZmanisMA72 $year $month $day $longitude $latitude $timezone]
	set alos [Alos72 $year $month $day $longitude $latitude $timezone]

	return [expr {$alos + ($zmanis * 10.75)}]
    }

    proc TZoffset {year month day timezone} {
	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y"]
	set tz [clock format $today -format "%z" -timezone $timezone]

	scan $tz "%3d%2d" tzh tzm
	set tzoffset [expr {$tzh + ($tzm / 60.0)}]

	return $tzoffset
    }

    proc ClockConvert {zman type year month day timezone} {
	#set caller [namespace tail [lindex [info level -1] 0]]
	set roundfunc [RoundFunc $type]

	if {[KeepSeconds] || [string match {ShaahZmanis*} $type]} {
	    # Round to nearest second
	    set zman [::tcl::mathfunc::$roundfunc [expr {$zman * 3600}]]
	    set zman [expr {int($zman)}]
	} else {
	    # Round to nearest minute
	    set zman [::tcl::mathfunc::$roundfunc [expr {$zman * 60}]]
	    set zman [expr {int($zman * 60)}]
	}

	set today [clock scan "$month/$day/$year" -format "%m/%d/%Y"]
	set seconds [clock add $today $zman seconds -timezone $timezone]

	return $seconds
    }

    proc Format {zman type year month day timezone {format ""}} {
	set seconds [ClockConvert $zman $type $year $month $day $timezone]

	if {$format eq ""} {
	    if {[string match {ShaahZmanis*} $type]} {
		set format "%k:%M:%S"
	    } elseif {[KeepSeconds]} {
		#set format "%l:%M:%S%P"
		set format "%k:%M:%S"
	    } else {
		#set format "%l:%M%P"
		set format "%k:%M"
	    }
	}

	return [string trim [clock format $seconds -format $format]]
    }
}
