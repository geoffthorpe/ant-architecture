/*
 * $Id: antvm.c,v 1.3 2000/05/16 19:13:46 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 09/14/97 -- cs50
 *
 * antvm.c -- The home of the main function of ant, an ANT virtual
 * machine.  This file is utterly incomplete, and provided only as the
 * most basic starting point.
 */

/*
 * Standard header files:
 */

#include	<stdio.h>

/*
 * Header files specific to ANT:
 */

#include	"ant.h"

/*
 * The following global variables define the entire state of the ANT
 * machine:  the PC, the contents of the registers, and memory.
 */

ant_pc_t	AntPC;
char		AntRegisters [ANT_REG_RANGE];
char		AntMemory [ANT_ADDR_RANGE];

int ant_exec (void);

/*
 * main -- the main function of the ant program.
 */

int main (int argc, char **argv)
{
	char *ant_program;
	int rc;

	ant_program = ant_get_prog_name (argc, argv);
	if (ant_program == NULL) {
		rc = 1;
	} else {
		rc = ant_load_text (ant_program);
		if (rc != 0) {
			printf ("ERROR: Couldn't load [%s].\n", ant_program);
			exit (1);
		}

		rc = ant_exec ();
	}
	return (rc);
}

/*
 * ant_exec - the function that actually executes an ANT VM.
 *
 * Returns 0 if the machine halted by executing a HALT instruction, or
 * non-zero if a fault was detected.  (In essence, the return value
 * should be treated as a boolean value that signifies whether
 * execution halted due to failure.)
 */

int ant_exec (void)
{

	return (0);
}

/*
 * end of antvm.c
 */
