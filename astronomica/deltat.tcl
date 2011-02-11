
namespace eval ::astronomica::deltaT {
    namespace path [namespace parent]

    ################
    # Chapter 10
    # Dynamical Time
    ################

    # Data taken from:
    # ftp://maia.usno.navy.mil/ser7/deltat.data
    # ftp://maia.usno.navy.mil/ser7/deltat.preds
    # ftp://maia.usno.navy.mil/ser7/historic_deltat.data

    variable deltaTdata {
	1900 -2.70
	1901 -1.48
	1902 -0.08
	1903  1.26
	1904  2.59
	1905  3.92
	1906  5.20
	1907  6.29
	1908  7.68
	1909  9.13
	1910 10.38
	1911 11.64
	1912 13.23
	1913 14.69
	1914 16.00
	1915 17.19
	1916 18.19
	1917 19.13
	1918 20.14
	1919 20.86
	1920 21.41
	1921 22.06
	1922 22.51
	1923 23.01
	1924 23.46
	1925 23.63
	1926 23.95
	1927 24.39
	1928 24.34
	1929 24.10
	1930 24.02
	1931 23.98
	1932 23.89
	1933 23.93
	1934 23.88
	1935 23.91
	1936 23.76
	1937 23.91
	1938 23.96
	1939 24.04
	1940 24.35
	1941 24.82
	1942 25.30
	1943 25.77
	1944 26.27
	1945 26.76
	1946 27.27
	1947 27.77
	1948 28.25
	1949 28.70
	1950 29.15
	1951 29.57
	1952 29.97
	1953 30.36
	1954 30.72
	1955 31.07
	1956 31.349
	1957 31.677
	1958 32.166
	1959 32.671
	1960 33.150
	1961 33.584
	1962 33.992
	1963 34.466
	1964 35.030
	1965 35.738
	1966 36.546
	1967 37.429
	1968 38.291
	1969 39.204
	1970 40.182
	1971 41.170
	1972 42.227
	1973 43.373
	1974 44.484
	1975 45.476
	1976 46.457
	1977 47.521
	1978 48.534
	1979 49.586
	1980 50.539
	1981 51.381
	1982 52.167
	1983 52.957
	1984 53.788
	1985 54.343
	1986 54.871
	1987 55.322
	1988 55.820
	1989 56.300
	1990 56.855
	1991 57.565
	1992 58.309
	1993 59.122
	1994 59.985
	1995 60.785
	1996 61.629
	1997 62.295
	1998 62.966
	1999 63.467
	2000 63.829
	2001 64.091
	2002 64.300
	2003 64.473
	2004 64.574
	2005 64.688
	2006 64.845
	2007 65.146
	2008 65.457
	2009 65.777
	2010 66.070
	2011 66.325

	# Future predictions
	2012 68.0
	2013 68.0
	2014 69.0
	2015 69.0
	2016 70.0
	2017 70.0
    }

    proc Init {} {
	variable deltaTdata
	variable deltaTdict

	set deltaTdict [dict create]

	foreach line [split $deltaTdata "\n"] {
	    set line [string trim $line]
	    if {($line eq "") || ([string index $line 0] eq "#")} {
		continue
	    }

	    foreach {y dt} $line {
		dict set deltaTdict $y $dt
	    }
	}

	return
    }

    proc deltaT-alt {jd} {
	variable deltaTdict

	if {! [info exists deltaTdict] || [dict size $deltaTdict] == 0} {
	    Init
	}

	set y [YearFraction $jd]
	set t [expr {($y - 2000) / 100.0}]

	if {[dict exists $deltaTdict [expr {int($y)}]]} {
	    set dt [dict get $deltaTdict [expr {int($y)}]]
	} elseif {$y < 948} {
	    set dt [expr {2177 + 497*$t + 44.1*$t**2}]
	} elseif {$y < 1800} {
	    set dt [expr {102 + 102*$t + 25.3*$t**2}]
	} elseif {$y < 1900} {
	    set u [expr {($y - 1900) / 100.0}]
	    set dt [expr {-2.50 + 228.95*$u + 5218.61*$u**2 + 56282.84*$u**3 + 324011.78*$u**4 + 1061660.75*$u**5 + 2087298.89*$u**6 + 2513807.78*$u**7 + 1818961.41*$u**8 + 727058.63*$u**9 + 123563.95*$u**10}]
	} elseif {$y < 2000} {
	    set u [expr {($y - 1900) / 100.0}]
	    set dt [expr {-2.44 + 87.24*$u + 815.20*$u**2 - 2637.80*$u**3 - 18756.33*$u**4 + 124906.15*$u**5 - 303191.19*$u**6 + 372919.88*$u**7 - 232424.66*$u**8 + 58353.42*$u**9}]
	} elseif {$y < 2100} {
	    set dt [expr {102 + 102*$t + 25.3*$t**2 + 0.37*($y - 2100)}]
	} else {
	    set dt [expr {102 + 102*$t + 25.3*$t**2}]
	}

	return $dt
    }

    # Taken from http://eclipse.gsfc.nasa.gov/SEhelp/deltatpoly2004.html
    proc deltaT {jd} {
	variable deltaTdict

	if {! [info exists deltaTdict] || [dict size $deltaTdict] == 0} {
	    Init
	}

	set y [YearFraction $jd]

	if {[dict exists $deltaTdict [expr {int($y)}]]} {
	    set dt [dict get $deltaTdict [expr {int($y)}]]
	} elseif {($y < -500) || ($y > 2150)} {
	    set u [expr {($y - 1820) / 100.0}]
	    set dt [expr {-20 + 32*$u**2}]
	} elseif {$y <= 500} {
	    set u [expr {$y / 100.0}]
	    set dt [expr {10583.6 - 1014.41*$u + 33.78311*$u**2 - 5.952053*$u**3 - 0.1798452*$u**4 + 0.022174192*$u**5 + 0.0090316521*$u**6}]
	} elseif {$y <= 1600} {
	    set u [expr {($y - 1000) / 100.0}]
	    set dt [expr {1574.2 - 556.01*$u + 71.23472*$u**2 + 0.319781*$u**3 - 0.8503463*$u**4 - 0.005050998*$u**5 + 0.0083572073*$u**6}]
	} elseif {$y <= 1700} {
	    set u [expr {($y - 1600) / 100.0}]
	    set dt [expr {120 - 98.08*$u - 153.2*$u**2 + $u**3/0.007129}]
	} elseif {$y <= 1800} {
	    set u [expr {($y - 1700) / 100.0}]
	    set dt [expr {8.83 + 16.03*$u - 59.285*$u**2 + 133.36*$u**3 - $u**4/0.01174}]
	} elseif {$y <= 1860} {
	    set u [expr {($y - 1800) / 100.0}]
	    set dt [expr {13.72 - 33.2447*$u + 68.612*$u**2 + 4111.6*$u**3 - 37436*$u**4 + 121272*$u**5 - 169900*$u**6 + 87500*$u**7}]
	} elseif {$y <= 1900} {
	    set u [expr {($y - 1860) / 100.0}]
	    set dt [expr {7.62 + 57.37*$u - 2517.54*$u**2 + 16806.68*$u**3 - 44736.24*$u**4 + $u**5/0.0000233174}]
	} elseif {$y <= 1920} {
	    set u [expr {($y - 1900) / 100.0}]
	    set dt [expr {-2.79 + 149.4119*$u - 598.939*$u**2 + 6196.6*$u**3 - 19700*$u**4}]
	} elseif {$y <= 1941} {
	    set u [expr {($y - 1920) / 100.0}]
	    set dt [expr {21.20 + 84.493*$u - 761*$u**2 + 2093.6*$u**3}]
	} elseif {$y <= 1961} {
	    set u [expr {($y - 1950) / 100.0}]
	    set dt [expr {29.07 + 40.7*$u - $u**2/0.0233 + $u**3/0.002547}]
	} elseif {$y <= 1986} {
	    set u [expr {($y - 1975) / 100.0}]
	    set dt [expr {45.45 + 106.7*$u - $u**2/0.0260 - $u**3/0.000718}]
	} elseif {$y <= 2005} {
	    set u [expr {($y - 2000) / 100.0}]
	    set dt [expr {63.86 + 33.45*$u - 603.74*$u**2 + 1727.5*$u**3 + 65181.4*$u**4 + 237359.9*$u**5}]
	} elseif {$y <= 2050} {
	    set u [expr {($y - 2000) / 100.0}]
	    set dt [expr {62.92 + 32.217*$u + 55.89*$u**2}]
	} elseif {$y <= 2150} {
	    set u [expr {($y - 1820) / 100.0}]
	    set dt [expr {-205.724 + 56.28*$u + 32*$u**2}]
	}
    }

    proc YearFraction {jd} {
	lassign [date::ymd $jd] y m d
	set jd0 [date::jd $y 1 1]
	set days [expr {[date::isLeap $y] ? 366 : 365}]
	set fraction [expr {($jd - $jd0) / double($days)}]

	return [expr {$y + $fraction}]
    }
}
