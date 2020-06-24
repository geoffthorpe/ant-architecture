/*
 * $Id: ant8_reg.c,v 1.1 2002/03/08 00:16:48 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/25/01
 *
 */

#include	<stdio.h>

#include	"ant_external.h"
#include	"ant8_external.h"

static	ant_asm_str_id_t	reg_names []	= {
	{ "r0",  0 }, { "r1",  1 }, { "r2",  2 }, { "r3",  3 },
	{ "r4",  4 }, { "r5",  5 }, { "r6",  6 }, { "r7",  7 },
	{ "r8",  8 }, { "r9",  9 }, { "r10",10 }, { "r11",11 },
	{ "r12",12 }, { "r13",13 }, { "r14",14 }, { "r15",15 },
	{ NULL,	 0 }
};

int ant_find_reg (char *str, unsigned int len)
{
	int i;

	if ((i = match_str_id (str, len, reg_names)) >= 0) {
		return (reg_names [i].id);
	}
	else {
		return (-1);
	}
}

/*
 * end of ant8_reg.c
 */
