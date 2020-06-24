# $Id: freebsd-intel.mk,v 1.6 2006/08/31 11:45:24 ellard Exp $
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

CC		= /usr/bin/gcc
RANLIB		= /usr/bin/ranlib
AR		= /usr/bin/ar
MAKE		= /usr/bin/make
LD		= /usr/bin/ld

LATEX		= /usr/local/bin/pslatex
PDFLATEX	= /usr/local/bin/pdflatex
PSNUP		= /usr/local/bin/psnup
DVIPS		= /usr/local/bin/dvips
MAKEINDEX	= /usr/local/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

TK_INC		= -I/usr/X11R6/include \
			-I/usr/local/include/tk8.2 \
			-I/usr/local/include/tcl8.2
TK_LIBS		= -L/usr/local/lib/ -ltk82 -ltcl82 \
			-static -L/usr/X11R6/lib -lX11 -lm

