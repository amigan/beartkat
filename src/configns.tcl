#config namespace
if {$tcl_platform(platform) == "unix"} {
	set unix yes
	set windows no
} elseif {$tcl_platform(platform) == "windows"} {
	set unix no
	set windows yes
}
namespace eval btkConfig {
	variable ttydev "/dev/cuaa0"
	variable baudrate 19200
	variable interv 1000
	variable notify yes
	namespace export baud
	namespace export serial
	namespace export interval
	namespace export notify
	proc baud {rate} {
		if {[string is integer $rate]} {
			set btkConfig::baudrate $rate
		} else {
			tk_messageBox -message "Error: baud parameter only accepts arguments in the form of an integer. Using default." -type ok -icon error -title "Configuration error"
		}
	}
	proc serial {device} {
		set btkConfig::ttydev $device
	}
	proc interval {seconds} {
		if {[string is double $seconds]} {
			set btkConfig::interv [expr [list int( $seconds * 1000 )]]
		} else {
			tk_messageBox -message "Error: interval parameter only accepts arguments in the form of a number. Using default." -type ok -icon error -title "Configuration error"
		}
	}
	proc prinotif ynms {
		if {$ynms} {
			set btkConfig::notify "yes"
		} elseif {[string equal $ynms "passive"]} {
			set btkConfig::notify "pass"
		} elseif {!$ynms} {
			set btkConfig::notify "no"
		}
	}
}
namespace import btkConfig::baud btkConfig::serial btkConfig::interval btkConfig::prinotif
source beartkat.conf
namespace forget btkConfig::*
