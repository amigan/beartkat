#!/usr/local/bin/tclsh8.4
proc loadfreqs {file labl} {
	if {[string length $file] == 0} {return}
	set freqdbh [ open $file "r" ]
	while {[gets $freqdbh cline] >= 0} {
		if {[regexp -- "^(\[0-9\]{1,3}):(\[0-9\]{2,4})\\.(\[0-9\]{3,4}),\"(.{0,16})\",(.*)$" $cline a chan wmhz dmhz alpha flags]} {
			if {[expr [string length $wmhz] != 4]} {
				lappend mhz [join [list [string repeat "0" [expr 4- [string length $wmhz]]] $wmhz] ""]
			} else {
				lappend mhz $wmhz
			}
			if {[expr [string length $dmhz] != 4]} {
				lappend mhz [join [list $dmhz [string repeat "0" [expr 4- [string length $dmhz]]]] ""]
			} else {
				lappend mhz $dmhz
			}
			set fmhz [join $mhz ""]
			if {[expr [string length $chan] != 3]} {
				lappend rchan [join [list [string repeat "0" [expr 3- [string length $chan]]] $chan] ""]
			} else {
				lappend rchan $chan
			}
			set fcmd [join [list PM $rchan] ""]
			set fcmdl [join [list $fcmd $fmhz]]
			$labl insert end "Sending channel $chan $alpha\n"
			if {[expr [string length $alpha] > 0]} {
				sendcommand "TA C $rchan $alpha"
			}
			foreach {key value} $flags {
				if {[string equal $key "-d"] && [string is boolean $value] && $value} {
					sendcommand "MA$rchan"
					sendcommand "DLN"
				} elseif {[string equal $key "-l"] && [string is boolean $value] && $value} {
					$labl insert end "Locking out $chan...\n"
					sendcommand "MA$rchan"
					sendcommand "LON"
				}
			}
			unset -nocomplain mhz fcmd fcmdl rchan a chan wmhz dmhz wal alpha key value flags
		} elseif {[regexp -- "^B(\[0-9\]|\[A-J\]):\"(.{0,16})\"$" $cline a bank btg]} {
			if {[string is digit $bank]} {
				set fbnk [string map {0 J 1 A 2 B 3 C 4 D 5 E 6 F 7 G 8 H 9 I} $bank]
			} else {
				set fbnk $bank
			}
			$labl insert end "Setting bank $fbnk to $btg...\n"
			sendcommand "TA B $fbnk $btg"
			unset -nocomplain a bank btg fbnk
		}
	}
	close $freqdbh
} 
proc loadtolist {file lb} {
	if {[string length $file] == 0} {return}
	set freqdbh [ open $file "r" ]
	$lb delete 0 end
	while {[gets $freqdbh cline] >= 0} {
		if {[regexp -- "^(\[0-9\]{1,3}):(\[0-9\]{2,4})\\.(\[0-9\]{3,4}),\"(.{0,16})\",(.*)$" $cline a chan wmhz dmhz alpha flags]} {
			if {$wmhz == 0} { continue }
			set cit {}
			lappend cit $chan [join [list $wmhz . $dmhz] ""] $alpha
			foreach {key value} $flags {
				if {[string equal $key "-d"] && [string is boolean $value] && $value} {
					lappend cit True
				} 
# else { lappend cit N }
				if {[string equal $key "-l"] && [string is boolean $value] && $value} {
					lappend cit True
				}
#  else { lappend cit N }
			}
			$lb insert end $cit
#			$lb insert end [list [join [list $chan :] ""]  [join [list $wmhz "." $dmhz] ""] $alpha]
		}
	}
	close $freqdbh
}
proc tunechan {chanline} {
	set chan [lindex $chanline 0]
	scommand [join [list "MA" $chan] ""]
}
