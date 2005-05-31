set bank A
set chnumb 1
proc bsel {} {
	global bank
	global chnumb
	set chnumb [string map {A 1 B 101 C 201 D 301 E 401 F 501 G 601 H 701 I 801 J 901} $bank]
}
proc selb {} {
	global bank
	global chnumb
	set exc [expr $chnumb % 100]
	set cid [expr ($chnumb - $exc) / 100]
	if {$exc == 0} { set cid [expr $cid - 1] }
	puts "$cid $exc"
	if {$cid == 10} { set bank J } else {
		set bank [string map {0 A 1 B 2 C 3 D 4 E 5 F 6 G 7 H 8 I 9 J} $cid]
	}
	return 1
}
proc edchan {chn} {
	set cw .chedit
	set bank A
	set chnumb $chn
	toplevel $cw
	label $cw.chla -text "Channel:"
	spinbox $cw.ch -from 1 -to 1000 -width 5 -validate focus -vcmd {string \
		is integer %P ; selb} -textvariable chnumb
	grid $cw.chla  -sticky w
	grid $cw.ch -row 0 -column 1 -sticky w
	label $cw.lab -text "Freq:"
	entry $cw.freq -validate focus -vcmd {regexp "\[0-9\]\[0-9\]\[0-9\]\[0-9\]\.\[0-9\]\[0-9\]\[0-9\]\[0-9\]" %P} -textvariable setfreq -width 9 -invcmd bell
	set setfreq 0000.0000
	grid $cw.lab -row 0 -column 2
	grid $cw.freq -row 0 -column 3
	label $cw.tal -text "Alpha Tag:"
	entry $cw.tag -width 17 -validate key -vcmd {expr [string length %P] < 16}
	grid $cw.tal -row 1 -column 0
	grid $cw.tag -row 1 -column 1 -columnspan 3 -sticky ew
	checkbutton $cw.pri -text "Priority" -variable prior
	checkbutton $cw.del -text "Delay" -variable delay
	grid $cw.pri -row 2 -column 0
	grid $cw.del -row 2 -column 1
	labelframe $cw.bank -text "Bank"
	grid $cw.bank -row 3 -column 0 -columnspan 4 -sticky we -pady 3 -padx 3
	set ol -1
	set ow 0
	foreach c {A B C D E F G H I J} {
		if {$ol == 5} {
			set ow [expr $ow + 1]
			set ol 0
		} else {
			set ol [expr $ol + 1]
		}
		radiobutton $cw.bank.b$c -text $c -variable bank -value $c -command "bsel"
		grid $cw.bank.b$c -column $ol -row $ow
	}
	button $cw.ok -text "Okay"
	button $cw.canc -text "Cancel" -command "destroy $cw"
	grid $cw.ok $cw.canc -row 4 -sticky we
	bsel
}
