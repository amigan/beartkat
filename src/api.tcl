#api
namespace eval beartkat {
	namespace export docommand
	proc docommand {cmd} {
		return [scommand $cmd]
	}
	proc togglelight {} {
		return [scommand "KEY08"]
	}
}
