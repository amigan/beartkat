# Example BearTKat script
# gets info, toggles light, switches to weather and back again
# (C)2004, 2005 Dan Ponte
puts "Loading..."
puts [beartkat::docommand "SI"]
beartkat::togglelight
after 1000 {beartkat::togglelight; after 1000 {beartkat::togglelight;after 1000 beartkat::togglelight}}
beartkat::docommand "KEY10"
beartkat::docommand "KEY02 1"
after 5000 {beartkat::docommand "KEY01"}
