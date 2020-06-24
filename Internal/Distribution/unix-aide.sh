#!/bin/csh -f
#
# $Id: unix-aide.sh,v 1.1 2002/04/17 16:26:22 ellard Exp $

set     full_path       = $0
set     full_dir        = "$full_path:h"
set	prog_name	= "$full_path:t"
set     lib_dir         = "$full_dir/../lib"

setenv  TK_LIBRARY      "$lib_dir/tk8.0"
setenv  TCL_LIBRARY     "$lib_dir/tcl8.0"

exec "$full_dir/_$prog_name"

exit 1

