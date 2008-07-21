# sourced from main
proc scommand {command} {
	global fhn
	global lastin
	global lastcmd
	global realmode
	set lastcmd $command
	if {$realmode} {
		puts $fhn $command
		flush $fhn
		vwait lastin
		return $lastin
	} else {
		return OK
	}
}
proc sendcommand {cmd} {
	global lastcmd
	global fhn
	global realmode
	set lastcmd $cmd
	if {$realmode} {
		puts $fhn $cmd
		flush $fhn
	}
}
