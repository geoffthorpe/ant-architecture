/*
 * $Id: ant32_bits.c,v 1.4 2002/01/02 02:29:17 ellard Exp $
 *
 * Dan Ellard -- 08/04/99
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant32_bits.c -- Functions for extracting the specified fields from
 * an ANT instruction word.  These make copious use of the macros
 * defined in ant_bits.h and ant_mach.h-- so much so that there is
 * very little left to do here.
 */

/*
	The ANT instructions look like the following:

	---------------------------------------------------
	| Operator | Register 1 | Register 2 | Register 3 |
	| (8 bits) |  (8 bits)  |  (8 bits)  |  (8 bits)  |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 |        Constant         |
	| (8 bits) |  (8 bits)  |        (16 bits)        |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 | Register 2 |  Constant  |
	| (8 bits) |  (8 bits)  |  (8 bits)  |  (8 bits)  |
	---------------------------------------------------

	These instructions extract the op, reg1, reg2, reg3,
	or const fields from an ANT instruction word.

	Note that in the current ANT-32 architecture, the top two bits
	of each register are IGNORED, so there is a 6-bit register
	space instead of a true 8-bit address space.  These bits are
	reserved for future use.

*/

#include	<stdio.h>

#include	"ant32_external.h"


unsigned int ant_get_op (ant_inst_t inst)
{
	return (GET_BYTE (inst, OP_BYTE));
}

unsigned int ant_get_reg1 (ant_inst_t inst)
{
	return (GET_BYTE (inst, REG1_BYTE));
}

unsigned int ant_get_reg2 (ant_inst_t inst)
{
	return (GET_BYTE (inst, REG2_BYTE));
}

unsigned int ant_get_reg3 (ant_inst_t inst)
{
	return (GET_BYTE (inst, REG3_BYTE));
}

unsigned int ant_get_const8u (ant_inst_t inst)
{
	return (GET_BYTE (inst, CONST_BYTE));
}

int ant_get_const8 (ant_inst_t inst)
{
	int val = GET_BYTE (inst, CONST_BYTE);

	if ((val & (1 << (BITS_PER_BYTE - 1))) != 0) {
		val -= (1 << BITS_PER_BYTE);
	}

	return (val);
}

unsigned int	ant_get_const16u (ant_inst_t inst)
{
	return (GET_HWORD (inst, CONST_HWORD));
}

int ant_get_const16 (ant_inst_t inst)
{
	int val = GET_HWORD (inst, CONST_HWORD);

	if ((val & (1 << (BITS_PER_HWORD - 1))) != 0) {
		val -= (1 << BITS_PER_HWORD);
	}

	return (val);
}

/*
 * end of ant32_bits.c
 */
