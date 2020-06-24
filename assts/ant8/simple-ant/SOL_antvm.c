/*
 * $Id: SOL_antvm.c,v 1.7 2000/10/30 04:26:19 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * SOL_antvm.c -- Example solution to antvm.c, with running commentary
 * and plenty of filler.
 */

#include	<stdio.h>

#include	"ant.h"

/*
 * The following global variables define the entire state of the ANT
 * machine:  the PC, the contents of the registers, and memory.
 */

ant_pc_t	AntPC;
char		AntRegisters [ANT_REG_RANGE];
char		AntMemory [ANT_ADDR_RANGE];

int ant_exec (void);

int ant_exec_inst (void);
int ant_exec (void);
void set_arith_r1 (int val);
void assign_reg (int reg, int val);

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
	}
	else {
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
 * ant_exec - the function that actually executes an ANT VM, executing
 * individual instructions until the ANT halts or encounters a fault.
 *
 * Returns 0 if the machine halted via a HALT syscall, or non-zero if
 * a fault was detected.  (In essence, the return value should be
 * treated as a boolean value that signifies whether execution halted
 * due to failure.)
 *
 * This function doesn't do all that much-- it's basically a loop that
 * keeps calling ant_exec_inst repeatedly until it returns a non-zero
 * code, indicating that something interesting has happened.  At that
 * point, it figures out what happened and what to return to the
 * caller.
 */

int ant_exec (void)
{
	int rc;

	while ((rc = ant_exec_inst ()) == 0)
		;

	if (rc >= 0) {
		return (0);
	}
	else {
		return (rc);
	}
}

/*
 * ant_exec_inst --
 *
 * Execute a single instruction.
 *
 * Returns zero if nothing exceptional happened, a negative number if
 * there was a fault of any kind, or a positive number if a HALT
 * instruction was executed.
 *
 * The execution of each instruction is implemented in a giant switch
 * statement.  This could be implemented as a bunch of little
 * functions, but there doesn't seem to be much benefit to this.  The
 * most repetitious activities, such as checking that the destination
 * register isn't r0 or r1, or checking for arithmetic overflow, are
 * handled in seperate functions.
 */

int ant_exec_inst (void)
{
	int op, r1, r2, r3, const8i, const4;
	int val, old_pc;
	ant_io_t channel;
	char const8c;
	int inst_lo_byte, inst_hi_byte;

	/*
	 * Grab a copy of the current PC.  It's useful to know
	 * what the actual address of the program being executed is,
	 * so we can have a copy of it if we want print plausible
	 * error messages if there's an error, and yet we can mess
	 * around with the actual PC it as appropriate
	 */

	old_pc = AntPC;

	/*
	 * Fetch the instruction and increment in the PC so that it
	 * points to the next instruction.
	 */

	inst_lo_byte = AntMemory [AntPC + 0];
	inst_hi_byte = AntMemory [AntPC + 1];

	AntPC += 2;

	/*
	 * Now pluck apart the instruction into all its possible
	 * components.  The actual fields we'll use later depend on
	 * the instruction being executed; no single instruction
	 * actually uses all of these.  However, doing this all at
	 * once means that we don't have to reproduce the code for
	 * teasing apart the instruction all over the place-- just do
	 * it once and be done with it.
	 */

	op = UPPER_NIBBLE (inst_lo_byte);
	r1 = LOWER_NIBBLE (inst_lo_byte);
	r2 = UPPER_NIBBLE (inst_hi_byte);
	r3 = LOWER_NIBBLE (inst_hi_byte);
	const4 = LOWER_NIBBLE (inst_hi_byte);
	const8i = LOWER_BYTE (inst_hi_byte);
	channel = LOWER_NIBBLE (inst_hi_byte);

	/*
	 * Here is a slightly subtle point-- const8i (which was just
	 * set) is an integer constant that ranges from 0..255.  For
	 * the arithmetic ops, we really want a signed 8-bit quantity. 
	 * There are several ways to achieve this; one easy way is to
	 * simply toss the bits into a signed char (const8c) and then
	 * use this char.
	 */

	const8c = const8i;

	switch (op) {
		case OP_ADD	:
			val = AntRegisters [r2] + AntRegisters [r3];
			assign_reg (r1, LOWER_BYTE (val));
			set_arith_r1 (val);
			break;

		case OP_SUB	:
			val = AntRegisters [r2] - AntRegisters [r3];
			assign_reg (r1, LOWER_BYTE (val));
			set_arith_r1 (val);
			break;

		case OP_MUL	:
			val = AntRegisters [r2] * AntRegisters [r3];
			assign_reg (r1, LOWER_BYTE (val));
			AntRegisters [SIDE_REG] = UPPER_BYTE (val);
			break;

		case OP_AND	:
			val = AntRegisters [r2] & AntRegisters [r3];
			AntRegisters [SIDE_REG] = ~val;
			assign_reg (r1, val);
			break;

		case OP_NOR	:
			val = ~(AntRegisters [r2] | AntRegisters [r3]);
			AntRegisters [SIDE_REG] = ~val;
			assign_reg (r1, val);
			break;

		case OP_SHF	:
			if (AntRegisters [r3] >= 0) {
				val = AntRegisters [r2] << AntRegisters [r3];
			}
			else {
				unsigned char t = AntRegisters [r2];

				val = t >> -AntRegisters [r3];
			}
			assign_reg (r1, val);
			AntRegisters [SIDE_REG] = 0;
			break;

		case OP_BEQ	:

			if (AntRegisters [r2] == AntRegisters [r3]) {
				AntPC = (ant_pc_t) AntRegisters [r1];
			}
			break;

		case OP_BGT	:

			/*
			 * Almost the same as BEQ.  Beware of
			 * cut-and-paste errors that stem from this
			 * similarity.
			 */

			if (AntRegisters [r2] > AntRegisters [r3]) {
				AntPC = (ant_pc_t) AntRegisters [r1];
			}
			break;

		case OP_LD1	:

			/*
			 * Make sure that the destination is OK first. 
			 *
			 * Next do the address calculation, carefully
			 * checking for overflow.  Note that the value
			 * of the register r2 is treated as unsigned
			 * here-- using LOWER_BYTE to convert it to an
			 * integer will do so without sign extension,
			 * which is exactly what you want.
			 *
			 * Once the address has been checked, go to
			 * memory and get the data.
			 */

			val = LOWER_BYTE (AntRegisters [r2]) + const4;
			if (val < 0 || val >= ANT_ADDR_RANGE) {
				ant_fault (FAULT_ADDR, old_pc);
				return (-1);
			}

			assign_reg (r1, AntMemory [val]);
			break;

		case OP_ST1	:

			/*
			 * Like OP_LD1, but backwards.  It's not an
			 * error if r0 or r1 are the first register--
			 * it's OK to *store* these registers, just
			 * not load into them.
			 */

			val = LOWER_BYTE (AntRegisters [r2]) + const4;
			if (val < 0 || val >= ANT_ADDR_RANGE) {
				ant_fault (FAULT_ADDR, old_pc);
				return (-1);
			}

			AntMemory [val] = AntRegisters [r1];
			break;

		case OP_JMP	:

			/*
			 * Note use of const8i, because the PC is
			 * unsigned (0..255).
			 */

			AntRegisters [SIDE_REG] = AntPC;
			AntPC = const8i;
			break;

		case OP_INC	:

			/*
			 * Note use of const8c, to make sure that the
			 * increment is done using signed arithmetic.
			 */

			val = AntRegisters [r1] + const8c;
			assign_reg (r1, val);
			set_arith_r1 (val);
			break;

		case OP_LC	:
			assign_reg (r1, const8i);
			break;

		case OP_IN	:
			val = do_in (channel);
			assign_reg (r1, val);
			break;

		case OP_OUT	:
			do_out (AntRegisters [r2], channel);
			break;

		case OP_HALT	:
			ant_dump_text ("ant.core");
			AntPC = const8i;
			return (1);
			break;

		default		:

			/*
			 * There aren't actually any more
			 * possibilities than there are instructions--
			 * but it's always good to be prepared, in case
			 * you forget an instruction!
			 */
			 
			ant_fault (FAULT_ILL, old_pc);
			return (-1);
			break;
	}

	return (0);
}

/*
 * set_arith_r1 -- boilerplate for dealing with detecting overflow and
 * underflow.  Based on the val, set r1 to be 1 (if val is larger than
 * MAX_ANT_INT), -1 (if val is smaller than MIN_ANT_INT), or 0.
 */

void set_arith_r1 (int val)
{

	if (val > MAX_ANT_INT) {
		AntRegisters [SIDE_REG] = 1;
	}
	else if (val < MIN_ANT_INT) {
		AntRegisters [SIDE_REG] = -1;
	}
	else {
		AntRegisters [SIDE_REG] = 0;
	}

	return ;
}

/*
 * Assign the given val to the specified register, but only if
 * the register isn't r0 or r1.  (registers r0 and r1 are never
 * directly assigned values.)
 */

void assign_reg (int reg, int val)
{

	if ((reg != ZERO_REG) && (reg != SIDE_REG)) {
		AntRegisters [reg] = LOWER_BYTE (val);
	}
}

/*
 * end of SOL_antvm.c
 */
