/*
 * $Id: ant.h,v 1.4 2000/10/31 16:50:45 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant.h -- General grab-bag header file for ANT programs.
 */

#ifndef	_ANT_H_
#define	_ANT_H_

#include	<stdio.h>

#include	"ant_bits.h"
#include	"ant_mach.h"

/*
 * Functions from ant_load.c:
 */

int		ant_load_text (char *filename);
char		*ant_get_prog_name (int argc, char **argv);
void		ant_clear (void);

/*
 * Functions from ant_dump.c:
 */

int		ant_dump_text (char *filename);
int		ant_print_reg (FILE *stream);
int		ant_print_memory (FILE *stream);

/*
 * Functions from ant_utils.c:
 */

void		ant_fault (ant_fault_t code, int pc);
int		do_in (int format);
int		do_out (int val, int format);

/*
 * Declarations for the global variables that implement the state of
 * the ANT VM:  the PC, the registers, data, and instruction memory.
 *
 * (CS50 students-- don't worry about what the "extern" keyword means
 * yet.)
 */

extern	ant_pc_t	AntPC;
extern	char		AntRegisters [ANT_REG_RANGE];
extern	char		AntMemory [ANT_ADDR_RANGE];

/*
 * end of ant.h
 */

#endif	/* _ANT_H_ */
