/*
 * $Id: ant32_exec.c,v 1.43 2002/01/09 21:38:26 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_exec.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>
#include	<assert.h>

#include	"ant_external.h"
#include	"ant32_external.h"

#include	"arith32.h"

static ant_pc_t increment_pc (ant_t *ant, ant_pc_t pc);
static int ant_arith (int op, u_int des, u_int src1, u_int src2, ant_t *ant);
static int ant_aritho (int op, u_int des, u_int src1, u_int src2, ant_t *ant);
static int ant_arithi (int op, u_int des, u_int src1, int imm, ant_t *ant);
static int ant_arithio (int op, u_int des, u_int src1, int imm, ant_t *ant);
static int ant_lc (int op, u_int des, int imm, ant_t *ant);

static int ant_special (int op, u_int des, int imm, ant_t *ant);
static int ant_opt_usr (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant);
static int ant_opt_sys (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant);

static int ant_compare (int op, u_int des, u_int src1, u_int src2, ant_t *ant);
static int ant_branch (int op, u_int reg1, u_int reg2, u_int reg3,
		int offset, ant_pc_t old_pc, ant_t *ant);
static int ant_load_store (int op, u_int reg1, u_int reg2, int offset, ant_t *ant);
static int ant_sys_ops (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant);
int check_des_reg (ant_t *ant, u_int des);
int check_src_reg (ant_t *ant, u_int src);
int set_des_reg (ant_t *ant, u_int des, ant_reg_t val);

static int ant32_check_intr (ant_t *ant);
static void ant32_update_timer (ant_t *ant);

/*
 * ant_exec --
 *
 * Exec the given ant machine.
 *
 * Returns 0 if the machine halted via a STOP instruction, or non-zero
 * if a fault was detected.
 */

int ant_exec (ant_t *ant)
{
	ant_exc_t rc;

	for (;;) {
		while ((rc = ant_exec_inst (ant)) == ANT_EXC_OK)
			;

		/*
		 * If we fell out of the previous loop, then something
		 * odd happened.
		 */

		switch (rc) {
			case ANT_EXC_OK :
				/* hmmm... */
				break;

			case ANT_EXC_HALT :
				return (0);
				break;

			case ANT_EXC_IDLE :
				/* &&& IDLE unfinished! */
				printf ("IDLE not fully supported!!\n");
				break;

			case ANT_EXC_EXC :
				printf ("ERROR: Exception occured with exceptions disabled.\n");
				return (-1);
				break;

			default :
				printf ("??? rc = %d\n", rc);
				break;
		}

	}
}

/*
 * ant_exec_inst --
 *
 * Execute a single instruction.
 */

int ant_exec_inst (ant_t *ant)
{
	u_int op, r1, r2, r3;
	int const8, const16;
	u_int const8u;
	ant_pc_t old_pc;
	ant_inst_t inst;
	ant_exc_t rc;

		/*
		 * Instructions can do anything they like to r0, but
		 * it has no effect.
		 *
		 * How this effect is achieved in hardware is up to
		 * the implementation.  The only important thing is
		 * that any read of r0 MUST get a zero, and any write
		 * to r0 will succeed without failure.
		 */

	ant->reg [ZERO_REG] = 0;

		/*
		 * Update the exception registers, so that if an
		 * exception occurs we're ready to handle it.
		 *
		 * Note that this is ONLY done if exceptions are not
		 * disabled-- so if we're in the middle of handling an
		 * exception, we don't overwrite the values of the
		 * e0-e3 registers, which we'll need to deal with the
		 * exception.
		 */

	if (! ant->exc_disable) {
		ant32_exc_update (ant);
	}

	ant->reg [CYCLE_REG_CPU]++;
	if (ant->mode == ANT_SUPER_MODE) {
		ant->reg [CYCLE_REG_CPU_SUP]++;
	}

	ant32_update_timer (ant);

	old_pc = ant->pc;
	inst = ant32_fetch_inst (ant, ant->pc, &rc, 1);

		/*
		 * If we can't even fetch the instruction, then bail
		 * out right away.
		 *
		 * (The work of recording the necessary info to catch
		 * this exception is done in fetch_inst.)
		 * 
		 */

	if (rc != ANT_EXC_OK) {
		goto throw;
	}

	ant->pc = increment_pc (ant, ant->pc);

	op = ant_get_op (inst);
	r1 = ant_get_reg1 (inst);
	r2 = ant_get_reg2 (inst);
	r3 = ant_get_reg3 (inst);
	const8 = ant_get_const8 (inst);
	const8u = ant_get_const8u (inst);
	const16 = ant_get_const16 (inst);

	switch (GET_OP_PREF (op)) {
	case ANT_ARITH_PREF:
		rc = ant_arith (op, r1, r2, r3, ant);
		break;
	case ANT_ARITHO_PREF:
		rc = ant_aritho (op, r1, r2, r3, ant);
		break;
	case ANT_ARITHI_PREF:
		rc = ant_arithi (op, r1, r2, const8, ant);
		break;
	case ANT_ARITHIO_PREF:
		rc = ant_arithio (op, r1, r2, const8, ant);
		break;
	case ANT_COMPARE_PREF:
		rc = ant_compare (op, r1, r2, r3, ant);
		break;
	case ANT_BRANCH_PREF:
		rc = ant_branch (op, r1, r2, r3, const16, old_pc, ant);
		break;
	case ANT_MEM_PREF:
		rc = ant_load_store (op, r1, r2, const8, ant);
		break;
	case ANT_CONST_PREF:
		rc = ant_lc (op, r1, const16, ant);
		break;
	case ANT_SPECIAL_PREF:
		rc = ant_special (op, r1, const16, ant);
		break;
	case ANT_OPT_USR_PREF:
		rc = ant_opt_usr (op, r1, r2, r3, ant);
		break;
	case ANT_OPT_SYS_PREF:
		rc = ant_opt_sys (op, r1, r2, r3, ant);
		break;
	case ANT_SYS_PREF:
		rc = ant_sys_ops (op, r1, r2, r3, ant);
		break;
	default:
		rc = ANT_EXC_ILL_INS;
		break;
	}

		/*
		 * If life was perfect, then all we would need to do
		 * was set r0 to zero *before* executing each
		 * instruction, as is done above.  However, the
		 * debugger might peek at the registers *after* an
		 * instruction changes r0 but *before* they are reset
		 * to zero.  Therefore, we also reset them to zero
		 * again here, even though this is redundant if the
		 * debugger is not running. 
		 *
		 * It's also redundant if the checking on the des
		 * registers is right.  So, this code shouldn't be
		 * executed.
		 */

	if (ant->reg [ZERO_REG] != 0) {
		printf ("r0 doesn't contain zero!  Resetting it.\n");
		ant->reg [ZERO_REG] = 0;
	}

	if ((rc == ANT_EXC_OK) && (ant->int_disable == 0)) {
		int status;

		status = ant32_check_intr (ant);

		/*
		 * &&& If we've detected an interrupt, then now it's
		 * time to do something about it.
		 *
		 * &&& Right now the only possible "interrupt" is the
		 * timer (a temporary hack, just to get something up
		 * and running).
		 */

		if (status > 0) {
			rc = ANT_EXC_TIMER;
		}
	}

	if (rc <= ANT_EXC_OK) {
		ant_status (rc);
		return (rc);
	}

		/*
		 * The operation tossed a real exception, and wasn't a
		 * memory operation, then setup the catch here.  (If
		 * it was a memory operation, then the catch should
		 * have already been done at the appropriate point in
		 * the memory system.)
		 *
		 * Then, no matter what kind of exception it was, do a
		 * throw.
		 */

	if (GET_OP_PREF (op) != ANT_MEM_PREF) {
		ant32_exc_catch (ant, 0, rc);
	}

throw:
	rc = ant32_exc_throw (ant);
	ant_status (rc);
	return (rc);
}

ant_inst_t ant32_fetch_inst (ant_t *ant, ant_pc_t pc, ant_exc_t *fault,
		int update_e2)
{
	ant_reg_t inst;

	*fault = do_load_store (sizeof (ant_inst_t), ANT_MEM_EXEC,
			ant, (ant_vaddr_t) pc, &inst, update_e2);

	return ((ant_inst_t) inst);
}

static ant_pc_t increment_pc (ant_t *ant, ant_pc_t pc)
{

	return (pc + sizeof (ant_inst_t));
}

static int ant_arith (int op, u_int des, u_int src1, u_int src2, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;
	ant_reg_t val;

	if (check_des_reg (ant, des) < 0 ||
			check_src_reg (ant, src1) < 0 ||
			check_src_reg (ant, src2) < 0) {
		return (ANT_EXC_REG_VIOL);
	}

	switch (op) {
	case OP_ADD	: val = reg [src1] + reg [src2]; break;
	case OP_SUB	: val = reg [src1] - reg [src2]; break;
	case OP_MUL	: val = reg [src1] * reg [src2]; break;
	case OP_DIV	:

		/*
		 * &&& This needs checking.
		 * &&& Is it really this simple?
		 */

		if (reg [src2] == 0) {
			return (ANT_EXC_DIV0);
		}

		if ((reg [src1] == MIN_ANT_INT) && (reg [src2] == -1)) {
			val = 0;
		}
		else {
			val = reg [src1] / reg [src2];
		}
		break;

	case OP_MOD	:
		/* &&& check edge cases. */

		if (reg [src2] == 0) {
			return (ANT_EXC_DIV0);
		}

		val = reg [src1] % reg [src2];
		break;

	case OP_OR	: val = reg [src1] | reg [src2]; break;
	case OP_NOR	: val = ~ (reg [src1] | reg [src2]); break;
	case OP_XOR	: val = reg [src1] ^ reg [src2]; break;
	case OP_AND	: val = reg [src1] & reg [src2]; break;
	case OP_SHR	: val = reg [src1] >> (0x1f & reg [src2]); break;
	case OP_SHRU	:
		val = ((unsigned) reg [src1]) >> (0x1f & reg [src2]);
		break;
	case OP_SHL	: val = reg [src1] << (0x1f & reg [src2]); break;
	default		:
		return (ANT_EXC_ILL_INS);
	}

	set_des_reg (ant, des, val);

	return (ANT_EXC_OK);
}

static int ant_arithi (int op, u_int des, u_int src1, int imm, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;
	ant_reg_t val;

	if (check_des_reg (ant, des) < 0 || check_src_reg (ant, src1) < 0) {
		return (ANT_EXC_REG_VIOL);
	}

	switch (op) {
	case OP_ADDI	: val = reg [src1] + imm; break;
	case OP_SUBI	: val = reg [src1] - imm; break;
	case OP_MULI	: val = reg [src1] * imm; break;
	case OP_DIVI	:
		if (imm == 0) {
			return (ANT_EXC_DIV0);
		}

		if ((reg [src1] == MIN_ANT_INT) && (imm == -1)) {
			val = 0;
		}
		else {
			val = reg [src1] / imm;
		}
		break;

	case OP_MODI	:
		if (imm == 0) {
			return (ANT_EXC_DIV0);
		}
		val = reg [src1] % imm;
		break;

	case OP_SHRI	: val = reg [src1] >> imm; break;
	case OP_SHRUI	: val = ((unsigned) reg [src1]) >> imm; break;
	case OP_SHLI	: val = reg [src1] << imm; break;
	default		:
		return (ANT_EXC_ILL_INS);
	}

	set_des_reg (ant, des, val);

	return (ANT_EXC_OK);
}

static int ant_aritho (int op, u_int des, u_int src1, u_int src2, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;
	ant_reg_t val1, val2;

	if ((des % 2) != 0) {
		return (ANT_EXC_ILL_INS);
	}
	if (check_des_reg (ant, des) < 0 ||
			check_des_reg (ant, des + 1) < 0 ||
			check_src_reg (ant, src1) < 0 ||
			check_src_reg (ant, src2)) {
		return (ANT_EXC_REG_VIOL);
	}


	switch (op) {
	case OP_ADDO :
		val1 = add32x32 (reg [src1], reg [src2], &val2);
		break;
	case OP_SUBO :
		val1 = sub32x32 (reg [src1], reg [src2], &val2);
		break;
	case OP_MULO :
		val1 = mul32x32 (reg [src1], reg [src2], &val2);
		break;

	default:
		return (ANT_EXC_ILL_INS);
	}

	set_des_reg (ant, des, val1);
	set_des_reg (ant, des + 1, val2);

	return (ANT_EXC_OK);
}


static int ant_arithio (int op, u_int des, u_int src1, int imm, ant_t *ant)
{
	ant_reg_t val1, val2;
	ant_reg_t *reg = ant->reg;

	if ((des % 2) != 0) {
		return (ANT_EXC_ILL_INS);
	}
	if (check_des_reg (ant, des) < 0 ||
			check_des_reg (ant, des + 1) < 0 ||
			check_src_reg (ant, src1)) {
		return (ANT_EXC_REG_VIOL);
	}

	switch (op) {
	case OP_ADDIO :
		val1 = add32x32 (reg [src1], imm, &val2);
		break;
	case OP_SUBIO :
		val1 = sub32x32 (reg [src1], imm, &val2);
		break;
	case OP_MULIO :
		val1 = mul32x32 (reg [src1], imm, &val2);
		break;
	default:
		return (ANT_EXC_ILL_INS);
	}

	set_des_reg (ant, des, val1);
	set_des_reg (ant, des + 1, val2);

	return (ANT_EXC_OK);
}

static int ant_lc (int op, u_int des, int imm, ant_t *ant)
{
	unsigned int top; //for sign extension
	ant_reg_t *reg = ant->reg;

	if (check_des_reg (ant, des) < 0) {
		return (ANT_EXC_REG_VIOL);
	}

	switch (op) {
	case OP_LCL	:
		/* yeah, this will break if we're not using 32 bit integers,
		 * but I don't know of a good way to do this without a loop
		 * if I don't assume that, so, umm, I'm gonna.
		 *
		 * oh, btw, this is sign extension code. - NCM
		 */
		top = (imm & (1 << (BITS_PER_HWORD - 1))) ? 0xffff0000 : 0;
		set_des_reg (ant, des, (imm & 0xffff) | top);
		break;
	case OP_LCH	:
		set_des_reg (ant, des,
				(reg [des] & 0xffff) | (imm << BITS_PER_HWORD));
		break;
	default :
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

static int ant_special (int op, u_int des, int imm, ant_t *ant)
{

	switch (op) {
	case OP_INFO :
		if (check_des_reg (ant, des) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		switch (imm) {
		case ANT_INFO_NREG:
			set_des_reg (ant, des, ant->params.n_reg);
			break;
		case ANT_INFO_NTLB:
			set_des_reg (ant, des, ant->params.n_tlb);
			break;
		case ANT_INFO_NSRAND:
			set_des_reg (ant, des, ant32_rand_nbits ());
			break;
		case ANT_INFO_OPTS:
			/* &&& UNFINISHED */
			printf ("info opts: UNFINISHED\n");
			break;
		case ANT_INFO_MANUFAC_ID:
			set_des_reg (ant, des, ANT_VM_MANUFACTURER);
			break;
		case ANT_INFO_SPEC_VER:
			set_des_reg (ant, des, ANT_VM_VERSION);
			break;
		case ANT_INFO_IMP_VER:

			/*
			 * &&& Should do something meaningful here,
			 * when we figure out what that might be.
			 */

			set_des_reg (ant, des, 0);
			break;

		case ANT_INFO_CPU_NUM:

			/*
			 * Always 0, until we write a multi-processor
			 * ANT VM.
			 */

			set_des_reg (ant, des, 0);
			break;
		default:
			set_des_reg (ant, des, 0);
			break;
		}

		break;

        case OP_TRAP	:
		return (ANT_EXC_TRAP);
		break;

	default :
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

static int ant_opt_usr (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant)
{
	int val;

	switch (op) {
        case OP_RAND	: {
		if (check_des_reg (ant, reg1) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		set_des_reg (ant, reg1, (ant32_rand ()));

		break;
	}
        case OP_CIN 	:
		if (check_des_reg (ant, reg1) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		ant32_cin (ant, &val);

		set_des_reg (ant, reg1, val);
		break;

        case OP_COUT	:
		if (check_src_reg (ant, reg2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		ant32_cout (ant, LOWER_BYTE (ant->reg [reg2]));
		break;

	default :
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

static int ant_opt_sys (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;

	/*
	 * NONE of these instructions are available in user mode.
	 */

	if (ant->mode == ANT_USER_MODE) {
		return (ANT_EXC_PRIV_INS);
	}

	switch (op) {
        case OP_SRAND	:

		if (check_src_reg (ant, reg1) ||
				check_src_reg (ant, reg2) ||
				check_src_reg (ant, reg2)) {
			return (ANT_EXC_REG_VIOL);
		}

		ant32_srand (reg [reg1], reg [reg2], reg [reg3]);
		break;

	default :
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

static int ant_compare (int op, u_int des, u_int src1, u_int src2, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;
	ant_reg_t val;

	if (check_des_reg (ant, des) < 0 ||
			check_src_reg (ant, src1) < 0 ||
			check_src_reg (ant, src2) < 0) {
		return (ANT_EXC_REG_VIOL);
	}

	switch (op) {
	case OP_EQ :
		val = (reg [src1] == reg [src2]) ? 1 : 0;
		break;
	case OP_GTS :
		val = (reg [src1] > reg [src2]) ? 1 : 0;
		break;
	case OP_GES :
		val = (reg [src1] >= reg [src2]) ? 1 : 0;
		break;
	case OP_GTU :
		val = (((unsigned) reg [src1]) >
				((unsigned) reg [src2])) ? 1 : 0;
		break;
	case OP_GEU :
		val = (((unsigned) reg [src1]) >=
				((unsigned) reg [src2])) ? 1 : 0;
		break;
	default :
		return (ANT_EXC_ILL_INS);
	}

	set_des_reg (ant, des, val);

	return (ANT_EXC_OK);
}

static int ant_branch (int op, u_int reg1, u_int reg2, u_int reg3,
		int offset, ant_pc_t old_pc, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;

	if (op == OP_JEZ || op == OP_JNZ || op == OP_BEZ || op == OP_BNZ) {
		u_int des = reg1;
		u_int src1 = reg2;
		u_int src2 = reg3;

		if (check_des_reg (ant, des) < 0 ||
				check_src_reg (ant, src1) < 0 ||
				check_src_reg (ant, src2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}
	
		switch (op) {
		case OP_BEZ :
			if (reg [src1] == 0) {
				ant->pc = old_pc + reg [src2];
			}
			break;
		case OP_BNZ :
			if (reg [src1] != 0) {
				ant->pc = old_pc + reg [src2];
			}
			break;
		case OP_JEZ :
			if (reg [src1] == 0) {
				ant->pc = reg [src2];
			}
			break;
		case OP_JNZ :
			if (reg [src1] != 0) {
				ant->pc = reg [src2];
			}
			break;
		default :
			ANT_ASSERT ("Unexpected opcode\n");
			break;
		}

		set_des_reg (ant, des, (ant_reg_t) old_pc); 
	}
	else if (op == OP_BEZI || op == OP_BNZI) {
		u_int src1 = reg1;

		if (check_src_reg (ant, src1) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		switch (op) {
		case OP_BEZI :
			if (reg [src1] == 0) {
				ant->pc = old_pc + (4 * offset);
			}
			break;
		case OP_BNZI :
			if (reg [src1] != 0) {
				ant->pc = old_pc + (4 * offset);
			}
			break;
		default :
			ANT_ASSERT ("Unexpected opcode\n");
			break;
		}
	}
	else {
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

static int ant_load_store (int op, u_int reg1, u_int reg2, int offset, ant_t *ant)
{
	ant_vaddr_t	vaddr	= ant->reg [reg2] + offset;
	char		val1;
	ant_reg_t	val4;
	ant_reg_t	tmp;
	ant_exc_t	rc;

	if (check_src_reg (ant, reg2) < 0) {
		ant32_exc_catch(ant, 0, ANT_EXC_REG_VIOL);
		return (ANT_EXC_REG_VIOL);
	}

	/*
	 * This logic isn't complete, but since CURRENTLY if a
	 * register can serve as a des then it must be able to serve
	 * as a src, we can treat EX as if it was just a LD. 
	 * Something to be careful about later...
	 */

	if (op == OP_LD1 || op == OP_LD4 || op == OP_EX4) {
		if (check_des_reg (ant, reg1) < 0) {
			ant32_exc_catch (ant, 0, ANT_EXC_REG_VIOL);
			return (ANT_EXC_REG_VIOL);
		}
	}
	else {
		if (check_src_reg (ant, reg1) < 0) {
			ant32_exc_catch (ant, 0, ANT_EXC_REG_VIOL);
			return (ANT_EXC_REG_VIOL);
		}
	}

	switch (op) {
	case OP_LD1	:
		rc = do_load_store (1, ANT_MEM_READ, ant, vaddr, &val1, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}
		set_des_reg (ant, reg1, val1);
		break;
	case OP_LD4	:
		rc = do_load_store (4, ANT_MEM_READ, ant, vaddr, &val4, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}
		set_des_reg (ant, reg1, val4);
		break;

	case OP_ST1	:
		val1 = ant->reg [reg1];
		rc = do_load_store (1, ANT_MEM_WRITE, ant, vaddr, &val1, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}
		break;
	case OP_ST4	:
		val4 = ant->reg [reg1];
		rc = do_load_store (4, ANT_MEM_WRITE, ant, vaddr, &val4, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}
		break;

	case OP_EX4	:
		val4 = ant->reg [reg1];
		rc = do_load_store (4, ANT_MEM_READ, ant, vaddr, &tmp, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}

		rc = do_load_store (4, ANT_MEM_WRITE, ant, vaddr, &val4, 1);
		if (rc != ANT_EXC_OK) {
			return (rc);
		}
		set_des_reg (ant, reg1, tmp);
		break;

	default:
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

/*
 * The return value indicates what, if anything, went wrong.
 */

int do_load_store (u_int size, ant_mem_op_t mode,
		ant_t *ant, ant_vaddr_t vaddr, void *des,
		int update_e2)
{
	ant_addr_t paddr;
	ant_vma_t ant_addr;
	ant_exc_t fault;

	if (mode == ANT_MEM_READ) {
		ant->reg [CYCLE_REG_READ]++;
	}
	else if (mode == ANT_MEM_WRITE) {
		ant->reg [CYCLE_REG_WRITE]++;
	}
	else {
		/* We don't count fetches right now. */
	}

	/*
	 * Check alignment first.
	 */

	if ((vaddr % size) != 0) {
		ant32_exc_catch (ant, mode, ANT_EXC_ALIGN);
		return (ANT_EXC_ALIGN);
	}

	paddr = ant32_v2p (vaddr, ant, ant->mode, mode, &fault, update_e2);
	if (fault != ANT_EXC_OK) {
		ant32_exc_catch (ant, mode, fault);
		return (fault);
	}

#ifndef	IS_BIG_ENDIAN

	if (size != 4) {
		ant_paddr_t new_paddr;

		new_paddr = paddr & ~3;
		switch (paddr % 4) {
			case 0 : new_paddr += 3; break; 
			case 1 : new_paddr += 2; break; 
			case 2 : new_paddr += 1; break; 
			case 3 : new_paddr += 0; break; 
		}

		paddr = new_paddr;
	}

#endif	/* Not IS_BIG_ENDIAN */

	ant_addr = ant32_p2vm (paddr, ant->pmem, mode);
	if (ant_addr == NULL) {
		ant32_exc_catch (ant, mode, ANT_EXC_BUS_ERR);
		return (ANT_EXC_BUS_ERR);
	}

	/*
	 * An "exec" access is a read, just with a different
	 * permission check.
	 */

	if (mode & (ANT_MEM_READ | ANT_MEM_EXEC)) {
		memmove (des, ant_addr, size);
	}
	else {
		memmove (ant_addr, des, size);
	}

	return (ANT_EXC_OK);
}

static int ant_sys_ops (int op, u_int reg1, u_int reg2, u_int reg3, ant_t *ant)
{
	ant_reg_t *reg = ant->reg;
	ant_reg_t val;
	u_int tlbi;
	u_int seg, vpn, po;
	ant_exc_t fault;
	ant_reg_t rc;

	/*
	 * NONE of these instructions are available in user mode.
	 */

	if (ant->mode == ANT_USER_MODE) {
		return (ANT_EXC_PRIV_INS);
	}

	switch (op) {
	case OP_TLBPI :
		if (check_des_reg (ant, reg1) < 0 ||
				check_src_reg (ant, reg2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		ant32_vaddr_split (ant->reg [reg2], &seg, &vpn, &po);
		rc = ant32_find_tlb_entry (ant->tlb,
				ant->params.n_tlb, seg, vpn, &fault);

		if (fault != ANT_EXC_OK) {
			return (fault);
		}

		ant->reg [reg1] = rc;

		break;

	case OP_TLBLE :
		if ((reg1 % 2) != 0) {
			return (ANT_EXC_ILL_INS);
		}
		if (check_des_reg (ant, reg1) < 0 ||
				check_des_reg (ant, reg1 + 1) < 0 ||
				check_src_reg (ant, reg2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		tlbi = (u_int) ant->reg [reg2];

		if (tlbi >= ant->params.n_tlb) {
			return (ANT_EXC_TLB_INV);
		}

		/* &&& CHECK ME */
		reg [reg1 + 0] = ant->tlb [tlbi].lower;
		reg [reg1 + 1] = ant->tlb [tlbi].upper;
		break;

	case OP_TLBSE :
		if ((reg3 % 2) != 0) {
			return (ANT_EXC_ILL_INS);
		}
		if (check_src_reg (ant, reg2) < 0 ||
				check_src_reg (ant, reg3) < 0 ||
				check_src_reg (ant, reg3 + 1) < 0) {
			return (ANT_EXC_REG_VIOL);
		}

		tlbi = (u_int) ant->reg [reg2];

		if (tlbi >= ant->params.n_tlb) {
			return (ANT_EXC_TLB_INV);
		}

		/* &&& CHECK */
		ant->tlb [tlbi].lower = reg [reg3 + 0];
		ant->tlb [tlbi].upper = reg [reg3 + 1];
		//DEBUG
		break;

	case OP_LEH :
		if (check_src_reg (ant, reg2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}
		ant->eh = ant->reg [reg2];
		break;

	case OP_RFE :
		if (check_src_reg (ant, reg1) < 0 ||
				check_src_reg (ant, reg2) < 0 ||
				check_src_reg (ant, reg3) < 0) {
			return (ANT_EXC_REG_VIOL);
		}
		ant->pc = ant->reg [reg1];
		ant->int_disable = ant->reg [reg2] & 1;
		ant->exc_disable = 0;
		ant->mode = (ant->reg [reg3] & 1) ? ANT_USER_MODE : ANT_SUPER_MODE;

		break;

		/*
		 * &&& This is a bogus hack just to get something
		 * functional.  IT SHOULD BE REMOVED.  &&&
		 */

	case OP_TIMER:
		if (check_des_reg (ant, reg1) < 0 ||
				check_src_reg (ant, reg2) < 0) {
			return (ANT_EXC_REG_VIOL);
		}
		val = ant->reg [reg2];
		set_des_reg (ant, reg1, ant->timer);
		ant->timer = val;

		if (ant->timer > 0) {
			ant->timer_set = 1;
		}
		else {
			ant->timer_set = 0;
		}
		break;

	case OP_HALT:
		return (ANT_EXC_HALT);
		break;

	case OP_IDLE:

		/*
		 * If the timer is set, then STOP will cause the timer
		 * to immediately reach zero and go off.
		 */

		if ((ant->int_disable != 0) && (ant->timer_set != 0)) {
			printf ("Ant32: ALLOWING TIMER TO EXPIRE\n");
			ant->timer = 0;
			ant->timer_set = 0;
			return (ANT_EXC_TIMER);
		}
		else {
			return (ANT_EXC_IDLE);
		}

		break;

	case OP_CLI:
		ant->int_disable = 0;
		break;
	case OP_STI:
		ant->int_disable = 1;
		break;
	case OP_CLE:
		ant->exc_disable = 0;
		break;
	case OP_STE:
		ant->exc_disable = 1;
		break;

	default :
		return (ANT_EXC_ILL_INS);
	}

	return (ANT_EXC_OK);
}

int set_des_reg (ant_t *ant, u_int des, ant_reg_t val)
{
	int rc = check_des_reg (ant, des);

	switch (rc) {
		case 0 :
			ant->reg [des] = val;
			break;

		case -1 :
			/* Read-only register-- do nothing. */
			break;

		default :

			/* A fault!  But this fault SHOULD have been
			 * detected earlier, so here we just ignore
			 * the assignment.
			 */

			break;
	}

	return (0);
}

/*
 * Check whether the des register is valid or not, given the current
 * ant register set and the current operating mode.
 *
 * zero - the destination is settable in the current mode.
 *
 * positive - read-only register.  Valid destination, but no effect.
 *
 * negative - invalid register address.
 *
 * There is repeated code between the user and supervisor mode checks,
 * but it seems better to seperate these at a high level, at least for
 * now.
 */

int check_des_reg (ant_t *ant, u_int des)
{

		/*
		 * Common cases
		 */

	if (des == ZERO_REG) {
		return (1);
	}
	else if (des < ant->params.n_reg) {
		return (0);
	}
	else if (des >= MIN_CYCLE_REG && des <= MAX_CYCLE_REG) {
		return (0);
	}

	if (ant->mode == ANT_SUPER_MODE) {
		switch (des) {
			case SUP_REG_0 :
			case SUP_REG_1 :
			case SUP_REG_2 :
			case SUP_REG_3 :
				return (0);
			case EXC_REG_0 :
			case EXC_REG_1 :
			case EXC_REG_2 :
			case EXC_REG_3 :
				return (-1);
			default :
				return (-1);
		}
	}

	return (-1);
}

/*
 * Check whether the src register is valid or not, given the current
 * ant register set and the current operating mode.
 *
 * zero - the destination is readable in the current mode.
 *
 * negative - invalid register address.
 */

int check_src_reg (ant_t *ant, u_int src)
{

	if (src < ant->params.n_reg) {
		return (0);
	}
	else if (src >= MIN_CYCLE_REG && src <= MAX_CYCLE_REG) {
		return (0);
	}

	if (ant->mode == ANT_SUPER_MODE) {
		switch (src) {
			case SUP_REG_0 :
			case SUP_REG_1 :
			case SUP_REG_2 :
			case SUP_REG_3 :

			case EXC_REG_0 :
			case EXC_REG_1 :
			case EXC_REG_2 :
			case EXC_REG_3 :
				return (0);
			default :
				return (-1);
		}
	}

	return (-1);
}

/*
 * &&& This function is just a placeholder!  It only implements bogus
 * timer interrupts and not the whole pantheon of possible devices.
 */

static int ant32_check_intr (ant_t *ant)
{

	if ((ant->timer_set != 0) && (ant->timer == 0)) {
		ant->timer_set = 0;
		return (1);
	}

	return (0);
}

static void ant32_update_timer (ant_t *ant)
{

	if ((ant->timer_set != 0) && (ant->timer > 0)) { 
		ant->timer--;
	}
}

/*
 * end of ant32_exec.c
 */
