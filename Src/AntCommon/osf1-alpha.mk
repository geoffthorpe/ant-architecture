# $Id: osf1-alpha.mk,v 1.5 2002/01/02 02:30:23 ellard Exp $
# osf1-alpha.mk

MAKE		= /usr/local/bin/gmake
CC		= /usr/local/gnu/bin/gcc
RANLIB		= /usr/local/gnu/bin/ranlib
AR		= /usr/local/gnu/bin/ar
LD		= /usr/ucb/ld

LATEX		= /usr/local/bin/pslatex
PDFLATEX	= /usr/local/bin/pdflatex
PSNUP		= /usr/local/bin/psnup
DVIPS		= /usr/local/bin/dvips
MAKEINDEX	= /usr/local/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS) -static

TK_INC		= -I/usr/local/include
TK_LIBS		= -L/usr/local/lib -ltk8.0 -ltcl8.0 -lX11 -lm -ldnet_stub
