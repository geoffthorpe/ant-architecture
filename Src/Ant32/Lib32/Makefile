# $Id: Makefile,v 1.18 2002/01/02 02:29:17 ellard Exp $
#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Makefile for libant32
#
# targets:
# all (default): builds libant32.a
# libant32.a
# clean
# depend

ANTHOSTTYPE := $(shell uname -sm | sed -e 's/ /-/g')
include ../../AntCommon/$(ANTHOSTTYPE).mk

# Choose the options for the ANT you are building...
# Do a "make clean" after changing any of these!

ANT_OPTS	=

ANT_VERSION	= $(ANT_LIB_VERSION)

# From here, things are pretty normal.

LIB		= libant32.a

DEFINES		= $(ANT_OPTS) $(ANT_VERSION)
INCLUDES	= -I../../AntCommon
CFLAGS		= $(CC_OPTIONS) $(INCLUDES) $(DEFINES)

SRC		= arith32.c ant32_mmu.c \
			ant32_pmem.c ant32_except.c ant32_boot.c \
			ant32_debug.c ant32_dbg.c \
			ant32_exec.c ant32_vm.c \
			ant32_load.c ant32_code.c ant32_dump.c \
			ant32_bits.c \
			ant32_core.c ant32_check.c \
			ant32_symtab.c ant32_fault.c \
			ant32_rand.c ant32_expand_op.c \
			ant32_disasm.c ant32_backpatch.c \
			ant32_reg.c
OBJ		= $(SRC:.c=.o)

all:		$(LIB)

build:		$(LIB)

$(LIB):		$(OBJ)
	rm -f $@
	$(AR) rc $@ $(OBJ)
	$(RANLIB) $@

clean:
	rm -f $(LIB) a.out core *.exe *.o *.so *.a *.dll

depend:
	@$(CC) -MM $(INCLUDES) $(SRC)

## end of Makefile

arith32.o: arith32.c arith32.h
ant32_mmu.o: ant32_mmu.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_pmem.o: ant32_pmem.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_except.o: ant32_except.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_boot.o: ant32_boot.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_debug.o: ant32_debug.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_dbg.o: ant32_dbg.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_exec.o: ant32_exec.c ../../AntCommon/ant_external.h \
 ant32_external.h arith32.h
ant32_vm.o: ant32_vm.c ../../AntCommon/ant_external.h ant32_external.h
ant32_load.o: ant32_load.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_dump.o: ant32_dump.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_bits.o: ant32_bits.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_core.o: ant32_core.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_check.o: ant32_check.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_symtab.o: ant32_symtab.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_fault.o: ant32_fault.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_rand.o: ant32_rand.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_expand_op.o: ant32_expand_op.c ../../AntCommon/ant_external.h \
 ant32_external.h
ant32_disasm.o: ant32_disasm.c ant32_external.h \
 ../../AntCommon/ant_external.h
ant32_backpatch.o: ant32_backpatch.c ../../AntCommon/ant_external.h \
 ../../AntCommon/ant_internal.h ant32_external.h
