/*
 * $Id: ant32_check.c,v 1.25 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 05/25/2000
 *
 * ant32_aa_check.c --
 *
 */
 
#include	"ant32_external.h"
#include	"ant_external.h"

static	int	check_no_args (ant_asm_stmnt_t *s);  

static	int	check_des_reg (ant_asm_stmnt_t *s);
static	int	check_1reg (ant_asm_stmnt_t *s);
static	int	check_2reg (ant_asm_stmnt_t *s);
static	int	check_2reg_and_const8 (ant_asm_stmnt_t *s);
static	int	check_reg (ant_asm_arg_t *a, char *desc);

static	int	check_imm (ant_asm_stmnt_t *s, int bits);
static	int	check_const (ant_asm_stmnt_t *s, int size);
static	int	check_string (ant_asm_stmnt_t *s);
static	int	check_jmp (ant_asm_stmnt_t *s);;

static	int	check_3reg (ant_asm_stmnt_t *s);

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

		case ASM_OP_DEFINE:
			/* &&& Really should check... */
			return (0);
			break;

		case ASM_OP_TEXT:
		case ASM_OP_DATA:
	  		return (check_no_args (s));
			break;

		case ASM_OP_BYTE:
			return (check_const (s, CONST_BYTE));
			break;

		case ASM_OP_WORD:
			return (check_const (s, CONST_WORD));
			break;

		case ASM_OP_ASCII:
		case ASM_OP_ASCIIZ:
			return (check_string (s));
			break;

		case ASM_OP_ALIGN:
		case ASM_OP_ADDR:
			if (s->num_args > 1) {
				sprintf (AntErrorStr,
					"only one operand allowed");
				return (-1);
			}
			return (check_const (s, CONST_WORD));
			break;

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
			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_ADDI	:	
		case OP_SUBI	:
		case OP_MULI	:
		case OP_DIVI	:
		case OP_MODI	:
		case OP_ORI	:
		case OP_NORI	:
		case OP_XORI	:
		case OP_ANDI	:
			return(0); break; /* no checks to allow pseudo ops - SS */
		case OP_SHRI	:
		case OP_SHRUI	:
		case OP_SHLI	:
			return(0); break; /* no checks to allow pseudo ops - SS */

		case OP_ADDO	:	
		case OP_SUBO	:
		case OP_MULO	:
			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_ADDIO	:	
		case OP_SUBIO	:
		case OP_MULIO	:
			return(0); break; /* no checks to allow pseudo ops - SS */

		case OP_EQ	:
		case OP_GTS	:
		case OP_GES	:
		case OP_GTU	:
		case OP_GEU	:
			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_LTS	:	/* pseudo op */
		case OP_LES	:	/* pseudo op */
		case OP_LTU	:	/* pseudo op */
		case OP_LEU	:	/* pseudo op */

			/*
			 * even though these are pseudo-ops, we can
			 * still check them for sanity.
			 */

			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_BEZ	:
		case OP_JEZ	:
		case OP_BNZ	:
		case OP_JNZ	:
			return (check_des_reg (s) || check_3reg (s));
			break;

		case OP_BEZI	:
		case OP_BNZI	:
		case OP_B   	:       /* pseudo op */
		case OP_J   	:       /* pseudo op */
		case OP_JEZI	:	/* pseudo op */
		case OP_JNZI	:	/* pseudo op */
			return(0); break; /* no checks to allow pseudo ops - SS */

		case OP_LD1	:
		case OP_LD4	:
			return (check_des_reg (s) || check_2reg_and_const8 (s));
			break;

		case OP_ST1	:
		case OP_ST4	:
			return (check_2reg_and_const8 (s));
			break;

		case OP_EX4	:
			return (check_des_reg (s) || check_2reg_and_const8 (s));
			break;

		case OP_LC 	:	/* pseudo op */
			return (check_des_reg (s) || check_imm (s, 32));
			break;

		case OP_LCL	:
		case OP_LCH	:
			return (check_des_reg (s) || check_imm (s, 16));
			break;

		case OP_TRAP	:
		case OP_HALT	:
		case OP_IDLE	:
		case OP_CLI	:
		case OP_STI	:
		case OP_CLE	:
		case OP_STE	:
	  		if (check_no_args (s)== -1) {
			  return (check_const (s, CONST_BYTE));
			}
  
			break;

		case OP_INFO	:
			return (check_des_reg (s) || check_imm (s, 16));
			break;

		case OP_RAND	:
			return (check_des_reg (s));
			break;
		case OP_SRAND	:
			return (check_3reg (s));
			break;

		case OP_CIN	:
		case OP_COUT	:
			return (check_1reg (s));
			break;

		case OP_TLBPI	:
		case OP_TLBLE	:
		case OP_TLBSE	:
                        return (check_2reg (s));
                        break;

		case OP_LEH	:
			return (0);	/* pseudo-op */
			break;

		case OP_RFE	:
			return (check_3reg (s));
			break;

		case OP_TIMER	:
			return (check_2reg (s));
			break;

		case OP_MOV	:	/* pseudo op */
		case OP_PUSH	:	/* pseudo op */
		case OP_POP	:	/* pseudo op */
		case OP_ENTRY	:	/* pseudo op */
		case OP_CALL	:	/* pseudo op */
		case OP_RETURN	:	/* pseudo op */
			return(0); break; /* no checks to allow pseudo ops - SS */

		default		:
			sprintf (AntErrorStr, "(0x%x): unknown opcode", s->op);
			return (-1);
	}

	return (0);
}

static int check_no_args (ant_asm_stmnt_t *s)
{
	if (s->num_args != 0) {
		sprintf (AntErrorStr, "invalid number of args, should be 0");
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
	if (reg == ZERO_REG) {
		sprintf (AntErrorStr, "WARNING: r%d is read-only!\n", reg);
	}

	if (reg < 0) {
		sprintf (AntErrorStr, "ERROR: r%d is invalid.\n", reg);
		return (-1);
	}

	if (reg >= (int) AntParameters.n_reg && reg < MIN_CYCLE_REG) {
		sprintf (AntErrorStr, "ERROR: r%d is invalid.\n", reg);
		return (-1);
	}

	return (0);
}

static int check_2reg_and_const8 (ant_asm_stmnt_t *s)
{
	/*
	 * 3 args, two registers and a 8-bit constant.
	 */
	if (s->num_args != 3) {
		sprintf (AntErrorStr, "invalid number of operands");
		return (-1);
	}
	if (s->args [0].type != REG_ARG) {
		sprintf (AntErrorStr, "1st arg must be a register");
		return (-1);
	}
	if (s->args [1].type != REG_ARG) {
		sprintf (AntErrorStr, "2nd arg must be a register");
		return (-1);
	}
        if ((s->args [2].type != INT_ARG) &&
                        (s->args [2].type != LABEL_ARG)) {

                sprintf (AntErrorStr,
                        "third operand must be an integer or label");
                return (-1);
        }
	if (s->args [2].type == INT_ARG) {
		if (s->args [2].val < 0 || s->args [2].val >= 256) {
		sprintf (AntErrorStr,
				"third operand must be a 8-bit constant");
		return (-1);
		}
	}

	return (0);
}

static int check_1reg (ant_asm_stmnt_t *s)
{

	if (s->num_args != 1) {
		sprintf (AntErrorStr, "invalid number of operands, should be 1");
		return (-1);
	}
	else if (check_reg (&s->args [0], "des")) {
		sprintf (AntErrorStr, "des must be a register");
		return (-1);
	}
	else if (check_reg (&s->args [0], "src1")) {
		sprintf (AntErrorStr, "src1 must be a register");
		return (-1);
	}
	else {
		return (0);
	}
}

static int check_2reg (ant_asm_stmnt_t *s)
{

	/*
	 * 2 args, all must be valid registers.
	 */

	if (s->num_args != 2) {
		sprintf (AntErrorStr,"invalid number of operands, should be 2");
		return (-1);
	}
	else if (check_reg (&s->args [0], "des")) {
		sprintf (AntErrorStr, "des must be a register");
		return (-1);
	}
	else if (check_reg (&s->args [0], "src1")) {
		sprintf (AntErrorStr, "src1 must be a register");
		return (-1);
	}
	else {
		return (0);
	}
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
	else if (check_reg (&s->args [0], "des")) {
		sprintf (AntErrorStr, "des must be a register");
		return (-1);
	}
	else if (check_reg (&s->args [1], "src1")) {
		sprintf (AntErrorStr, "src1 must be a register");
		return (-1);
	}
	else if (check_reg (&s->args [2], "src2")) {
		sprintf (AntErrorStr, "src2 must be a register");
		return (-1);
	}
	else {
		return (0);
	}
}

static int check_reg (ant_asm_arg_t *arg, char *desc)
{

	if (arg->type != REG_ARG) {
		sprintf (AntErrorStr, "%s must be a register", desc);
		return (-1);
	}
	else if (arg->reg >= (int) AntParameters.n_reg &&
			arg->reg < MIN_CYCLE_REG) {
		sprintf (AntErrorStr, "%s invalid (>= %d)",
				desc, AntParameters.n_reg);
		return (-1);
	}
	else {
		return (0);
	}
}

static int check_const (ant_asm_stmnt_t *s, int size)
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

		if (size == CONST_WORD) {
			if (type != INT_ARG && type != LABEL_ARG) {
				sprintf (AntErrorStr, "illegal data constant");
				return (-1);
			}
		}
		else if (size == CONST_BYTE) {
			if (type != INT_ARG) {
				sprintf (AntErrorStr, "illegal byte constant");
				return (-1);
			}

			if (s->args [i].val > 255 ||
					s->args [i].val < -128) {
				sprintf (AntErrorStr, "illegal 8-bit constant");
				return (-1);
			}
		}
		else {
			ANT_ASSERT (0);
		}
	}

	return (0);
}

static int check_string (ant_asm_stmnt_t *s)
{

	if (s->num_args != 1) {
		sprintf (AntErrorStr, "invalid number of operands %d (.ascii)", s->num_args);
		return (-1);
	}
	else if (s->args [0].type != STRING_ARG) {
		sprintf (AntErrorStr, "operand must be a string");
		return (-1);
	}
	else {
		return (0);
	}
}

static int check_imm (ant_asm_stmnt_t *s, int bits)
{
	long max_unsigned;
	int min_signed;

	/*
	 * 1 register followed by 1 const.  Const can
	 * be integer or label.
	 */

	if (s->num_args != 2) {
		sprintf (AntErrorStr, "invalid number of operands %d (reg const)", s->num_args);
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

	if ((s->args [1].type != INT_ARG) &&
			(s->args [1].type != LABEL_ARG)) {
		sprintf (AntErrorStr,
			"second operand must be an integer or label");
		return (-1);
	}

	/*
	 * Note the chicanery necessary to compute the max unsigned
	 * integer when the number really is the max.  What we need to
	 * do is compute half the max, subtract one, then compute it again
	 * and find the sum.
	 * Note: this is done rather than 2^bits - 1, because it would
         * overflow if bits were 32 ...SS
	 */

	max_unsigned	= 1 << (bits - 1);
	max_unsigned	-= 1;
	max_unsigned 	+= 1 << (bits - 1);

	min_signed	= - (1 << (bits - 1));

	if (bits == 32) {

		/*
		 * &&& Just assume that anything goes.  This
		 * isn't really valid, but proper checking is
		 * too hard for my foggy mind right now.
		 */

		 return (0);
	}

	if (s->args [1].type == INT_ARG) {

		if (s->args [1].val > max_unsigned) {
			sprintf (AntErrorStr, "illegal %d-bit constant", bits);
			sprintf (AntErrorStr, "val = %d, max = %lu, min = %d\n",
					s->args [1].val,
					max_unsigned, min_signed);
			return (-1);
		}
		else if (s->args [1].val < min_signed) {
			sprintf (AntErrorStr, "illegal %d-bit constant", bits);
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
				"operand must be an integer or label.\n");
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
 * end of ant32_aa_check.c
 */
