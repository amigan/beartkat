#!/usr/local/bin/wish8.4
# under the DUPL
# $Amigan: beartkat/src/beartkat.tcl,v 1.10 2005/01/17 16:40:54 dcp1990 Exp $
# (C)2004-2005, Dan Ponte
#YA!!!
#package require wcb
package require tablelist
set lastcmd ""
set version 0.3
set tries 1
set gotresp no
set donthandle no
proc setalpha {chan tag fhh mde} {
	if {[expr [string length $chan] != 3]} {
		return
	}
	if {[string equal $mde "set"]} {
		sendcommand [list TA C $chan $tag]
	} elseif {[string equal $mde "clear"]} {
		sendcommand "TA C $chan "
	} elseif {[string equal $mde "get"]} {
		set algt [scommand "TA C $chan"]
		if {[regexp -- "TA C (\[0-9\]{3}) (.{0,16})\$" $algt a cn ttag]} {
			if {[string equal [.alp.mfr.chan get] $cn]} {
				.alp.mfr.ent delete 0 end
				.alp.mfr.ent insert 1 $ttag
			}
		}
	}
}
proc aboutbox {} {
	global version
	toplevel .abtbox
	frame .abtbox.msg
	pack .abtbox.msg -fill both -side top
	frame .abtbox.btn
	pack .abtbox.btn -side bottom -fill x
	label .abtbox.msg.icon -bitmap info
	label .abtbox.msg.mess -text "BearTKat v$version - a scanner control app for the BC250D and other radios\n(C)2004-2005, Dan Ponte. Licensed under the DUPL.\nA copy of the DUPL should have been included with this application. If not, write dcp1990@neptune.atopia.net.\nPortions (specifically the control protocol) are copyright (C)2003,2004 Uniden America, Inc.\nThis product is not endorsed by or affiliated with Uniden.\nThe \"Bearcat\" logo and the Bearcat name are property of Uniden America and are trademarked.\n\$Amigan: beartkat/src/beartkat.tcl,v 1.10 2005/01/17 16:40:54 dcp1990 Exp $\nhttp://www.theamigan.net/beartkat.html" -justify left
	pack .abtbox.msg.icon -side left
	pack .abtbox.msg.mess
	button .abtbox.btn.ok -text "Ok" -command {destroy .abtbox}
	pack .abtbox.btn.ok
	wm resizable .abtbox 0 0
	wm title .abtbox "About"
}
proc rejmod {w args} {
#	wcb::cancel
	return
}
proc table {w content args} {
    frame $w -bg black
    set r 0
    foreach row $content {
	set fields {}
	set c 0
	foreach col $row {
	    lappend fields [label $w.$r/$c -text $col]
	    incr c
	}
	eval grid $fields -sticky news -padx 1 -pady 1
	incr r
    }
    set w
}

proc dispol {} {
	global fhn
	every "cancel" {sendcommand "LCD"}
	.mfr.openprt configure -text "Start Polling"
	.mfr.openprt configure -command {enabpol $fhn}
}
proc gbatt {} {
	set blvl [scommand "BL"]
	if {[regexp "BAT (\[0-9\]{3})" $blvl a lvl]} {
		set flvl [expr {int($lvl * .392156862745098)}]
		.disp.scr.batt configure -text "Batt: $flvl%"
	}
}
proc checkscanner {} {
	global waitingresp
	global gotresp
	if {$gotresp} {
		return
	}
	set gotresp no
	global fhn
	set waitingresp yes
	global tries
	if {$tries == 1} {
		sendcommand SI
		after 1000 {incr tries; checkscanner}
	} elseif {$tries < 9} {
		sendcommand SI
		after 1000 {incr tries; checkscanner}
	} elseif {$tries == 9} {
		set res [tk_messageBox -message "Never got a response from the radio.\nCheck that it is plugged in, your serial settings are correct, and that it is powered on." -type abortretryignore -icon error]
		if {$res == "abort"} {
			exit -1
		} elseif {$res == "retry"} {
			set waitingresp yes
			set gotresp no
			set tries 1
			checkscanner
		} elseif {$res == "ignore"} {
			.statusbar.scmodel configure -text "Goto Help->About my radio"
			return
		}
	}
}
proc filedialog {w types oper ent} {
	set file [realdialog $w $types $oper]
	if [string compare $file ""] {
		$ent delete 0 end
		$ent insert 0 $file
		$ent xview end
	}
	return $file
}
proc realdialog {w types oper} {
	if {$oper == "open"} {
		set file [tk_getOpenFile -filetypes $types -parent $w]
	} else {
		set file [tk_getSaveFile -filetypes $types -parent $w \
		    -initialfile Untitled -defaultextension .txt]
	}
	return $file
}
proc enabpol fhh {
	global fhn
	.mfr.openprt configure -text "Stop Polling"
	.mfr.openprt configure -command {dispol}
	every $btkConfig::interv {sendcommand "LCD"}
}
proc every {interval script} {
   global everyIds
   if {$interval eq "cancel"} {
      catch {after cancel $everyIds($script)}
      return
   }
   set everyIds($script) [after $interval [info level 0]]
   uplevel #0 $script
}
set alphop no
proc oalphwind {} {
	global alphop
	toplevel .alp
	set alphop yes
	.menubar.scan activate "Set Alpha Tags"
	wm resizable .alp no no
	wm title .alp "Alpha Tags"
	frame .alp.mfr -borderwidth 2
	pack .alp.mfr
	label .alp.mfr.cl -text "Channel number:"
	entry .alp.mfr.chan -width 4 -validate key -vcmd {expr {[regexp "^\[0-9\]{0,3}\$" %P] && [string length %P]<4}}
	pack .alp.mfr.cl .alp.mfr.chan -side left
	label .alp.mfr.tl -text "Alpha Text:"
	entry .alp.mfr.ent -width 16 -validate key -vcmd {expr {[string length %P] < 17}}
	pack .alp.mfr.tl .alp.mfr.ent -side left
	button .alp.mfr.setal -text "Set Alpha" -command {setalpha [.alp.mfr.chan get] [.alp.mfr.ent get] $fhn set}
	button .alp.mfr.clral -text "Clear Alpha" -command {setalpha [.alp.mfr.chan get] [.alp.mfr.ent get] $fhn clear}
	button .alp.mfr.getal -text "Get Alpha" -command {setalpha [.alp.mfr.chan get] "" $fhn get}
	pack .alp.mfr.setal .alp.mfr.clral .alp.mfr.getal -side left
	button .alp.mfr.close -text "Okay" -command "destroy .alp; set alphop no"
	pack .alp.mfr.close  -fill y
	wm protocol .alp WM_DELETE_WINDOW {set alphop no}
}
proc handlefile fhh {
	global lastin
	global donthandle
	global lastcmd
	set curin [gets $fhh]
	if {[regexp -- "LCD(\[1-4\]) \\\[(.{16})\\\]\\\[(.{16})\\\]" $curin oth lnum te fmt]} {
		if {[expr $lnum == 1]} {
			.disp.scr.lcd1 configure -text $te
		} elseif {[expr $lnum == 2]} {
			.disp.scr.lcd2 configure -text $te
		} elseif {[expr $lnum == 3]} {
			.disp.scr.lcd3 configure -text $te
		} elseif {[expr $lnum == 4]} {
			.disp.scr.lcd4 configure -text $te
		}
		return;
	} elseif {[regexp -- "ERR" $curin]} {
		tk_messageBox -message "Received ERR message from radio. Last command $lastcmd" -type ok -icon error
	} elseif {[regexp -- {SI (.*),(.*),([0-9][0-9][0-9])$} $curin a model esn rcmdv]} {
		global waitingresp
		global gotresp
		if {$waitingresp && !$gotresp} {
			set waitingresp no
			set gotresp yes
			.statusbar.scmodel configure -text "Model: $model"
		} elseif {$donthandle} {
			set lastin $curin
			set donthandle no
		} else {
			set blfs [scommand "BL"]
			regexp "BAT (\[0-9\]{3})" $blfs a batl
			set blevel [expr {int( $batl * .392156862745098)}]
			tk_messageBox -message "Scanner reported the following:\nModel: $model\nRemote Command Version: $rcmdv\nESN (not used): $esn\nBattery Level: $batl ($blevel%)" -type ok -icon info -title "About my radio"
		}
	} elseif {[regexp -- "PST" $curin]} {
		foreach {kg} {1 2 3 4} {
			.disp.scr.lcd$kg configure -background red
		}
	} elseif {[regexp -- "PRT" $curin]} {
		foreach {kg} {1 2 3 4} {
			.disp.scr.lcd$kg configure -background orange
		}
	} elseif {[string length $curin] > 1} {
		set lastin $curin
	}
}
source scommand.tcl
source api.tcl
source configns.tcl
source dumpmem.tcl
source loadfreqs.tcl
wm geometry . "=200x100"
set fhn [ open $btkConfig::ttydev "r+" ]
fconfigure $fhn -mode $btkConfig::baudrate,n,8,1 -blocking no
wm title . "BearTkat v$version"
frame .mfr -borderwidth 2 -width 102c -height 30c
grid .mfr -sticky wwwwwnnnnn -row 0 -column 0
#frame .menubar -relief raised -bd 2
#pack .menubar -in .mfr -fill x -expand yes 
menu .menubar -tearoff no
#menubutton .menubar.file -text "File" -menu .menubar.file.menu
#pack .menubar.file -side left
#menubutton .menubar.scan -text "Scanner" -menu .menubar.scan.menu
#pack .menubar.scan -side left
#menubutton .menubar.help -text "Help" -menu .menubar.help.menu
#pack .menubar.help -side right
menu .menubar.file -tearoff no
.menubar add cascade -label "File" -menu .menubar.file -underline 0
.menubar.file add command -label "Exit" -command "exit"
.menubar.file add command -label "Run Tcl Script" -command {set tscr [realdialog . {{"Tcl Script" {.tcl}}} open]; if {[string compare $tscr ""]} {source $tscr}}
menu .menubar.scan -tearoff no
.menubar add cascade -label "Scanner" -menu .menubar.scan -underline 0
.menubar.scan add command -label "Set Alpha Tags" -command {if {!$alphop} {oalphwind}}
menu .menubar.help -tearoff no
.menubar add cascade -label "Help" -menu .menubar.help -underline 0
.menubar.help add command -label "Help" -command {tk_messageBox -message "No online help yet. Try README.txt, included in the distribution." -type ok -icon info}
.menubar.help add command -label "About my radio" -command {sendcommand "SI"}
.menubar.help add command -label "About BearTKat" -command {aboutbox}
if {$windows} {
	menu .menubar.system -tearoff no
	.menubar add cascade -label "System" -menu .menubar.system -underline 0
	.menubar.system add command -label "About my radio" -command {sendcommand SI}
}
button .mfr.openprt -text "Start Polling" -command {enabpol $fhn}
button .mfr.quit -text "Exit" -command "exit"
pack .mfr.openprt .mfr.quit -side left
frame .statusbar
grid .statusbar -sticky s -row 4
label .statusbar.scmodel -text "Model: Waiting..." 
pack .statusbar.scmodel 
toplevel .disp
wm title .disp "LCD"
wm resizable .disp no no
frame .disp.scr -borderwidth 2 -width 16c -height 4c -relief sunken -background orange
pack .disp.scr
label .disp.scr.lcd1 -width 16 -text "                " -background orange -font "Courier 10"
label .disp.scr.lcd2 -width 16 -text "                " -background orange -font "Courier 10"
label .disp.scr.lcd3 -width 16 -text "                " -background orange -font "Courier 10"
label .disp.scr.lcd4 -width 16 -text "                " -background orange -font "Courier 10"
pack .disp.scr.lcd1 .disp.scr.lcd2 .disp.scr.lcd3 .disp.scr.lcd4
if {$btkConfig::notify} {
	sendcommand "RIN"
} elseif {[string equal $btkConfig::notify pass]} {
# do nothing
} elseif {!$btkConfig::notify} {
	sendcommand "RIF"
}
#label .disp.scr.batt -width 10 -text "Batt: ---" -background orange -font "Courier 10"
#pack .disp.scr.batt -side left
frame .disp.but -borderwidth 2 -width 16c -height 7c
pack .disp.but
set crow 0
button .disp.but.scan -text "SCAN" -command {sendcommand "KEY01"}
button .disp.but.rsm -text "RSM" -command {sendcommand KEY00}
button .disp.but.manual -text "MAN" -command {sendcommand KEY07}
button .disp.but.lgt -text "Light" -command {sendcommand "KEY08"}
button .disp.but.wx -text "WX" -command {sendcommand "KEY10"; sendcommand "KEY02 1"}
button .disp.but.lockout -text "L/O" -command {sendcommand "KEY06"}
grid .disp.but.manual .disp.but.rsm -sticky we -ipadx .2c
grid .disp.but.scan .disp.but.wx -sticky we
grid .disp.but.lgt .disp.but.lockout -sticky we
frame .disp.butk -width 7c
pack .disp.butk -expand yes -fill x
foreach cn {1 2 3} {
	button .disp.butk.kn$cn -text $cn -command [list sendcommand [list KEY02 $cn]]
	grid .disp.butk.kn$cn -row $crow -column [expr "$cn - 1"] -sticky we -ipadx .25c
}
incr crow
foreach cn {4 5 6} {
	button .disp.butk.kn$cn -text $cn -command [list sendcommand [list KEY02 $cn]]
	grid .disp.butk.kn$cn -row $crow -column [expr "$cn - 4"] -sticky we
}
incr crow
foreach cn {7 8 9} {
	button .disp.butk.kn$cn -text $cn -command [list sendcommand [list KEY02 $cn]]
	grid .disp.butk.kn$cn -row $crow -column [expr "$cn - 7"] -sticky we
}
unset cn
button .disp.butk.dec -text "." -command {sendcommand "KEY03"}
button .disp.butk.kn0 -text "0" -command {sendcommand "KEY02 0"}
button .disp.butk.enter -text "E" -command {sendcommand KEY04}
grid .disp.butk.dec .disp.butk.kn0 .disp.butk.enter -sticky we
fileevent $fhn readable {handlefile $fhn}
set tx .freq.outp
toplevel .freq
wm title .freq "Frequencies"
text .freq.outp -wrap word -width 78 -height 20 -setgrid on -yscrollcommand ".freq.ys set"
scrollbar .freq.ys -command ".freq.outp yview"
$tx insert end "This is the output area. Click the 'Open' button below to open a file in the following format:\n\tchannel#:freq.uency,\"Alpha tag\",-d yes|no -l yes|no\\n\nwhere -d is the delay flag and -l is the lockout flag\n"
pack .freq.ys -side right -fill y
pack .freq.outp -fill both -expand 1
frame .freq.mfr -height 24c -width 80c
frame .freq.banks
pack .freq.mfr -side top -fill x
pack .freq.banks -side bottom -fill x -after .freq.mfr -anchor s
entry .freq.mfr.ftop -width 20
button .freq.mfr.browse -text "Browse..." -command {filedialog . {{"Frequency Database" {.fdb .chan}}} save .freq.mfr.ftop}
button .freq.mfr.dfreqs -text "Dump Frequencies" -command {.freq.mfr.dfreqs configure -state disabled; .freq.mfr.lfreqs configure -state disabled; dumpsel [.freq.mfr.ftop get] $tx; .freq.mfr.dfreqs configure -state normal; .freq.mfr.lfreqs configure -state normal}
button .freq.mfr.browses -text "Browse..." -command {filedialog . {{"Frequency Database" {.fdb .chan}}} open .freq.mfr.ftop}
button .freq.mfr.lfreqs -text "Load Frequencies" -command {.freq.mfr.dfreqs configure -state disabled; .freq.mfr.lfreqs configure -state disabled; loadfreqs [.freq.mfr.ftop get] $tx; .freq.mfr.dfreqs configure -state normal; .freq.mfr.lfreqs configure -state normal}
pack .freq.mfr.ftop .freq.mfr.browse .freq.mfr.dfreqs .freq.mfr.browses .freq.mfr.lfreqs -side left
#baks stuff
label .freq.banks.lab -text "Banks to dump: "
pack .freq.banks.lab -side left
checkbutton .freq.banks.b_A -text "A" -variable bank_A -relief flat
.freq.banks.b_A select
pack .freq.banks.b_A -side left
foreach {key} {B C D E F G H I J} {
	checkbutton .freq.banks.b_$key -text "$key" -variable bank_$key -relief flat
	.freq.banks.b_$key select
	pack .freq.banks.b_$key -side left
}
toplevel .chanl
wm title .chanl "Channels"
frame .chanl.f -height 16c -width 80c
frame .chanl.b -height 4c -width 80c 
pack .chanl.b -side top -fill y -anchor w
pack .chanl.f -side bottom -fill both -expand 1
scrollbar .chanl.f.scb -command ".chanl.f.clist yview"
#listbox .chanl.f.clist -height 14 -setgrid 1 -width 64 -yscroll ".chanl.f.scb set"
tablelist::tablelist .chanl.f.clist -columns \
	{0 "Channel" left \
	0 "Frequency" left 0 "Alpha Tag" left 0 "Delay" left 0 "L/O" left \
	} -yscrollcommand [list .chanl.f.scb set]
.chanl.f.clist columnconfigure 0 -sortmode integer
#.chanl.f.clist columnconfigure 3 -name delay -editable no -editwindow checkbutton
#.chanl.f.clist columnconfigure 4 -name lockout -editable no -editwindow checkbutton
entry .chanl.b.fet -w 50
button .chanl.b.load -text "Load FDB" -command {filedialog . {{"Frequency Database" {.fdb .chan}}} open .chanl.b.fet; loadtolist [.chanl.b.fet get] .chanl.f.clist }
button .chanl.b.tune -text "Tune Selected" -command {set csel [.chanl.f.clist curselection] ; if {[string length $csel] == 0} {tk_messageBox -message "Nothing selected!" -type ok -icon error} else { tunechan [.chanl.f.clist get $csel]} }
pack .chanl.f.scb -side right -fill y
pack .chanl.f.clist -side left -fill both -expand 1
pack .chanl.b.load .chanl.b.tune -side left 
pack .chanl.b.fet -side right -fill x -expand 1
#wcb::callback $tx before insert rejmod
#wcb::callback $tx before delete rejmod
wm protocol . WM_DELETE_WINDOW {exit}
wm protocol .disp WM_DELETE_WINDOW {exit}
wm resizable . no no
wm protocol .chanl WM_DELETE_WINDOW {exit}
. configure -menu .menubar
if {$windows} {
	wm iconbitmap . -default "beartkat.ico"
}
checkscanner
