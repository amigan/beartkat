# sourced from main
proc scommand {command} {
	global fhn
	global lastin
	global lastcmd
	puts $fhn $command
	flush $fhn
	set lastcmd $command
	vwait lastin
	return $lastin
}
proc sendcommand {cmd} {
	global lastcmd
	global fhn
	puts $fhn $cmd
	flush $fhn
	set lastcmd $cmd
}
