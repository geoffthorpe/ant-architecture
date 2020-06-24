# $Id: darwin-ppc.mk,v 1.5 2003/02/19 20:47:52 ellard Exp $
# darwin-ppc.mk
#
# Based on linux-intel.mk.
#
# For the all the *latex files, it assumes they are installed with fink.
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with dynamically-linked
# libraries, for example, strive to disable them by changing LFLAGS.

CC		= /usr/bin/cc
RANLIB		= /usr/bin/ranlib
AR		= /usr/bin/ar
MAKE		= /usr/bin/make
LD		= /usr/bin/ld

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

TK_INC		= -I/usr/local/include -I/usr/X11R6/include
TK_LIBS		= -L/usr/local/lib -ltk8.0 -ltcl8.0 \
			-L/usr/X11R6/lib -lX11 -lm

