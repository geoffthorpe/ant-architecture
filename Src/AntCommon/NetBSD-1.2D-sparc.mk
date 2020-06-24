# $Id: NetBSD-1.2D-sparc.mk,v 1.2 2002/01/02 02:30:23 ellard Exp $
# blank.mk
#
# Blank template for architecture-dependent files to set up environment
# variables to create portable makefiles, etc.
#
# A kludge, but a relatively minor one...
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are
# correct for many systems but not for all.  On systems with
# dynamically-linked libraries, for example, strive to disable them
# by changing LFLAGS.

setenv 	MAKE	"make"
setenv	CC	"gcc"
setenv	CFLAGS	"-Wall -O -pedantic"
setenv	LINK	"$CC"
setenv	LFLAGS	"$CFLAGS -static"
setenv	RANLIB	"ranlib"
setenv	AR	"ar"


