#api
namespace eval beartkat {
	namespace export docommand
	variable cbs
	namespace export togglelight
	namespace export register
	proc docommand {cmd} {
		return [scommand $cmd]
	}
	proc togglelight {} {
		return [scommand "KEY08"]
	}
	proc register {event callback} {
		lappend cbs $event $callback
	}
}
