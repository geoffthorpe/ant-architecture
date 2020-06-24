# $Id: darwin-ppc-fink.mk,v 1.1 2002/04/30 18:51:00 vernal Exp $
# darwin-ppc.mk
#
# Based on linux-intel.mk.
#
# For all the necessary unix-type functionality, assumes the
# installation of the fink package (similar to FreeBSD ports project).
# The distribution can be found at:
#
# http://fink.sourceforge.net/
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with dynamically-linked
# libraries, for example, strive to disable them by changing LFLAGS.

CC			= /usr/bin/cc
RANLIB		= /usr/bin/ranlib
AR			= /usr/bin/ar
MAKE		= /usr/bin/make
LD			= /usr/bin/ld

FINK_PATH	= /sw

LATEX		= $(FINK_PATH)/bin/pslatex
PDFLATEX	= $(FINK_PATH)/bin/pdflatex
PSNUP		= /usr/bin/false
DVIPS		= $(FINK_PATH)/bin/dvips
MAKEINDEX	= $(FINK_PATH)/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC -DIS_BIG_ENDIAN
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

TK_INC		= -I$(FINK_PATH)/include -I/usr/X11R6/include 
TK_LIBS		= -L$(FINK_PATH)/lib -L/usr/X11R6/lib -ltk -ltcl -lX11 -lm

