
package require msgcat

namespace eval ::dafyomi {
    variable library [file dirname [file normalize [info script]]]

    variable dafyomi
    set dafyomi(oldepoch) [clock scan "09/11/1923" -format "%m/%d/%Y" -gmt 1]
    set dafyomi(newepoch) [clock scan "06/24/1975" -format "%m/%d/%Y" -gmt 1]
    set dafyomi(oldtotal) [expr {2702 * 86400}]
    set dafyomi(newtotal) [expr {2711 * 86400}]
    set dafyomi(_locale) [msgcat::mclocale]

    set dafyomi(shas) [dict create  \
	Berachos	{2 64}  \
	Shabbos		{2 157} \
	Eruvin		{2 105} \
	Pesachim	{2 121} \
	Shekalim	{2 22}  \
	Yoma		{2 88}  \
	Succah		{2 56}  \
	Beitzah		{2 40}  \
	{Rosh Hashanah}	{2 35}  \
	Taanis		{2 31}  \
	Megillah	{2 32}  \
	{Moed Katan}	{2 29}  \
	Chagigah	{2 27}  \
	Yevamos		{2 122} \
	Kesubos		{2 112} \
	Nedarim		{2 91}  \
	Nazir		{2 66}  \
	Sotah		{2 49}  \
	Gittin		{2 90}  \
	Kiddushin	{2 82}  \
	{Bava Kamma}	{2 119} \
	{Bava Metzia}	{2 119} \
	{Bava Basra}	{2 176} \
	Sanhedrin	{2 113} \
	Makkos		{2 24}  \
	Shevuos		{2 49}  \
	{Avodah Zarah}	{2 76}  \
	Horayos		{2 14}  \
	Zevachim	{2 120} \
	Menachos	{2 110} \
	Chullin		{2 142} \
	Bechoros	{2 61}  \
	Arachin		{2 34}  \
	Temurah		{2 34}  \
	Kereisos	{2 28}  \
	Meilah		{2 22}  \
	Kinnim		{23 25} \
	Tamid		{26 34} \
	Middos		{35 37} \
	Niddah		{2 73}  \
    ]

    proc cycle {year month day} {
	variable dafyomi

	set cycle 0
	set day [clock scan "${month}/${day}/${year}" -format "%m/%d/%Y" -gmt 1]

	if {$day >= $dafyomi(newepoch)} {
	    set cycle [expr {abs($day - $dafyomi(newepoch)) / $dafyomi(newtotal) + 8}]
	} elseif {$day >= $dafyomi(oldepoch)} {
	    set cycle [expr {abs($day - $dafyomi(oldepoch)) / $dafyomi(oldtotal) + 1}]
	}

	return $cycle
    }

    proc daf {year month day} {
	variable dafyomi

	set daf 0
	set maseches ""
	set day [clock scan "${month}/${day}/${year}" -format "%m/%d/%Y" -gmt 1]

	if {$day >= $dafyomi(newepoch)} {
	    dict set dafyomi(shas) Shekalim {2 22}
	    set daf [expr {abs($day - $dafyomi(newepoch)) % $dafyomi(newtotal)}]
	} elseif {$day >= $dafyomi(oldepoch)} {
	    dict set dafyomi(shas) Shekalim {2 13}
	    set daf [expr {abs($day - $dafyomi(oldepoch)) % $dafyomi(oldtotal)}]
	} else {
	    return -code error "The date given is prior to organized Daf Yomi cycles."
	}

	set daf [expr {$daf / 86400}]
	dict for {maseches pages} $dafyomi(shas) {
	    lassign $pages first last
	    set dapim [expr {$last - $first + 1}]

	    if {$daf < $dapim} {
		set daf [expr {$first + $daf}]
		break
	    }

	    set daf [expr {$daf - $dapim}]
	}

	return [encoding convertfrom [msgcat::mc "$maseches %s" [msgcat::mc $daf]]]
    }

    proc locale {{locale ""}} {
	variable dafyomi
	variable library

	if {$locale eq ""} {
	    set locale [msgcat::mclocale]
	} else {
	    if {$locale eq "-"} {
		set locale $dafyomi(_locale)
	    }

	    msgcat::mclocale $locale
	    msgcat::mcload [file join $library msgs]
	}

	return $locale
    }
}
