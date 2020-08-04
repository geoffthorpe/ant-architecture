/*
 * $Id: ant8_dis.c,v 1.7 2002/10/09 23:51:46 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_disasm.c -- Routines for disassembling parts of the ANT
 * machine, displaying the contents in a human-readable format.
 *
 */

#include	<stdio.h>
#include	<string.h>

#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

#include	"ant_external.h"

#define	MAX_DMEM_STR_SIZE (ANT_DATA_ADDR_RANGE * 8 * 4)
#define	MAX_IMEM_STR_SIZE (ANT_INST_ADDR_RANGE * 80)

typedef	enum {
	ADDR3, ADDR2, ADDR1, ADDR0, ADDR_REG1, LOAD_STORE, IO_OP, NO_OP
} op_type_t;

#define	DATA_PER_LINE	16

static void print_reg (int reg_idx, ant_data_t *values, char *buf);
static void print_constant (int constant, char *buf);
static const char *find_io_mnemonic (int periph);

/*
 * Uses ant_disasm_i_mem to create a string representing the
 * disassembly of instruction memory, then prints the string out and
 * frees it.
 */

void ant_disasm_i_mem_print (ant_t *ant)
{
	char *ptr = ant_disasm_i_mem (ant, 0);

	printf ("%s", ptr);
	free (ptr);

	return ;
}

/*
 * Uses ant_disasm_d_mem to create a string representing the
 * disassembly of instruction memory, then prints the string out and
 * frees it.
 */

void ant_disasm_d_mem_print (ant_t *ant)
{
	char *ptr = ant_disasm_d_mem (ant, 1, 0);

	printf ("%s", ptr);
	free (ptr);

	return ;
}

/*
 * ant_disasm_i_mem --
 *
 * Creates and returns a string representing the disassembled
 * instruction memory of the given ant machine.  Tries to ignore
 * uninitialized locations in instruction memory.
 *
 */

char *ant_disasm_i_mem (ant_t *ant, int include_all)
{
	extern ant_symtab_t *labelTable;
	int pc, max;
	char buf [MAX_IMEM_STR_SIZE];
	char *labels [ANT_DATA_ADDR_RANGE];

	symtab2array (labelTable, labels);

	if (ant->inst_cnt >= 0) {
		max = 2 * ant->inst_cnt;
	}
	else {

		/*
		 * Working forward from the start of instruction
		 * memory, find the first instr that does contain the
		 * ILLEGAL code, and the disasm all the instructions
		 * beforehand.
		 */

		for (max = 0; max < ANT_INST_ADDR_RANGE;
				max = ant_increment_pc (max)) {
			if (ant_fetch_instruction (ant, max) ==
					ILLEGAL_INSTRUCTION) {
				break;
			}
		}
	}

	buf [0] = '\0';
	for (pc = 0; pc < max;) {
		ant_inst_t inst;
		char label_str [100];

		if (labels [pc] != NULL) {
			sprintf (label_str, "%s:", labels [pc]);
		}
		else {
			*label_str = '\0';
		}

		sprintf (buf + strlen (buf), "0x%.2x: %-15s ", pc, label_str);

		inst = ant_fetch_instruction (ant, pc);
		ant_disasm_inst (inst, pc, NULL, buf + strlen (buf), 0);
		sprintf (buf + strlen (buf), "\n");

		pc = ant_increment_pc (pc);

		/*
		 * Beware of wrapping!
		 */

		if (pc == 0) {
			break;
		}
	}

	if (include_all) {
		int blanks = ANT_INST_ADDR_RANGE - pc;
		int i;

		for (i = 0; i < blanks; i = ant_increment_pc (i)) {
			sprintf (buf + strlen (buf), "0x%.2x:\n", pc + i);
		}
	}

	free_label_array (labels);

	return (strdup (buf));
}

/*
 * ant_disasm_d_mem --
 *
 * Creates and returns a string representing the disassembled data
 * memory of the given ant machine.  Tries to ignore "uninitialized"
 * (all zeros) locations in instruction memory by not printing rows
 * that are entirely zero.
 *
 */

char *ant_disasm_d_mem (ant_t *ant, int show_x, int no_show_empty)
{
	int i;
	char buf [MAX_DMEM_STR_SIZE];
	int prev_was_empty = 0;

	buf [0] = '\0';

	/*
	 * Pretty-print data memory, taking some care to skip over
	 * large regions of zeros.  Makes no attempt to print data in
	 * the original format (that info is entirely lost).
	 */

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i += DATA_PER_LINE) {
		int j;

		if (no_show_empty) {

			/*
			 * This little slice of ugliness is to make it
			 * possible to skip over lines that would
			 * otherwise be entirely zeros:  look through
			 * each "line"; if there's anything non-zero,
			 * then print the line and continue on;
			 * otherwise don't print anything.
			 */

			for (j = 0; j < DATA_PER_LINE; j++) {
				if (ant->data [i + j] != 0) {
					break;
				}
			}
			if (j == DATA_PER_LINE) {
				if (!prev_was_empty) {
					prev_was_empty = 1;
					sprintf (buf + strlen (buf),
							"%s", "---\n");
					}
				}
			else {
				ant_disasm_data_block (ant->data, i,
						DATA_PER_LINE,
						buf + strlen (buf), show_x);
				prev_was_empty = 0;
			}
		}
		else {
			ant_disasm_data_block (ant->data, i,
					DATA_PER_LINE,
					buf + strlen (buf), show_x);
		}
	}

	return (strdup (buf));
}

/*
 * ant_disasm_data_block --
 *
 * Disassamble a "block" of data into the given buf (which is ASSUMED
 * to be large enough).
 */

void ant_disasm_data_block (ant_data_t *data, unsigned int offset,
			unsigned int count, char *buf, int show_x)
{
	unsigned int i;
	char *data_bytes = (char *) data;
	char *byte_fmt;

	if (show_x) {
		byte_fmt = " x%.2x";
	}
	else {
		byte_fmt = " %.2x";
	}


	ANT_ASSERT (offset < ANT_DATA_ADDR_RANGE);
	

	*buf = '\0';

	for (i = 0; i < count; i++) {
		if (i % DATA_PER_LINE == 0) {
			sprintf (buf + strlen (buf),
					"0x%.2x:\t", offset + i);
		}

		if ((i + offset) >= ANT_DATA_ADDR_RANGE) {
			break;
		}

		sprintf (buf + strlen (buf), byte_fmt,
				BYTE_MASK & data_bytes [i + offset]);

		if ((i % DATA_PER_LINE) == (DATA_PER_LINE - 1)) {
			sprintf (buf + strlen (buf), "\n");
		}
	}

	if ((i % DATA_PER_LINE) != 0) {
		sprintf (buf + strlen (buf), "\n");
	}

	return ;
}


/*
 * ant_disasm_inst --
 *
 * Disassamble a single instruction, into the given buf (which is
 * ASSUMED to be large enough).
 *
 * &&& This is a clumsy function and could be written more
 * efficiently, but it doesn't matter for small programs...
 */

int		ant_disasm_inst (ant_inst_t inst, unsigned int offset,
			ant_data_t *regs, char *buf, int show_pc)
{
	int op, r1, r2, r3, uconst4;
	int constant;
	char *str = NULL;
	op_type_t type = NO_OP;

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);
	uconst4 = ant_get_uconst4 (inst);

	constant = ant_get_const8 (inst);

	*buf = '\0';

	if (show_pc) {
		print_constant (offset, buf + strlen (buf));
		sprintf (buf + strlen (buf), ":\t");
	}

	switch (op) {
		case OP_ADD	: str = "add "; type = ADDR3; break;
		case OP_SUB	: str = "sub "; type = ADDR3; break;
		case OP_MUL	: str = "mul "; type = ADDR3; break;
		case OP_BEQ	: str = "beq "; type = ADDR3; break;
		case OP_BGT	: str = "bgt "; type = ADDR3; break;
		case OP_AND	: str = "and "; type = ADDR3; break;
		case OP_NOR	: str = "nor "; type = ADDR3; break;
		case OP_SHF	: str = "shf "; type = ADDR3; break;
		case OP_LC		: str = "lc  "; type = ADDR2; break;

		case OP_LD1	: str = "ld1 "; type = LOAD_STORE; break;
		case OP_ST1	: str = "st1 "; type = LOAD_STORE; break;
		case OP_INC	: str = "inc "; type = ADDR2; break;
		case OP_JMP	: str = "jmp "; type = ADDR1; break;

		case OP_HALT	: str = "hlt "; type = ADDR0; break;

		case OP_IN	:
			str = "in  ";
			type = IO_OP;
			constant &= 0xf;
			break;
				
		case OP_OUT	:
			str = "out ";
			type = IO_OP;
			constant &= 0xf;
			r1 = r2;
			break;

		default		:
			sprintf (buf + strlen (buf),
					"ILLEGAL op (0x%.4x)\n", inst);
			break;
	}

	if (str != NULL) {
		sprintf (buf + strlen (buf), "%s", str);
	}

	switch (type) {

		case IO_OP :
			print_reg (r1, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			sprintf (buf + strlen (buf), "%s",
					find_io_mnemonic (constant));
			break;

		case ADDR3 :
			print_reg (r1, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			print_reg (r2, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			print_reg (r3, regs, buf + strlen (buf));
			break;

		case ADDR2 :
			print_reg (r1, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			print_constant (constant, buf + strlen (buf));
			break;

		case ADDR1 :
			print_constant (constant, buf + strlen (buf));
			break;

		case ADDR0 :
			break;

		case LOAD_STORE :
			print_reg (r1, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			print_reg (r2, regs, buf + strlen (buf));
			sprintf (buf + strlen (buf), ", ");
			sprintf (buf + strlen (buf), "0x%x", uconst4);
			break;

		case ADDR_REG1 :
			print_reg (r1, regs, buf + strlen (buf));
			break;

		default :
			ANT_ASSERT (0);
			break;
	}

	return (0);
}

/*
 * ant_inst_src --
 *
 * Find the src and des registers used by an instruction.
 *
 */

int ant_inst_src (ant_inst_t inst, ant_data_t *reg,
		int *_src1, int *_src2, int *_src3, int *_des,
		int *_iperiph, int *_operiph, int *_ovalue,
		int *_waddr, int *_raddr)
{
	int op, r1, r2, r3, uconst4;
	int constant;

	int src1 = -1;
	int src2 = -1;
	int src3 = -1;
	int des  = -1;
	int iperiph = -1;
	int operiph = -1;
	int ovalue = -1;
	int waddr = -1;
	int raddr = -1;

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);
	uconst4 = ant_get_uconst4 (inst);

	constant = ant_get_const8 (inst);

	switch (op) {
		case OP_ADD	:
		case OP_SUB	:
		case OP_MUL	:
		case OP_AND	:
		case OP_NOR	:
		case OP_SHF	:
			src1 = r2;
			src2 = r3;
			des  = r1;
			break;

		case OP_BEQ	:
		case OP_BGT	:
			src1 = r2;
			src2 = r3;
			src3 = r1;
			break;

		case OP_LC	:
			des  = r1;
			break;

		case OP_LD1	:
			des  = r1;
			src1 = r2;
			raddr = LOWER_BYTE (reg [src1] + uconst4);
			break;

		case OP_ST1	:
			src1 = r2;
			src2 = r1;
			waddr = LOWER_BYTE (reg [src1] + uconst4);
			break;

		case OP_INC	:
			src1 = r1;
			des  = r1;
			break;

		case OP_JMP	:
			break;

		case OP_HALT	:
			break;

		case OP_IN	:
			des  = r1;
			iperiph = constant & 0xf;
			break;

		case OP_OUT	:
			src1 = r2;
			operiph = constant & 0xf;
			ovalue = reg [src1];
			break;

		default		:
			ANT_ASSERT (0);
			break;
	}

	*_src1 = src1;
	*_src2 = src2;
	*_src3 = src3;
	*_des  = des;
	*_iperiph = iperiph;
	*_operiph = operiph;
	*_ovalue = ovalue;
	*_waddr = waddr;
	*_raddr = raddr;

	return (0);
}


/*
 * Print the register (and its value, if the values array is non-NULL)
 * to the given buf (which is ASSUMED to be large enough).
 */

static void print_reg (int reg_idx, ant_data_t values [], char *buf)
{
	char *fmt = "=(0x%-.2x)";

	sprintf (buf, "r%d", reg_idx);
	if (values != NULL) {
		sprintf (buf + strlen (buf),
				fmt, LOWER_BYTE (values [reg_idx]));
	}
}

/*
 * Print the constant to the given buf (which is ASSUMED to be large
 * enough).
 */

static void print_constant (int constant, char *buf)
{

	sprintf (buf, "0x%.2x", constant);
	return ;
}

static const char *find_io_mnemonic (int periph)
{
	switch (periph) {
		case 0 : return ("Hex");	break;
		case 1 : return ("Binary");	break;
		case 2 : return ("ASCII");	break;
		default: return ("???");	break;
	}
}

/*
 * end of ant_dis.c
 */
