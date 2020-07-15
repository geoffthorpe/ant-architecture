# $Id: linux-intel.mk,v 1.8 2003/02/19 21:42:44 ellard Exp $
# linux-intel.mk
#
# Based on a blank template for architecture-dependent files to set up
# environment variables to create portable makefiles, etc.
#
# A kludge, but a relatively minor one...
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with
# dynamically-linked libraries, for example, strive to disable them by
# changing LFLAGS.

CC		= /usr/bin/gcc
RANLIB		= /usr/bin/ranlib
AR		= /usr/bin/ar
MAKE		= /usr/bin/make
LD		= /usr/bin/ld -G -z text

LATEX		= /usr/bin/pslatex
PDFLATEX	= /usr/bin/pdflatex
PSNUP		= false
DVIPS		= /usr/bin/dvips
MAKEINDEX	= /usr/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

#TK_INC		= -I/home/lair/ant/usr/linux-intel/include
#TK_LIBS		= -L/home/lair/ant/usr/linux-intel/lib -ltk8.0 -ltcl8.0 \
#			-L/usr/X11R6/lib -lX11 -lm -ldl

#TK_INC		= -I/groups/ant/usr/linux-intel/include
#TK_LIBS		= -L/groups/ant/usr/linux-intel/lib \
#			-ltk8.0 -ltcl8.0 \
#			-L/usr/lib -lX11 -lm -ldl

TK_INC		= -I/usr/include/tcl8.6
TK_LIBS		= \
			-ltk8.6 -ltcl8.6 \
			-L/usr/lib -lX11 -lm -ldl

