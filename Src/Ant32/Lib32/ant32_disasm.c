/*
 * $Id: ant32_disasm.c,v 1.16 2003/01/23 03:26:34 sara Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 01/24/01
 *
 * ant32_disasm.c -- Routines for disassembling parts of the ANT
 * machine, displaying the contents in a human-readable format.
 *
 */

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include        "ant32_external.h"
#include	"ant_external.h"

#define	MAX_DMEM_STR_SIZE (ANT_DATA_ADDR_RANGE * 8 * 4)
#define	MAX_IMEM_STR_SIZE (ANT_INST_ADDR_RANGE * 80)

#define	DATA_PER_LINE	16

static void print_reg (int reg_idx, ant_reg_t *values, char *buf);
static void print_constant (int constant, char *buf);
static char *find_io_mnemonic (int periph);

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
			ant_reg_t *regs, char *buf, int show_pc)
{
	int op, r1, r2, r3, const8, const16;
	char *r1_str, *r2_str, *r3_str;

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);

	r1_str = ant32_reg_name (r1);
	r2_str = ant32_reg_name (r2);
	r3_str = ant32_reg_name (r3);

	const8 = ant_get_const8 (inst);
	const16 = 0xffff & ant_get_const16 (inst);

	*buf = '\0';

	if (show_pc) {
		print_constant (offset, buf + strlen (buf));
		sprintf (buf + strlen (buf), ":\t");
	}


	switch (op) {
	case OP_ADD	:
		sprintf (buf, "add\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SUB	: 
		sprintf (buf, "sub\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_MUL	:
		sprintf (buf, "mul\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_DIV	:
		sprintf (buf, "div\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_MOD	:
		sprintf (buf, "mod\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_OR	:
		sprintf (buf, "or\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_NOR	:
		sprintf (buf, "nor\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_XOR	:
		sprintf (buf, "xor\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_AND	:
		sprintf (buf, "and\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SHR	:
		sprintf (buf, "shr\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SHRU	:
		sprintf (buf, "shru\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SHL	:
		sprintf (buf, "shl\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_ADDI	:
		sprintf (buf, "addi\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_SUBI	:
		sprintf (buf, "subi\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_MULI	:
		sprintf (buf, "muli\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_DIVI	:
		sprintf (buf, "divi\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_MODI	:
		sprintf (buf, "modi\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_SHRI	:
		sprintf (buf, "shri\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_SHRUI	:
		sprintf (buf, "shrui\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_SHLI	:
		sprintf (buf, "shli\t%s, %s, %d", r1_str, r2_str, const8);
		break;

	case OP_ADDO	:
		sprintf (buf, "addo\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SUBO	:
		sprintf (buf, "subo\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_MULO	:
		sprintf (buf, "mulo\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_ADDIO	:
		sprintf (buf, "addio\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_SUBIO	:
		sprintf (buf, "subio\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_MULIO	:
		sprintf (buf, "mulio\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_EQ	:
		sprintf (buf, "eq\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_GTS	:
		sprintf (buf, "gts\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_GES	:
		sprintf (buf, "ges\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_GTU	:
		sprintf (buf, "gtu\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_GEU	:
		sprintf (buf, "geu\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;


	case OP_BEZ	:
		sprintf (buf, "bez\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_JEZ	:
		sprintf (buf, "jez\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_BNZ	:
		sprintf (buf, "bnz\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;
	case OP_JNZ	:
		sprintf (buf, "jnz\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_BEZI	:
		sprintf (buf, "bezi\t%s, 0x%x", r1_str, const16);
		break;
	case OP_BNZI	:
		sprintf (buf, "bnzi\t%s, 0x%x", r1_str, const16);
		break;

	case OP_LD1	:
		sprintf (buf, "ld1\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_LD4	:
		sprintf (buf, "ld4\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_ST1	:
		sprintf (buf, "st1\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_ST4	:
		sprintf (buf, "st4\t%s, %s, %d", r1_str, r2_str, const8);
		break;
	case OP_EX4	:
		sprintf (buf, "ex4\t%s, %s, %d", r1_str, r2_str, const8);
		break;

	case OP_LCL	:
		sprintf (buf, "lcl\t%s, 0x%x", r1_str, const16);
		break;
	case OP_LCH	:
		sprintf (buf, "lch\t%s, 0x%x", r1_str, const16);
		break;

	case OP_TRAP	:
		sprintf (buf, "trap\t 0x%-2x%-2x%-2x", r1, r2, r3);
		break;
	case OP_INFO	:
		sprintf (buf, "info\t%s, 0x%x", r1_str, const16);
		break;

	case OP_RAND	:
		sprintf (buf, "rand\t%s", r1_str);
		break;
	case OP_SRAND	:
		sprintf (buf, "srand\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_CIN	:
		sprintf (buf, "cin\t%s", r1_str);
		break;
	case OP_COUT	:
		sprintf (buf, "cout\t%s", r2_str);
		break;

	case OP_TLBPI	:
		sprintf (buf, "tlbpi\t%s, %s", r1_str, r2_str);
		break;
	case OP_TLBLE	:
		sprintf (buf, "tlble\t%s, %s", r1_str, r2_str);
		break;
	case OP_TLBSE	:
		sprintf (buf, "tlbse\t%s, %s", r2_str, r3_str);
		break;

	case OP_LEH	:
		sprintf (buf, "leh\t%s", r2_str);
		break;
	case OP_RFE	:
		sprintf (buf, "rfe\t%s, %s, %s", r1_str, r2_str, r3_str);
		break;

	case OP_TIMER	:
		sprintf (buf, "timer\t%s, %s", r1_str, r2_str);
		break;
	case OP_CLI	:
		sprintf (buf, "cli");
		break;
	case OP_STI	:
		sprintf (buf, "sti");
		break;
	case OP_CLE	:
		sprintf (buf, "cle");
		break;
	case OP_STE	:
		sprintf (buf, "ste");
		break;
	case OP_IDLE	:
		sprintf (buf, "idle");
		break;
	case OP_HALT	:
		sprintf (buf, "halt");
		break;

	default		:
		sprintf (buf, "%x %x %x %x", op, r1, r2, r3);
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

int ant_inst_src (ant_inst_t inst, ant_reg_t *reg,
		int *_src1, int *_src2, int *_src3,
		int *_des1, int *_des2,
		int *_waddr, int *_raddr, int *_ovalue,
		char **buf)
{
	int op, r1, r2, r3, const8;

	int src1 = -1;
	int src2 = -1;
	int src3 = -1;
	int des1 = -1;
	int des2 = -1;
	int waddr = -1;
	int raddr = -1;
	int ovalue = -1;

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);
	const8 = ant_get_const8 (inst);

	switch (op) {
	case OP_ADD	:
	case OP_SUB	: 
	case OP_MUL	:
	case OP_DIV	:
	case OP_MOD	:
	case OP_OR	:
	case OP_NOR	:
	case OP_XOR	:
	case OP_AND	:
	case OP_SHR	:
	case OP_SHRU	:
	case OP_SHL	:
		des1 = r1, src1 = r2; src2 = r3;
		break;

	case OP_ADDI	:
	case OP_SUBI	:
	case OP_MULI	:
	case OP_DIVI	:
	case OP_MODI	:
	case OP_SHRI	:
	case OP_SHRUI	:
	case OP_SHLI	:
		des1 = r1, src1 = r2;
		break;

	case OP_ADDO	:
	case OP_SUBO	:
	case OP_MULO	:
		des1 = r1, des2 = r1 + 1; src1 = r2; src2 = r3;
		break;

	case OP_ADDIO	:
	case OP_SUBIO	:
	case OP_MULIO	:
		des1 = r1, des2 = r1 + 1; src1 = r2;
		break;

	case OP_EQ	:
	case OP_GTS	:
	case OP_GES	:
	case OP_GTU	:
	case OP_GEU	:
		des1 = r1, src1 = r2; src2 = r3;
		break;

	case OP_BEZ	:
	case OP_JEZ	:
	case OP_BNZ	:
	case OP_JNZ	:
		des1 = r1, src1 = r2; src2 = r3;
		break;

	case OP_BEZI	:
	case OP_BNZI	:
		src1 = r1;
		break;

	case OP_LD1	:
	case OP_LD4	:
		des1 = r1; src1 = r2; raddr = reg [r2] + const8;
		break;

	case OP_ST1	:
	case OP_ST4	:
		src1 = r1; src2 = r2; waddr = reg [r2] + const8;
		break;

	case OP_EX4	:
		des1 = r1; src1 = r1; src2 = r2;
		raddr = waddr = reg [r2] + const8;
		break;

	case OP_LCL	:
	case OP_LCH	:
		des1 = r1;
		break;

	case OP_TRAP	:
		src1 = r1; src2 = r2; src3 = r3;
		break;

	case OP_INFO	:
		des1 = r1;
		break;

	case OP_RAND	:
		des1 = r1;
		break;

	case OP_SRAND	:
		src1 = r1; src2 = r2; src3 = r3;
		break;

	case OP_CIN	:
		des1 = r1;
		break;

	case OP_COUT	:
		src1 = r2; ovalue = LOWER_BYTE (reg [r2]);
		break;

	case OP_TLBPI	:
		des1 = r1; src1 = r2;
		break;

	case OP_TLBLE	:
		des1 = r1; des2 = r1 + 1; src1 = r2;
		break;

	case OP_TLBSE	:
		src1 = r2; src2 = r3; src3 = r3 + 1;
		break;

	case OP_LEH	:
		src1 = r2;
		break;

	case OP_RFE	:
		src1 = r1; src2 = r2; src3 = r3;
		break;

	case OP_TIMER	:
		des1 = r1; src1 = r2;
		break;

	case OP_CLI	:
	case OP_STI	:
	case OP_CLE	:
	case OP_STE	:
	case OP_IDLE	:
	case OP_HALT	:
		/* these instructions use no registers or memory */
		break;

	default		:
		return (-1);
	}

	*_src1 = src1;
	*_src2 = src2;
	*_src3 = src3;
	*_des1 = des1;
	*_des2 = des2;
	*_raddr = raddr;
	*_waddr = waddr;
	*_ovalue = ovalue;

	if (buf != NULL) {
		char tmp_buf [512];	/* &&& large enough? */

		sprintf (tmp_buf, "%d %d %d %d %d %d %d %d",
				src1, src2, src3, des1, des2,
				raddr, waddr, ovalue);

		*buf = strdup (tmp_buf);
		ANT_ASSERT (*buf != NULL);
	}

	return (0);
}

/*
 * Print the register (and its value, if the values array is non-NULL)
 * to the given buf (which is ASSUMED to be large enough).
 */

static void print_reg (int reg_idx, ant_reg_t values [], char *buf)
{
	char *fmt = "=(0x%-.8x)";

	sprintf (buf, "r%d", reg_idx);
	if (values != NULL) {
		sprintf (buf + strlen (buf), fmt, values [reg_idx]);
	}
}

/*
 * Print the constant to the given buf (which is ASSUMED to be large
 * enough).
 */

static void print_constant (int constant, char *buf)
{

	sprintf (buf, "0x%.8x", constant);
	return ;
}

/*
 * end of ant32_dis.c
 */
