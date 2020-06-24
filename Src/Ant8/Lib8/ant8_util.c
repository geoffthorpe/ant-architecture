/*
 * $Id: ant8_util.c,v 1.3 2001/01/02 15:30:04 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_util.c --
 *
 */

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

void ant_assign_des_reg (ant_data_t *regs, int des_reg, ant_data_t val)
{

	if ((des_reg != ZERO_REG) && (des_reg != SIDE_REG)) {
		regs [des_reg] = val;
	}

	return ;
}

void ant_word2bits (int word, char *buf)
{
	int i;

	for (i = ANT_DATA_BITS - 1; i >= 0; i--) {
		buf [ANT_DATA_BITS - i - 1] = (word & (1 << i)) ? '1' : '0';
	}

	buf [ANT_DATA_BITS] = '\0';

	return ;
}

void ant_print_value_str (char *buf, int value, char *label)
{
	char bits [ANT_DATA_BITS + 1];

	buf [0] = '\0';

	ant_word2bits (LOWER_BYTE (value), bits);

	sprintf (buf + strlen (buf), "%4d  0x%.2x  0%.3o  0b%.8s",
			(char) value,
			LOWER_BYTE (value),
			LOWER_BYTE (value),
			bits);

	/*
	 * On some systems, isprint is broken and needs to be
	 * protected.
	 */


	if ((value > 0 && value <= 127) && (isprint (LOWER_BYTE (value)))) {
		sprintf (buf + strlen (buf),
				"  '%c'  ", LOWER_BYTE (value));
	}
	else {
		sprintf (buf + strlen (buf), "  ###  ");
	}

	if (label != NULL) {
		sprintf (buf + strlen (buf), "  $%s", label);
	}

	return ;
}

void ant_print_value (FILE *stream, int value, char *label)
{
	char buf [1024];

	ant_print_value_str (buf, value, label);

	fprintf (stream, "%s", buf);

	return ;
}

/*
 * end of ant_util.c
 */
