#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Makefile for .../Src/Ant32/... programs
#
# targets:
# all (default): builds aa32, ant32
# aa32
# ant32
# clean
# test: to test the executables
# depend

AA32_EXE	= aa32
ANT32_EXE	= ant32
AD32_EXE	= ad32
AIDE32_EXE	= aide32

ANTHOSTTYPE := $(shell uname -sm | sed -e 's/ /-/g')

include ../AntCommon/$(ANTHOSTTYPE).mk

# Choose the options for the ANT you are building...
# Do a "make clean" after changing any of these!

ANT_OPTS	=

ANT_VERSION	= $(ANT_LIB_VERSION)

DEFINES		= $(ANT_OPTS) $(ANT_VERSION)
INCLUDES	= -I../AntCommon -I./Lib32
CFLAGS		= $(CC_OPTIONS) $(INCLUDES) $(DEFINES)

ANT32DEP	= libant32 libant
ANT32LIB	= ./Lib32/libant32.a ../AntCommon/libant.a

# EXTRA_OBJ exists to create a workaround for a bug in the
# Darwin linker, which gets confused by global variables sometimes,
# especially when they're in libraries.

EXTRA_OBJ	= ../AntCommon/ant_error.o

AA32_SRC	= aa32.c ant32_reg.c
AA32_OBJ	= $(AA32_SRC:.c=.o) $(EXTRA_OBJ)

ANT32_SRC	= ant32.c
ANT32_OBJ	= $(ANT32_SRC:.c=.o) $(EXTRA_OBJ)

AD32_SRC	= ad32.c ad32_util.c ant32_reg.c
AD32_OBJ	= $(AD32_SRC:.c=.o) $(EXTRA_OBJ)

AIDE32_SRC	= aide32_wish.c
AIDE32_OBJ	= $(AIDE32_SRC:.c=.o) $(EXTRA_OBJ)

EXECUTABLES	= $(AA32_EXE) $(ANT32_EXE) $(AD32_EXE) $(AIDE32_EXE)
SOURCES     	= $(AA32_SRC) $(ANT32_SRC) $(AD32_SRC) $(AIDE32_SRC)

all:		$(ANT32DEP) $(EXECUTABLES) ant32rom.a32

$(AIDE32_EXE):		$(ANT32LIB) $(AIDE32_OBJ) $(ANT32DEP)
	$(LINK) -o $@ $(AIDE32_OBJ) $(LFLAGS)  $(ANT32LIB) $(TK_LIBS) 

ant32rom.a32:	$(AA32_EXE)
	./$(AA32_EXE) -o $@ -a 0xbfffc000 rom.asm

$(AA32_EXE):		$(AA32_OBJ) $(ANT32DEP)
	$(LINK) -o $@ $(LFLAGS) $(AA32_OBJ) $(ANT32LIB)

$(ANT32_EXE):		$(ANT32_OBJ) $(ANT32DEP)
	$(LINK) -o $@ $(LFLAGS) $(ANT32_OBJ) $(ANT32LIB)

$(AD32_EXE):		$(ANT32LIB) $(AD32_OBJ) $(ANT32DEP)
	$(LINK) -o $@ $(LFLAGS) $(AD32_OBJ) $(ANT32LIB)


test:           $(ANT32_EXE)-test $(AA32_EXE)-test

$(ANT32_EXE)-test:      $(ANT32_EXE)
	Tests/$(ANT32_EXE)-test --quiet +all ./$(ANT32_EXE)

$(AA32_EXE)-test:       $(AA32_EXE)
	Tests/$(AA32_EXE)-test --quiet +all ./$(AA32_EXE)

# Targets to make sure that the sub libraries are properly built. 
# These targets should ensure that the libraries are up-to-date.
# however.

libant32:
	cd Lib32;		$(MAKE)

libant:
	cd ../AntCommon;	$(MAKE)

clean:
	rm -f $(EXECUTABLES) a.out core *.exe *.o *.so *.a *.dll
	cd Lib32;		$(MAKE) $@
	cd ../AntCommon;	$(MAKE) $@

depend:
	@$(CC) -MM $(INCLUDES) $(SOURCES)

# No CC_OPTIONS, because the gcc compiler gripes about the X library
# too much when all the warnings are turned on!

aide32_ide.o: aide32_ide.c
	$(CC) $(CC_OPT_BASE) $(INCLUDES) $(TK_INC) $(DEFINES) -c aide32_ide.c

aide32_wish.o:	aide32_wish.c
	$(CC) $(CC_OPT_BASE) $(INCLUDES) $(TK_INC) $(DEFINES) -c aide32_wish.c

## end of Makefile

aa32.o: aa32.c ../AntCommon/ant_external.h Lib32/ant32_external.h
ant32.o: ant32.c ../AntCommon/ant_external.h Lib32/ant32_external.h
ad32.o: ad32.c Lib32/ant32_external.h ../AntCommon/ant_external.h \
 ad32_util.h
ad32_util.o: ad32_util.c Lib32/ant32_external.h \
 ../AntCommon/ant_external.h ad32_util.h
aide32_ide.o: aide32_ide.c Lib32/ant32_external.h \
 ../AntCommon/ant_external.h
aide32_wish.o: aide32_wish.c Lib32/ant32_external.h \
 ../AntCommon/ant_external.h aide32_gui.h
