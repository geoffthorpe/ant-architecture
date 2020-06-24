/*
 * $Id: ant8_exec.c,v 1.14 2003/02/12 19:07:50 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_exec.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

/*
 * Note: ascii code 4 is the eot (aka EOI or control-D)
 * code.  It doesn't seem to be defined anywhere standard,
 * hence its appearance as a magic number here.
 */

#define	ASCII_EOT	4

static int do_in_stdin (int format, char *side_reg);
static int do_out_stdout (int val, int format, ant_data_t *side_reg,
		FILE *stream);

	/*
	 * ant_seen_eoi records whether an EOI has been detected on
	 * the input.
	 */

int ant_seen_eoi = 0;

/*
 * ant_exec --
 *
 * Exec the given ant machine.
 *
 * Returns 0 if the machine halted via a HALT instruction, or non-zero if
 * a fault was detected.
 */

int		ant_exec (ant_t *ant)
{
	int rc;

	while ((rc = ant_exec_inst (ant, NULL, NULL, stdout)) == 0)
		;

	if (rc >= 0) {
		return (0);
	}
	else {
		return (rc);
	}
}

/*
 * Fetching an instruction would be a no-brainer, except that there
 * are two memory models for the ANT-- the single memory space (for
 * SINGLE_ADDRESS_SPACE) and the split data and instruction space. 
 * Therefore, how the instruction is fetched depends on what kind of
 * machine you're on.
 *
 * It's nicer to hide this in one function than have this ugliness
 * seep into the code.
 */

ant_inst_t ant_fetch_instruction (ant_t *ant, ant_pc_t pc)
{
	ant_inst_t inst;

	inst = (LOWER_BYTE (ant->data [pc + 0]) << 8) |
			LOWER_BYTE (ant->data [pc + 1]);

	return (inst);
}

/*
 * Like ant_fetch_instruction -- a simple thing made ugly by the
 * shared address problems.
 */

ant_pc_t ant_increment_pc (ant_pc_t pc)
{

	return (pc + 2);
}


/*
 * ant_exec_inst --
 *
 * Execute a single instruction.
 */

int		ant_exec_inst (ant_t *ant, int *input_reg_index,
			int *input_type, FILE *out)
{
	unsigned int op, r1, r2, r3, uconst4;
	ant_reg_t constant;
	int val, old_pc;
	ant_inst_t inst;
	ant_reg_t *reg = ant->reg;

	ant_status (STATUS_OK);

	old_pc = ant->pc;

	if ((ant->pc % 2) != 0) {
		ant_fault (FAULT_ADDR, ant->pc, ant, 1);
		return (-1);
	}

	inst = ant_fetch_instruction (ant, ant->pc);
	ant->pc = ant_increment_pc (ant->pc);

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);
	uconst4 = ant_get_uconst4 (inst);

	constant = ant_get_const8 (inst);

	switch (op) {
		case OP_ADD	:
			val = reg [r2] + reg [r3];

			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));

			if (val > MAX_ANT_INT) {
				reg [SIDE_REG] = 1;
			}
			else if (val < MIN_ANT_INT) {
				reg [SIDE_REG] = -1;
			}
			else {
				reg [SIDE_REG] = 0;
			}

			break;

		case OP_SUB	:
			val = reg [r2] - reg [r3];

			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));

			if (val > MAX_ANT_INT) {
				reg [SIDE_REG] = 1;
			}
			else if (val < MIN_ANT_INT) {
				reg [SIDE_REG] = -1;
			}
			else {
				reg [SIDE_REG] = 0;
			}
			break;

		case OP_MUL	:
			val = reg [r2] * reg [r3];

			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));

			reg [SIDE_REG] = UPPER_BYTE (val);
			break;

		case OP_AND	:
			val = reg [r2] & reg [r3];
			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));
			reg [SIDE_REG] = ~val;
			break;

		case OP_NOR	:
			val = ~(reg [r2] | reg [r3]);
			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));
			reg [SIDE_REG] = ~val;
			break;

		case OP_SHF	:
			if (reg [r3] >= 0) {
				val = reg [r2] << reg [r3];
			}
			else {
				unsigned char t = reg [r2];

				val = t >> -reg [r3];
			}

			ant_assign_des_reg (reg, r1, LOWER_BYTE (val));
			reg [SIDE_REG] = 0;
			break;

		case OP_BEQ	:
			if (reg [r2] == reg [r3]) {
				ant->pc = (unsigned char) reg [r1];
			}
			break;

		case OP_BGT	:
			if (reg [r2] > reg [r3]) {
				ant->pc = (unsigned char) reg [r1];
			}
			break;

		case OP_LD1	:
			val = LOWER_BYTE (reg [r2]) + uconst4;
			if (val < 0 || val >= ANT_DATA_ADDR_RANGE) {
				ant_fault (FAULT_ADDR, old_pc, ant, 1);
				return (-1);
			}

			ant_assign_des_reg (reg, r1, ant->data [val]);
			break;

		case OP_ST1	:
			val = LOWER_BYTE (reg [r2]) + uconst4;
			if (val < 0 || val >= ANT_DATA_ADDR_RANGE) {
				ant_fault (FAULT_ADDR, old_pc, ant, 1);
				return (-1);
			}

			ant->data [val] = reg [r1];
			break;

		case OP_LC	:
			ant_assign_des_reg (reg, r1, constant);
			break;


		case OP_JMP	:
			reg [SIDE_REG] = ant->pc;
			ant->pc = LOWER_BYTE (constant);
			break;

		case OP_INC	:
			val = reg [r1] + constant;

			if (val > MAX_ANT_INT) {
				reg [SIDE_REG] = 1;
			}
			else if (val < MIN_ANT_INT) {
				reg [SIDE_REG] = -1;
			}
			else {
				reg [SIDE_REG] = 0;
			}

			ant_assign_des_reg (reg, r1, val);

			break;

		case OP_IN	: {

			/*
			 * In ordinary operation, input_reg_index is
			 * NULL, and so we just block the execution of
			 * the ANT until the user types something.  If
			 * we're trying to simulate things at a finer
			 * level, however, we treat an attempt to read
			 * like an exceptional condition-- the
			 * operation stalls, and the processor is left
			 * in an intermediate state, waiting for the
			 * input to arrive so it can be deposited in
			 * the appropriate register.  In this case,
			 * *input_reg_index is filled in with the
			 * register index, so this operation can be
			 * completed elsewhere.
			 */

			if (input_reg_index == NULL) {
				val = do_in_stdin (uconst4, &reg [SIDE_REG]);
				ant_assign_des_reg (reg, r1, val);
			}
			else {
				if (ant_console_qlen () > 0) {
					val = ant8_do_in_buf (uconst4,
							&reg [SIDE_REG]);
					ant_assign_des_reg (reg, r1, val);
				}
				else {
					*input_reg_index = r1;
					*input_type = uconst4;
					ant_status (STATUS_INPUT);
					return (1);
				}
			}

			break;
		}

		case OP_OUT	: {
			do_out_stdout (reg [r2], uconst4, &reg [SIDE_REG],
					out);
			break;
		}

		case OP_HALT	:
			ant_status (STATUS_HALT);
			return (1);
			break;

		default		:
			ant_fault (FAULT_ILL, old_pc, ant, 1);
			return (-1);
			break;
	}

	return (0);
}

static int do_in_stdin (int format, char *side_reg)
{
	char d [10];
	int val;
	int i;

	switch (format) {
		case 0 :	/* Hex */
			for (i = 0; i < 2; i++) {
				d [i] = getc (stdin);
			}
			d [2] = '\0';

				/* Eat extra characters. */
			while (getc (stdin) != '\n')
				;

			val = strtol (d, NULL, 16);
			break;
		case 1 : 	/* Binary */
			for (i = 0; i < 8; i++) {
				d [i] = getc (stdin);
			}
			d [8] = '\0';

				/* Eat extra characters. */
			while (getc (stdin) != '\n')
				;

			val = strtol (d, NULL, 2);
			break;
		case 2 :	/* ASCII */
			val = getc (stdin);
			val = LOWER_BYTE (val);
			break;

		default :
			/* No such peripheral! */
			val = 0;
			break;

	}

	if (side_reg != NULL) {
		*side_reg = feof (stdin) ? 1 : 0;
	}

	return (val);
}

#define	READ_CHAR()	(prev_char = ant_console_dequeue ())

int ant8_do_in_buf (int format, char *side_reg)
{
	char d [10];
	int val;
	int i;
	int c;
	int qlen;
	static int prev_char = '\n';

	qlen = ant_console_qlen ();

	/*
	 * Look for control-D (aka ASCII eot char) at the start of the
	 * line.  This is done by peeking ahead to see if the next
	 * char is ASCII_EOT and the previous character was a newline. 
	 * In order for this to work properly, every time a character
	 * is read from the console, it needs to be saved in
	 * prev_char.  This is accomplished with the READ_CHAR macro
	 * defined above.  Not pretty.
	 */

	c = ant_console_peek ();
	if ((c == ASCII_EOT) && (prev_char == '\n')) {
		ant_seen_eoi = 0;
		*side_reg = 1;
		return (0);
	}
	else {
		*side_reg = 0;
	}

	switch (format) {
		case 0 :	/* Hex */
			for (i = 0; i < 2 && i < qlen; i++) {
				c = READ_CHAR ();
				if (c == '\n') {
					break;
				}
				d [i] = c;
			}
			d [i] = '\0';

				/* Eat extra characters. */
			while ((ant_console_qlen () > 0)
					&& (READ_CHAR () != '\n')) {
				;
			}

			val = strtol (d, NULL, 16);
			break;
		case 1 : 	/* Binary */
			for (i = 0; i < 8 && i < qlen; i++) {
				c = READ_CHAR ();
				if (c == '\n') {
					break;
				}
				d [i] = c;
			}
			d [i] = '\0';

				/* Eat extra characters. */
			while ((ant_console_qlen () > 0) &&
					(READ_CHAR () != '\n')) {
				;
			}

			val = strtol (d, NULL, 2);
			break;
		case 2 :	/* ASCII */

			c = READ_CHAR ();
			val = LOWER_BYTE (c);
			break;

		default :
			/* No such peripheral! */
			val = 0;
			break;

	}

	return (val);
}

static int do_out_stdout (int val, int format, ant_data_t *side_reg,
		FILE *stream)
{
	int i;
	char buf [1024];

	buf [0] = '\0';

	switch (format) {
		case 0 :	/* Hex */
			sprintf (buf + strlen (buf), "%x", LOWER_BYTE (val));
			break;
		case 1 : 	/* Binary */

			for (i = 7; i >= 0; i--) {
				sprintf (buf + strlen (buf),
					"%c", (val & (1 << i)) ? '1' : '0');
			}
			break;
		case 2 :	/* ASCII */
			sprintf (buf + strlen (buf), "%c", val);
			break;

		default :
			/* No such peripheral! */
			break;

	}

	if (side_reg != NULL) {
		*side_reg = 0;
	}

	if (stream != NULL) {
		fprintf (stream, "%s", buf);
		fflush (stream);
		return (0);
	}
	else {
		/* *result_str = strdup (buf); */
		return (0);
	}
}

/*
 * end of SOL_ant_exec.c
 */
