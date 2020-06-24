/*
 * $Id: ant_utils.c,v 1.4 2000/10/31 16:50:45 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * NOTE TO CS50 STUDENTS - You are not expected, for assignment 5, to
 * understand all of the code in this file.  This code uses constructs
 * that have NOT been covered yet (but will be covered later in the
 * semester).
 */

#include	<stdio.h>
#include	<stdlib.h>

#include	"ant.h"

/*
 * Do the work of the "in" instruction, for the given format.
 */

int do_in (int format)
{
	char d [9];
	int val;
	int i;

	switch (format) {
		case IO_HEX :		/* Hex */
			for (i = 0; i < 2; i++) {
				d [i] = getc (stdin);
			}
			d [2] = '\0';

				/*
				 * Read and throw away any extra
				 * characters, until a newline is
				 * reached.
				 */

			while (getc (stdin) != '\n')
				;

			val = strtol (d, NULL, 16);
			break;

		case IO_BINARY : 	/* Binary */
			for (i = 0; i < 8; i++) {
				d [i] = getc (stdin);
			}
			d [8] = '\0';

				/* Eat extra characters. */
			while (getc (stdin) != '\n')
				;

			val = strtol (d, NULL, 2);
			break;

		case IO_ASCII :		/* ASCII */
			val = getc (stdin);
			val = LOWER_BYTE (val);
			break;

		default :
			/* No such peripheral! */
			val = 0;
			break;

	}

	/*
	 * If we're at EOF (which is detected by the feof function)
	 * then set register r1 to 1.  Otherwise, set r1 to 0.
	 */

	AntRegisters [SIDE_REG] = feof (stdin) ? 1 : 0;

	return (val);
}

int do_out (int val, int format)
{
	int i;

	switch (format) {
		case IO_HEX :		/* Hex */
			printf ("%x", LOWER_BYTE (val));
			break;

		case IO_BINARY : 	/* Binary */
			for (i = 7; i >= 0; i--) {
				printf ("%c", (val & (1 << i)) ? '1' : '0');
			}
			break;

		case IO_ASCII :		/* ASCII */
			printf ("%c", val);
			break;

		default :
			/* No such peripheral! */
			break;

	}

	fflush (stdout);
	AntRegisters [SIDE_REG] = 0;
	return (0);
}

/*
 * ant_fault - prints given a fault code and the PC, print an
 * appropriate error message, and dump the ANT's core.
 *
 * Note that this function does NOT cause the ANT VM to exit.
 *
 * Parameters:
 *
 * code - an ant_fault_t value (see ant.h).
 *
 * old_pc - the value of the PC for the instruction that caused the
 * fault.  Used to help generate a meaningful error message.
 */

void ant_fault (ant_fault_t code, int old_pc)
{
	char *description;

	switch (code) {
		case FAULT_ADDR	:
			description = "Bad address";
			break;
		case FAULT_ILL	:
			description = "Illegal instruction";
			break;
		default		:
			description = "Unknown error";
			break;
	}

	printf ("FAULT: (pc = 0x%.2x): %s.\n", old_pc, description);

	ant_dump_text ("ant.core");

	return ;
}

/*
 * end of ant_utils.c
 */
