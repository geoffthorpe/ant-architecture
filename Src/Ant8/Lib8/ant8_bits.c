/*
 * $Id: ant8_bits.c,v 1.4 2002/10/09 23:51:46 ellard Exp $
 *
 * Dan Ellard -- 11/20/96 -- cs50
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_bits.c -- Functions for extracting the specified fields from an
 * ANT instruction word.  These make copious use of the macros defined
 * in ant_bits.h and ant_mach.h-- so much so that there is very little
 * left to do here.
 */

/*
	The ANT instructions look like the following:

	---------------------------------------------------
	| Operator | Register 1 | Register 2 | Register 3 |
	| (4 bits) |  (4 bits)  |  (4 bits)  |  (4 bits)  |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 |        Constant         |
	| (4 bits) |  (4 bits)  |        (8 bits)         |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 | Register 2 |  Constant  |
	| (4 bits) |  (4 bits)  |  (4 bits)  |  (4 bits)  |
	---------------------------------------------------

	These instructions extract the op, reg1, reg2, reg3,
	or const fields from an ANT instruction word.
*/

#include	<stdio.h>

#include	"ant8_external.h"
#include	"ant8_internal.h"


unsigned int ant_get_op (long inst)
{
	return (GET_NIBBLE (inst, OP_NIBBLE));
}

unsigned int ant_get_reg1 (long inst)
{
	return (GET_NIBBLE (inst, REG1_NIBBLE));
}

unsigned int ant_get_reg2 (long inst)
{
	return (GET_NIBBLE (inst, REG2_NIBBLE));
}

unsigned int ant_get_reg3 (long inst)
{
	return (GET_NIBBLE (inst, REG3_NIBBLE));
}

unsigned int ant_get_uconst4 (long inst)
{
	return (GET_NIBBLE (inst, CONST_NIBBLE));
}

int		ant_get_const8 (long inst)
{
	return (GET_BYTE (inst, CONST_BYTE));
}

/*
 * end of ant_bits.c
 */
