#!/usr/local/bin/tclsh8.4
# dumps the specified bank
set cr 1
proc getbank {chan} {
	if {[expr $chan <= 100 && $chan >= 1]} {
		return "A"
	} elseif {[expr $chan >= 101 && $chan <= 200]} {
		return "B"
	} elseif {[expr $chan >= 201 && $chan <= 300]} {
		return "C"
	} elseif {[expr $chan >= 301 && $chan <= 400]} {
		return "D"
	} elseif {[expr $chan >= 401 && $chan <= 500]} {
		return "E"
	} elseif {[expr $chan >= 501 && $chan <= 600]} {
		return "F"
	} elseif {[expr $chan >= 601 && $chan <= 700]} {
		return "G"
	} elseif {[expr $chan >= 701 && $chan <= 800]} {
		return "H"
	} elseif {[expr $chan >= 801 && $chan <= 900]} {
		return "I"
	} elseif {[expr ($chan >= 901 && $chan <= 1000) || $chan == 0]} {
		return "J"
	}
}
proc getbankschan {bank} {
	return [string map {A 1 B 101 C 201 D 301 E 401 F 501 G 601 H 701 I 801 J 901} $bank]
}
proc getbankechan {bank} {
	return [string map {A 100 B 200 C 300 D 400 E 500 F 600 G 700 H 800 I 900 J 1000} $bank]
}
proc simulcommand {command} {
	#puts [join [list "Running command" $command]]
	if {[regexp -- "^TA (\[CB\]) (\[A-J\]|\[0-9\]{3}) (.{0,16})$" $command a mde bchan tag]} {
		return "OK"
	} elseif {[regexp -- "^TA C (\[0-9\]{3})$" $command a chan]} {
		return "TA C $chan Some Tag"
	} elseif {[regexp -- "^PM(\[0-9\]{3})$" $command a chan]} {
#C089 F08511625 TN DN LF AF RF N000
			return "C$chan F01555500 TN DN LN AF RF N000"
	}
}
proc dumpbank {bank file fhn} {
        if {[string length $file] == 0} {return}
	set bstart [getbankschan $bank]
	set bend   [getbankechan $bank]
	set ccdbh  [open $file "a"]
	for {set cx $bstart} {$cx <= $bend} {incr cx} {
		set x {}
		if {[expr [string length $cx] < 3]} {
			lappend x [join [list [string repeat "0" [expr 3- [string length $cx]]] $cx] ""]
		} elseif {[expr $cx == 1000]} {
			set x "000"
		} else {
			set x $cx
		}
		set result [scommand [join [list "PM" $x] ""]]
		set tag    [scommand [list "TA" "C" $x]]
		if {[regexp -- "^TA C $x (.{1,16})" $tag a ttg]} {
			set fta [join [list ",\"" $ttg "\""] ""]
		} else {
			set fta ",\"\""
		}
		if {[regexp -- "^C(\[0-9\]{3}) F(\[0-9\]{4})(\[0-9\]{4}) T(\[TFNY\]) D(\[TFNY\]) L(\[TFNY\]) A(\[TFNY\]) R(\[TFNY\]) N(\[0-9\]{3})" $result a chan wmhz dmhz trunked delay lockout atten recording ctcss]} {
			if {$wmhz == 0} { continue }
			set flags " "
			if {[string equal "N" $delay]} {
				lappend flags -d yes
			}
			if {[string equal "N" $lockout]} {
				lappend flags -l yes
			}
			puts $ccdbh [join [list $chan ":" $wmhz "." $dmhz $fta "," $flags] ""]
		}
		unset -nocomplain chan wmhz fta result x tag ttg
	}
	close $ccdbh
}
proc dumpall {filename clabel} {
	$clabel insert end "Dumping to $filename\n"
	$clabel insert end "Dumping bank A...\n"
	dumpbank "A" $filename 0
	$clabel insert end "Dumping bank B...\n"
	dumpbank "B" $filename 0
	$clabel insert end "Dumping bank C...\n"
	dumpbank "C" $filename 0
	$clabel insert end "Dumping bank D...\n"
	dumpbank "D" $filename 0
	$clabel insert end "Dumping bank E...\n"
	dumpbank "E" $filename 0
	$clabel insert end "Dumping bank F...\n"
	dumpbank "F" $filename 0
	$clabel insert end "Dumping bank G...\n"
	dumpbank "G" $filename 0
	$clabel insert end "Dumping bank H...\n"
	dumpbank "H" $filename 0
	$clabel insert end "Dumping bank I...\n"
	dumpbank "I" $filename 0
	$clabel insert end "Dumping bank J...\n"
	dumpbank "J" $filename 0
	$clabel insert end "Dumping Finished!"
}
proc dumpsel {filename clabel} {
        if {[string length $filename] == 0} {return}
	foreach {ky} {A B C D E F G H I J} {
		global bank_$ky
		if {[set bank_$ky]} {
			$clabel insert end "Dumping bank $ky...\n"
			dumpbank $ky $filename 0
		}
	}
	$clabel insert end "Dumping finished!\n"
}
