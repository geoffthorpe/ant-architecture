#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Makefile for .../Src/Ant8/...
#
# targets:
# all (default): builds aa8 ad8 aide8 ant8
# aa8
# ad8
# aide8
# ant8
# clean
# test: tests the executables
# depend

ANTHOSTTYPE := $(shell uname -sm | sed -e 's/ /-/g')

AA8_EXE		= aa8
AD8_EXE		= ad8
AIDE8_EXE	= aide8
ANT8_EXE	= ant8

include ../AntCommon/$(ANTHOSTTYPE).mk

# Choose the options for the ANT you are building...
# Do a "make clean" after changing any of these!

ANT_OPTS	=
ANT_VERSION	= $(ANT_LIB_VERSION)
DEFINES		= $(ANT_OPTS) $(ANT_VERSION)
INCLUDES	= -I../AntCommon -I./Lib8
CFLAGS		= $(CC_OPTIONS) $(INCLUDES) $(DEFINES)

ANT8DEP		= libant8 libant
ANT8LIB		= ./Lib8/libant8.a ../AntCommon/libant.a

AA8_SRC		= aa8.c ant8_reg.c
AD8_SRC		= ad8.c ad8_util.c ad8_help.c ant8_reg.c
AIDE8_SRC	= aide8_ide.c aide8_wish.c aide8_gui.c ant8_reg.c
ANT8_SRC	= ant8.c 

# EXTRA_OBJ exists to create a workaround for a bug in the
# Darwin linker, which gets confused by global variables sometimes,
# especially when they're in libraries.

EXTRA_OBJ	= ../AntCommon/ant_error.o

AA8_OBJ		= $(AA8_SRC:.c=.o) $(EXTRA_OBJ)
AD8_OBJ		= $(AD8_SRC:.c=.o) $(EXTRA_OBJ)
AIDE8_OBJ	= $(AIDE8_SRC:.c=.o) $(EXTRA_OBJ)
ANT8_OBJ	= $(ANT8_SRC:.c=.o) $(EXTRA_OBJ)

EXECUTABLES     = $(AA8_EXE) $(AD8_EXE) $(AIDE8_EXE) $(ANT8_EXE)
SOURCES		= $(AA8_SRC) $(AD8_SRC) $(AIDE8_SRC) $(ANT8_SRC)

all:		$(ANT8DEP) $(EXECUTABLES)

$(AA8_EXE):	$(AA8_OBJ) $(ANT8DEP)
	$(LINK) -o $@ $(LFLAGS) $(AA8_OBJ) $(ANT8LIB)

$(AD8_EXE):	$(AD8_OBJ) $(ANT8DEP)
	$(LINK) -o $@ $(LFLAGS) $(AD8_OBJ) $(ANT8LIB)

$(AIDE8_EXE):	$(AIDE8_OBJ) $(ANT8DEP)
	$(LINK) $(AIDE8_FLAGS) -o $@ $(LFLAGS) $(AIDE8_OBJ) $(ANT8LIB) $(TK_LIBS)

$(ANT8_EXE):	$(ANT8_OBJ) $(ANT8DEP)
	$(LINK) -o $@ $(LFLAGS) $(ANT8_OBJ) $(ANT8LIB)

test:		$(ANT8_EXE)-test $(AA8_EXE)-test

$(ANT8_EXE)-test:	$(ANT8_EXE)
	Tests/$(ANT8_EXE)-test --quiet +all ./$(ANT8_EXE)

$(AA8_EXE)-test:	$(AA8_EXE)
	Tests/$(AA8_EXE)-test --quiet +all ./$(AA8_EXE)

# Targets to make sure that the sub libraries are properly built. 
# These targets should ensure that the libraries are up-to-date.

libant8:
	cd Lib8;		$(MAKE)

libant:
	cd ../AntCommon;	$(MAKE)

clean:
	rm -f $(EXECUTABLES) a.out core *.exe *.o *.so *.a *.dll
	cd Lib8;		$(MAKE) $@
	cd ../AntCommon;	$(MAKE) $@

depend:
	@$(CC) -MM $(INCLUDES) $(SOURCES)

# No CC_OPTIONS, because the gcc compiler gripes about the X library
# too much when all the warnings are turned on!

aide8_ide.o: aide8_ide.c
	$(CC) $(CC_OPT_BASE) $(INCLUDES) $(TK_INC) $(DEFINES) -c aide8_ide.c

aide8_wish.o: aide8_wish.c
	$(CC) $(CC_OPT_BASE) $(INCLUDES) $(TK_INC) $(DEFINES) -c aide8_wish.c

## end of Makefile

aa8.o: aa8.c Lib8/ant8_external.h ../AntCommon/ant_external.h
ant8_reg.o: ant8_reg.c ../AntCommon/ant_external.h \
 Lib8/ant8_external.h
ad8.o: ad8.c Lib8/ant8_external.h ../AntCommon/ant_external.h \
 ad8_util.h
ad8_util.o: ad8_util.c Lib8/ant8_external.h \
 ../AntCommon/ant_external.h ad8_util.h
ad8_help.o: ad8_help.c Lib8/ant8_external.h \
 ../AntCommon/ant_external.h
ant8_reg.o: ant8_reg.c ../AntCommon/ant_external.h \
 Lib8/ant8_external.h
aide8_gui.o: aide8_gui.c Lib8/ant8_external.h \
 ../AntCommon/ant_external.h aide8_gui.h
ant8_reg.o: ant8_reg.c ../AntCommon/ant_external.h \
 Lib8/ant8_external.h
ant8.o: ant8.c Lib8/ant8_external.h ../AntCommon/ant_external.h
