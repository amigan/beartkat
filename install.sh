#!/bin/sh
# $Amigan: beartkat/install.sh,v 1.1 2005/03/10 01:14:28 dcp1990 Exp $
PREFIX=/usr/X11R6
echo "beartkat installer"
install -d ${PREFIX}/lib/beartkat/
install src/*.tcl src/*.conf ${PREFIX}/lib/beartkat/
cat > ${PREFIX}/bin/beartkat <<EDS
#!/usr/local/bin/wish8.4
cd ${PREFIX}/lib/beartkat/
source beartkat.tcl
EDS
chmod +x ${PREFIX}/bin/beartkat
