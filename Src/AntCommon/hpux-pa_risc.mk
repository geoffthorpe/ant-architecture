# $Id: hpux-pa_risc.mk,v 1.2 2002/01/02 02:30:23 ellard Exp $
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

MAKE	= make
CC	= gcc
CFLAGS	= -Wall -O -pedantic
LINK	= $(CC)
LFLAGS	= $(CFLAGS) -static
RANLIB	= true
AR	= ar

TK_INC	= DUNNO
TK_LIBS	= DUNNO

