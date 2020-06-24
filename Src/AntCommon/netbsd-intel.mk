# $Id: netbsd-intel.mk,v 1.2 2002/01/02 02:30:23 ellard Exp $
# netbsd-intel.mk
#
# Based on linux-intel.mk. Should actually work for any netbsd platform...
# I'm not sure the tcl stuff is correct though.
#
# A kludge, but a relatively minor one...
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with
# dynamically-linked libraries, for example, strive to disable them by
# changing LFLAGS.

CC		= gcc
RANLIB		= ranlib
AR		= ar
MAKE		= gmake
LD		= ld

LATEX		= latex
PDFLATEX	= false
PSNUP		= false
DVIPS		= dvips
MAKEINDEX	= false

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

TK_INC		= 
TK_LIBS		= -static -L/usr/pkg/lib -ltk8.0 -ltcl8.0 -L/usr/X11R6/lib -lX11 -lm -ldl

