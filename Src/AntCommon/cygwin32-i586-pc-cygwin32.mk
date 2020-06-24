# $Id: cygwin32-i586-pc-cygwin32.mk,v 1.3 2002/01/02 02:30:23 ellard Exp $
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

AA_EXE		= aa.exe
AD_EXE		= ad.exe
ANT_EXE		= ant.exe
AIDE_EXE	= aide.exe

MAKE		= make
AIDE8_FLAGS	= -mwindows
CC		= gcc
CC_OPT_BASE	= -g -O -DWINTEL
CC_WARNING	= -W -Wall -Wno-char-subscripts -pedantic
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC) -static
LFLAGS		= $(CFLAGS)
RANLIB		= ranlib
AR		= ar

TK_INC	=
TK_LIBS	= -L//d/cygnus/cygwin-b20/H-i586-cygwin32/lib -ltk80 -ltcl80

