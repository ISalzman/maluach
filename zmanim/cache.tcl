
namespace eval ::zmanim::cache {

    namespace ensemble create -subcommands {add exists get trim}

    variable cache
    
    set cache(cache) [dict create]
    set cache(lru) [list]
    set cache(max) 500

    proc add {ts lon lat alt key val} {
	variable cache

	if {! [dict exists $cache(cache) $ts]} {
	    dict set cache(cache) $ts [dict create longitude $lon latitude $lat $alt [dict create $key $val]]
	} else {
	    array set bag [dict get $cache(cache) $ts]
	    if {$bag(longitude) == $lon && $bag(latitude) == $lat} {
		dict set cache(cache) $ts $alt $key $val
	    } else {
		dict set cache(cache) $ts [dict create longitude $lon latitude $lat $alt [dict create $key $val]]
	    }
	}

	set pos [lsearch $cache(lru) $ts]
	set cache(lru) [lreplace $cache(lru) $pos $pos]
	lappend cache(lru) $ts

	trim
	return
    }

    proc get {ts lon lat alt key} {
	variable cache

	if {! [dict exists $cache(cache) $ts]} {
	    return -code error "no data for \"$ts\" in cache"
	}

	array set bag [dict get $cache(cache) $ts]
	if {$bag(longitude) == $lon && $bag(latitude) == $lat && [info exists bag($alt)]} {
	    return [dict get $bag($alt) $key]
	}

	return -code error "no data for \"$key\" in cache"
    }

    proc exists {ts lon lat alt key} {
	variable cache

	if {! [dict exists $cache(cache) $ts]} {
	    return false
	}

	array set bag [dict get $cache(cache) $ts]
	if {$bag(longitude) == $lon && $bag(latitude) == $lat && [info exists bag($alt)]} {
	    return [dict exists $bag($alt) $key]
	}

	return false
    }

    proc trim {{max ""}} {
	variable cache

	if {$max eq ""} {
	    set max $cache(max)
	}

	if {! [string is integer $max]} {
	    return -code error "expected integer but got \"$max\""
	}

	set len [llength $cache(lru)]
	if {$len > $max} {
	    set dif [expr {$len - $max - 1}]
	    foreach key [lrange $cache(lru) 0 $dif] {
		dict unset cache(cache) $key
	    }
	    set cache(lru) [lrange $cache(lru) [incr dif] end]
	}

	return
    }
}
