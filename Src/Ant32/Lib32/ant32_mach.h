#ifndef	_ANT32_MACH_H_
#define	_ANT32_MACH_H_

/* $Id: ant32_mach.h,v 1.3 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_mach.h -- header file for the ANT-32 machine.
 *
 * The definitions here define the basic properties of the ANT-32
 * machine, and some data structures that can be useful to
 * implementing a virtual version of this machine in C.
 */


 
	/*
	 * &&& Assumption:  the integers on the host computer are at
	 * least 32-bits in size.  Otherwise, the following typedef's
	 * will not work as expected, and life will become remarkably
	 * more painful.
	 */

typedef	unsigned int	ant_inst_t;
typedef	unsigned int	ant_addr_t;
typedef	int		ant_reg_t;
typedef	double		ant_freg_t;
typedef	unsigned int	ant_pc_t;

/*
 * The following macros define the number of bits are in the various
 * sorts of addresses:  instruction addresses, data addresses, and
 * register numbers.  ANT_OP_CODE_BITS defines the number of bits in
 * the op field of an ANT instruction, ANT_ADDR_BITS defines the
 * number of bits in an ANT memory address, ANT_REG_ADDR_BITS defines
 * the number of bits in a general register address, and ANT_FREG_ADDR_BITS
 * defines the number of bits in a floating point register address.
 */

#define	ANT_OP_CODE_BITS	8
#define	ANT_VADDR_BITS		32
#define	ANT_PADDR_BITS		30
#define	ANT_REG_ADDR_BITS	8
#define	ANT_FREG_ADDR_BITS	8

/*
 * ANT_DATA_BITS is the number of bits in each general register, the
 * native word size of the architecture.  This must, by necessity, be
 * greater than or equal to ANT_ADDR_BITS.
 */

#define	ANT_DATA_BITS		32

	/*
	 * &&& define the most restrictive memory alignment to be 8
	 * bytes, instead of 4, in case doubles get added later.
	 */

#define MAX_ANT_ALIGN		8

	/*
	 * Assuming 2's complement representation, the largest int we
	 * can represent in ANT_DATA_BITS is 2^(ANT_DATA_BITS-1)-1,
	 * and the smallest is -(2^(ANT_DATA_BITS-1)).
	 *
	 * These definitions only work as long as ANT_DATA_BITS is
	 * smaller than the number of bits in an int on the native
	 * machine, which is not generally the case.
	 *
	 * Note the roundabout way of specifying MIN_ANT_INT-- we
	 * construct a positive number that has half the magnitude of
	 * the min int, and then multiply it by -2.  We can't just
	 * construct a positive number with the correct magnitude and
	 * then negate it, because no such positive 32-bit number
	 * exists in this representation, and we might be running on
	 * 32-bit hardware.  (Other methods exist, but depending on
	 * the compiler, may fail for the same reason.) Yucky.
	 */

#define	MIN_ANT_INT		(-2 * (1 << (ANT_DATA_BITS - 2)))
#define	MAX_ANT_INT		(-(MIN_ANT_INT + 1))

/* The memory address space starts at zero and has a top address of
 * ANT_ADDR_RANGE-1.  Similarly, register numbers range from 0 to
 * ANT_REG_RANGE-1.
 *
 * These constants are defined here to have the largest possible
 * values, given the number of bits available for each type of
 * address.  However, it is very rare for an ANT to actually have a
 * complete 32-bit address space, and at some point there may be ANTs
 * with fewer registers.
 */

#define	ANT_VADDR_RANGE		(1 << ANT_VADDR_BITS)
#define	ANT_PADDR_RANGE		(1 << ANT_PADDR_BITS)

#define	ANT_REG_RANGE		(1 << ANT_REG_ADDR_BITS)
#define	ANT_FREG_RANGE		(1 << ANT_FREG_ADDR_BITS)
#define	ANT_MAX_TLB_ENTRIES	1024

/*
 * Define the SMALLEST permissible number of registers and TLB
 * entries.  For any practical purpose, an Ant32 can't have fewer than
 * these.  You can redefine them to be smaller if you dare.
 */

#define	ANT_MIN_N_REG		8
#define	ANT_MIN_N_FREG		4
#define	ANT_MIN_N_TLB		4

/* The ANT-32 architecture reserves two special registers: One that
 * always holds the constant zero, and the other that holds the floating
 * point constant 0.0.
 * In the version of ANT-32, these are always registers 0 and 1, respectively,
 * but you should use these definitions in case the designers change
 * their minds later.
 */

#define	ZERO_REG		0
#define	ZERO_FREG		0

/* The following macros define what each nibble or word in an
 * instruction signifies, counting up from the right (the low-order
 * bits).  See ant.txt for more information, and ant_bits.c for
 * related functions.
 */

#define	OP_BYTE			3
#define	REG1_BYTE		2
#define	REG2_BYTE		1
#define	REG3_BYTE		0
#define	CONST_WORD		0
#define	CONST_HWORD		0
#define	CONST_BYTE		0

/* Listings (and types) for the constants for all the opcodes and
 * syscalls.
 */

#define	ANT_ARITH_PREF		0x00	
#define ANT_ARITHO_PREF		0x10
#define ANT_ARITHI_PREF		0x20
#define	ANT_COMPARE_PREF	0x30
#define	ANT_BRANCH_PREF		0x40
#define	ANT_MEM_PREF		0x50
#define	ANT_FP_PREF		0x80
#define	ANT_TLB_PREF		0xA0
#define	ANT_CONST_PREF		0xD0
#define	ANT_RAND_PREF		0xE0
#define	ANT_SYS_PREF		0xF0

/*
 * The pseudo-ops are defined here for the sake of simplicity.  The
 * are NOT part of the architecture, and are only used by the
 * assembler.
 */

#define	ANT_POP_PREF		0x100

#define	GET_OP_PREF(x)	((x) & 0xf0)

typedef	enum	{
	OP_ADD		= ANT_ARITH_PREF | 0x0,
	OP_SUB		= ANT_ARITH_PREF | 0x1,
	OP_MUL		= ANT_ARITH_PREF | 0x2,
	OP_DIV		= ANT_ARITH_PREF | 0x3,
	OP_MOD		= ANT_ARITH_PREF | 0x4,
	OP_SHR		= ANT_ARITH_PREF | 0x5,
	OP_SHRU		= ANT_ARITH_PREF | 0x6,
	OP_SHL		= ANT_ARITH_PREF | 0x7,
	OP_OR		= ANT_ARITH_PREF | 0x8,
	OP_NOR		= ANT_ARITH_PREF | 0x9,
	OP_XOR		= ANT_ARITH_PREF | 0xA,
	OP_AND		= ANT_ARITH_PREF | 0xB,

	OP_MULO		= ANT_ARITHO_PREF | 0x2,

	OP_ADDI		= ANT_ARITHI_PREF | 0x0,
	OP_SUBI		= ANT_ARITHI_PREF | 0x1,
	OP_MULI		= ANT_ARITHI_PREF | 0x2,
	OP_DIVI		= ANT_ARITHI_PREF | 0x3,
	OP_MODI		= ANT_ARITHI_PREF | 0x4,
	OP_SHRI		= ANT_ARITHI_PREF | 0x5,
	OP_SHRUI	= ANT_ARITHI_PREF | 0x6,
	OP_SHLI		= ANT_ARITHI_PREF | 0x7,

	OP_EQ		= ANT_COMPARE_PREF | 0x0,
	OP_GT		= ANT_COMPARE_PREF | 0x1,
	OP_GE		= ANT_COMPARE_PREF | 0x2,
	OP_GTU		= ANT_COMPARE_PREF | 0x9,
	OP_GEU		= ANT_COMPARE_PREF | 0xA,

	OP_BEZ		= ANT_BRANCH_PREF | 0x0,
	OP_BNZ		= ANT_BRANCH_PREF | 0x1,
	OP_BEZI		= ANT_BRANCH_PREF | 0x2,
	OP_BNZI		= ANT_BRANCH_PREF | 0x3,
	OP_JRAL		= ANT_BRANCH_PREF | 0x8,

	OP_LD1		= ANT_MEM_PREF | 0x0,
	OP_LD4		= ANT_MEM_PREF | 0x1,
	OP_LDF		= ANT_MEM_PREF | 0x2,
	OP_ST1		= ANT_MEM_PREF | 0x8,
	OP_ST4		= ANT_MEM_PREF | 0x9,
	OP_STF		= ANT_MEM_PREF | 0xA,

	OP_FADD		= ANT_FP_PREF | 0x0,
	OP_FSUB		= ANT_FP_PREF | 0x1,
	OP_FMUL		= ANT_FP_PREF | 0x2,
	OP_FDIV		= ANT_FP_PREF | 0x3,
	OP_FEQ		= ANT_FP_PREF | 0x4,
	OP_FGT		= ANT_FP_PREF | 0x5,
	OP_FGE		= ANT_FP_PREF | 0x6,
	OP_FLT		= ANT_FP_PREF | 0x8,
	OP_FIX		= ANT_FP_PREF | 0x9,
	OP_R2F		= ANT_FP_PREF | 0xE,
	OP_F2R		= ANT_FP_PREF | 0xF,

	OP_LTLBI	= ANT_TLB_PREF | 0x0,
	OP_LTLBE	= ANT_TLB_PREF | 0x1,
	OP_STLBE	= ANT_TLB_PREF | 0x2,
	OP_STLBA	= ANT_TLB_PREF | 0x3,
	OP_CTLBA	= ANT_TLB_PREF | 0x4,

	OP_LC		= ANT_CONST_PREF | 0x0,
	OP_LCH		= ANT_CONST_PREF | 0x1,

	OP_RAND		= ANT_RAND_PREF | 0x0,
	OP_SRAND	= ANT_RAND_PREF | 0x1,

	OP_SYS		= ANT_SYS_PREF | 0x0,
	OP_RSYS		= ANT_SYS_PREF | 0x1,
	OP_RFE		= ANT_SYS_PREF | 0x2,
	OP_INFO		= ANT_SYS_PREF | 0x3,
	OP_CIN		= ANT_SYS_PREF | 0x8,
	OP_COUT		= ANT_SYS_PREF | 0x9,

	POP_LCW		= ANT_POP_PREF	| 0x0,
	POP_JMP		= ANT_POP_PREF	| 0x1

} ant_op_t;

typedef	enum	{
	SYS_HALT	= 0x0,
	SYS_DUMP	= 0x1,
	SYS_PUT_CHAR	= 0x2,
	SYS_GET_CHAR	= 0x3,
	SYS_PUT_INT	= 0x4,
	SYS_GET_INT	= 0x5,
	SYS_PUT_STR	= 0x6
} ant_sys_t;

	/*
	 * The execution mode is either super (supervisory) or user. 
	 * In user mode, only some of the segment registers are
	 * accessible, and some instructions cannot be performed.  In
	 * super mode, anything goes.
	 */

typedef	enum	{
	ANT_SUPER_MODE	= 0x0,
	ANT_USER_MODE	= 0x1
} ant_exec_mode_t;

typedef	struct	{
	unsigned int	attr;
	unsigned int	phys;
} ant_tlbe_t;

	

unsigned int	ant_get_op (ant_inst_t inst);
unsigned int	ant_get_reg1 (ant_inst_t inst);
unsigned int	ant_get_reg2 (ant_inst_t inst);
unsigned int	ant_get_reg3 (ant_inst_t inst);
unsigned int	ant_get_const8u (ant_inst_t inst);
int		ant_get_const8 (ant_inst_t inst);
unsigned int	ant_get_const16u (ant_inst_t inst);
int		ant_get_const16 (ant_inst_t inst);

/*
 * end of ant32_mach.h
 */
#endif	/* _ANT32_MACH_H_ */
