/*
 * $Id: ant8_check.c,v 1.5 2002/10/19 18:36:41 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 11/02/96 -- cs50
 *
 * ant_parse.c --
 *
 * Routines to parse a string as a single line of ANT assembly
 * language.
 *
 */
 
#include	"ant8_external.h"
#include	"ant8_internal.h"

static	int	check_ld_st (ant_asm_stmnt_t *s);
static	int	check_3reg (ant_asm_stmnt_t *s);
static	int	check_des_reg (ant_asm_stmnt_t *s);
static	int	check_imm (ant_asm_stmnt_t *s);
static	int	check_byte (ant_asm_stmnt_t *s);
static	int	check_jmp (ant_asm_stmnt_t *s);

int		DesWarnOnly	= 0;


/*
 * args_check --
 *
 * Given a pointer to a statment structure, determine whether the
 * statement is viable by checking whether the opcode is legal, and
 * the argument types match what the opcode expects.
 *
 * This function has far too many magic numbers and assumptions.
 */

int ant_asm_args_check (ant_asm_stmnt_t *s)
{

	switch (s->op) {
		case ASM_OP_NONE:
			/* No op?  It must be OK... */
			return (0);
			break;

		case ASM_OP_BYTE:
			return (check_byte (s));
			break;

		case ASM_OP_DEFINE:
			break;

		case OP_ADD	:
		case OP_SUB	:
		case OP_MUL	:
		case OP_AND	:
		case OP_NOR	:
		case OP_SHF	:
			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_BEQ	:
		case OP_BGT	:
			return (check_3reg (s));
			break;

		case OP_INC	:
			return (check_des_reg (s) || check_imm (s));
			break;

		case OP_JMP	:
			return (check_jmp (s));
			break;

		case OP_IN		:
		case OP_OUT	:
			return (check_imm (s));

		case OP_HALT	:
			if (s->num_args == 0) {
				return (0);
			}
			else {
				sprintf (AntErrorStr,
						"hlt should have no operands");
				return (1);
			}
			break;

		case OP_LC	:
			return (check_des_reg (s) || check_imm (s));
			break;

		case OP_LD1	:
			return (check_des_reg (s) || check_ld_st (s));
			break;

		case OP_ST1	:
			return (check_ld_st (s));
			break;

		default		:
			sprintf (AntErrorStr, "unknown opcode");
			return (-1);
	}

	return (0);
}

static int check_des_reg (ant_asm_stmnt_t *s)
{
	int reg;

	if (s->args [0].type != REG_ARG) {
		sprintf (AntErrorStr, "destination must be a register");
		return (-1);
	}

	reg = s->args [0].reg;
	if (reg == ZERO_REG || reg == SIDE_REG) {
		sprintf (AntErrorStr, "WARNING: r%d is read-only!\n", reg);
	}

	return (0);
}

static int check_ld_st (ant_asm_stmnt_t *s)
{
	
	/*
	 * 3 args, two registers and a 4-bit constant.
	 */

	if (s->num_args != 3) {
		sprintf (AntErrorStr, "invalid number of operands");
		return (-1);
	}
	if (s->args [0].type != REG_ARG) {
		sprintf (AntErrorStr, "des must be a register");
		return (-1);
	}
	if (s->args [1].type != REG_ARG) {
		sprintf (AntErrorStr, "src1 must be a register");
		return (-1);
	}
	if (s->args [2].type != INT_ARG) {
		sprintf (AntErrorStr, "third operand must be a constant");
		return (-1);
	}
	if (s->args [2].val < 0 || s->args [2].val >= 16) {
		sprintf (AntErrorStr,
				"third operand must be a 4-bit constant");
		return (-1);
	}

	return (0);
}

static int check_3reg (ant_asm_stmnt_t *s)
{

	/*
	 * 3 args, all must be valid registers.
	 */

	if (s->num_args != 3) {
		sprintf (AntErrorStr, "invalid number of operands");
		return (-1);
	}
	else if (s->args [0].type != REG_ARG) {
		printf ("SDSDFS\n");
		sprintf (AntErrorStr, "des must be a register");
		return (-1);
	}
	else if (s->args [1].type != REG_ARG) {
		sprintf (AntErrorStr, "src1 must be a register");
		return (-1);
	}
	else if (s->args [2].type != REG_ARG) {
		sprintf (AntErrorStr, "src2 must be a register");
		return (-1);
	}
	else {
		return (0);
	}
}

static int check_byte (ant_asm_stmnt_t *s)
{
	unsigned int i;

	/*
	 * 1-8 constants (integers). 
	 * labels permitted.
	 */

	if (s->num_args < 1) {
		sprintf (AntErrorStr, "no data constants specified?");
		return (-1);
	}
	if (s->num_args > ANT_ASM_MAX_ARGS) {
		sprintf (AntErrorStr, "too many data constants specified");
		return (-1);
	}

	for (i = 0; i < s->num_args; i++) {
		int		type;

		type = s->args [i].type;

		if (type != INT_ARG && type != LABEL_ARG) {
			sprintf (AntErrorStr, "illegal data constant");
			return (-1);
		}

		if (s->args [i].val > 255 ||
				s->args [i].val < -128) {
			sprintf (AntErrorStr, "illegal 8-bit constant");
			return (-1);
		}
	}

	return (0);
}

static int check_imm (ant_asm_stmnt_t *s)
{
	/*
	 * 1 register followed by 1 const.  Const can
	 * be integer or label.
	 */

	if (s->num_args != 2) {
		sprintf (AntErrorStr, "invalid number of operands");
		return (-1);
	}

	if (s->args [0].type != REG_ARG) {
		sprintf (AntErrorStr, "first operand must be register");
		return (-1);
	}

	/*
	 * The way that sys constants are specified is a little
	 * different than the way than lc and inc constants.
	 */

	if ((s->op == OP_IN || s->op == OP_OUT) && 
			(s->args [1].type == SYS_CONST_ARG)) {
		return (0);
	}
	else if ((s->args [1].type != INT_ARG) &&
			(s->args [1].type != LABEL_ARG)) {
		sprintf (AntErrorStr,
			"second operand must be an integer or label");
		return (-1);
	}

	if (s->args [1].type == INT_ARG) {
		if (s->args [1].val > 255 ||
				s->args [1].val < -128) {
			sprintf (AntErrorStr, "illegal 8-bit constant");
			return (-1);
		}
	}

	return (0);
}

static int check_jmp (ant_asm_stmnt_t *s)
{

	/*
	 * 1 const.  Const can be integer or label.
	 */

	if (s->num_args != 1) {
		sprintf (AntErrorStr, "invalid number of operands");
		return (-1);
	}

	if ((s->args [0].type != INT_ARG) &&
			(s->args [0].type != LABEL_ARG)) {
		sprintf (AntErrorStr,
				"operand must be an integer or label");
		return (-1);
	}

	if (s->args [0].type == INT_ARG) {
		if (s->args [0].val > 255 ||
				s->args [0].val < 0) {
			sprintf (AntErrorStr,
					"illegal unsigned 8-bit constant");
			return (-1);
		}
	}

	return (0);
}

/*
 * end of ant_asm_check.c
 */
