#ifndef	_ANT32_EXTERNAL_H_
#define	_ANT32_EXTERNAL_H_

#include	<stdio.h>
#include <sys/types.h>
#include	"ant_external.h"

/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * The definitions here define the basic properties of the ANT-32
 * machine, and some data structures that can be useful to
 * implementing a virtual version of this machine in C.
 */

/*
 * from ant32_mach.h
 */
 
	/*
	 * &&& Assumption:  the integers on the host system are at
	 * least 32-bits in size.  Otherwise, the following typedef's
	 * will not work as expected.
	 */

typedef	unsigned int	ant_inst_t;

typedef	unsigned int	ant_addr_t;
typedef	int		ant_reg_t;
typedef	unsigned int	ant_pc_t;

/*
 * The following macros define the number of bits are in the various
 * sorts of addresses:  instruction addresses, data addresses, and
 * register numbers.  ANT_OP_CODE_BITS defines the number of bits in
 * the op field of an ANT instruction, ANT_ADDR_BITS defines the
 * number of bits in an ANT memory address, ANT_REG_ADDR_BITS defines
 * the number of bits in a general register address.
 */

#define	ANT_OP_CODE_BITS	8
#define	ANT_VADDR_BITS		32
#define	ANT_PADDR_BITS		30
#define	ANT_REG_ADDR_BITS	8

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
#define	ANT_MAX_TLB_ENTRIES	1024

/* The ANT-32 architecture reserves several special registers:  One
 * that always holds the constant zero (r0), cycle counters, and a
 * bunch of exception and supervisor-mode registers.
 */

#define	ZERO_REG		0

 				/*
				 * The cycle counters:  r/w in all
				 * modes.
				 */

#define	MIN_CYCLE_REG		240
#define	CYCLE_REG_CPU		240
#define	CYCLE_REG_CPU_SUP	241
#define	CYCLE_REG_TLB_MISS	242
#define	CYCLE_REG_CACHE_MISS	243
#define	CYCLE_REG_IRQ		244
#define	CYCLE_REG_EXC		245
#define	CYCLE_REG_READ		246
#define	CYCLE_REG_WRITE		247
#define	MAX_CYCLE_REG		247


				/* READ/WRITE in sup mode	*/
#define	SUP_REG_0		248	/* aka k0		*/
#define	SUP_REG_1		249	/* aka k1		*/
#define	SUP_REG_2		250	/* aka k2		*/
#define	SUP_REG_3		251	/* aka k3		*/

				/* READ ONLY in supervisor mode */
#define	EXC_REG_0		252	/* aka e0, shadow pc	*/
#define	EXC_REG_1		253	/* aka e1, int mask	*/
#define	EXC_REG_2		254	/* aka e2, TLB latch	*/
#define	EXC_REG_3		255	/* aka e3, exception	*/

#define IS_EXC_REG(a) ((a) >= EXC_REG_0 && (a) <= EXC_REG_3)

/*
 * Define the SMALLEST (and largest) permissible number of registers and TLB
 * entries.  According to the spec, an Ant-32 doesn't conform unless
 * it has at least these many.  You can redefine them to be smaller if
 * you dare.
 *
 * MIN_N_REG, MAX_N_REG hardwired to 64 for first release.  &&&
 */

#define	ANT_MIN_N_REG		64
#define	ANT_MAX_N_REG		240

#define	ANT_MIN_N_TLB		32
#define	ANT_MAX_N_TLB		1024

/* The following macros define what each nibble or word in an
 * instruction signifies, counting up from the right (the low-order
 * bits).
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

#define	ANT_SPECIAL_PREF	0x10
#define	ANT_OPT_USR_PREF	0x20
#define	ANT_SYS_PREF		0x40
#define	ANT_OPT_SYS_PREF	0x60

#define	ANT_ARITH_PREF		0x80	
#define ANT_ARITHI_PREF		0x90
#define ANT_ARITHO_PREF		0xA0
#define ANT_ARITHIO_PREF	0xB0
#define	ANT_COMPARE_PREF	0xC0
#define	ANT_BRANCH_PREF		0xD0
#define	ANT_MEM_PREF		0xE0
#define	ANT_CONST_PREF		0xF0

/*
 * The pseudo-ops are defined here for the sake of simplicity.  They
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
	OP_OR		= ANT_ARITH_PREF | 0x5,
	OP_NOR		= ANT_ARITH_PREF | 0x6,
	OP_XOR		= ANT_ARITH_PREF | 0x7,
	OP_AND		= ANT_ARITH_PREF | 0x8,
	OP_SHR		= ANT_ARITH_PREF | 0xC,
	OP_SHRU		= ANT_ARITH_PREF | 0xD,
	OP_SHL		= ANT_ARITH_PREF | 0xE,

	OP_ADDI		= ANT_ARITHI_PREF | 0x0,
	OP_SUBI		= ANT_ARITHI_PREF | 0x1,
	OP_MULI		= ANT_ARITHI_PREF | 0x2,
	OP_DIVI		= ANT_ARITHI_PREF | 0x3,
	OP_MODI		= ANT_ARITHI_PREF | 0x4,
	OP_SHRI		= ANT_ARITHI_PREF | 0xC,
	OP_SHRUI	= ANT_ARITHI_PREF | 0xD,
	OP_SHLI		= ANT_ARITHI_PREF | 0xE,

	OP_ADDO		= ANT_ARITHO_PREF | 0x0,
	OP_SUBO		= ANT_ARITHO_PREF | 0x1,
	OP_MULO		= ANT_ARITHO_PREF | 0x2,

	OP_ADDIO	= ANT_ARITHIO_PREF | 0x0,
	OP_SUBIO	= ANT_ARITHIO_PREF | 0x1,
	OP_MULIO	= ANT_ARITHIO_PREF | 0x2,

	OP_GTS		= ANT_COMPARE_PREF | 0x1,
	OP_EQ		= ANT_COMPARE_PREF | 0x2,
	OP_GES		= ANT_COMPARE_PREF | 0x3,
	OP_GTU		= ANT_COMPARE_PREF | 0x5,
	OP_GEU		= ANT_COMPARE_PREF | 0x7,

	OP_BEZ		= ANT_BRANCH_PREF | 0x0,
	OP_JEZ		= ANT_BRANCH_PREF | 0x1,
	OP_BNZ		= ANT_BRANCH_PREF | 0x2,
	OP_JNZ		= ANT_BRANCH_PREF | 0x3,
	OP_BEZI		= ANT_BRANCH_PREF | 0x4,
	OP_BNZI		= ANT_BRANCH_PREF | 0x6,

	OP_LD1		= ANT_MEM_PREF | 0x0,
	OP_LD4		= ANT_MEM_PREF | 0x2,
	OP_ST1		= ANT_MEM_PREF | 0x4,
	OP_ST4		= ANT_MEM_PREF | 0x6,
	OP_EX4		= ANT_MEM_PREF | 0xA,

	OP_LCL		= ANT_CONST_PREF | 0x0,
	OP_LCH		= ANT_CONST_PREF | 0x1,

	OP_TRAP		= ANT_SPECIAL_PREF | 0x0,
	OP_INFO		= ANT_SPECIAL_PREF | 0x1,

	OP_RAND		= ANT_OPT_USR_PREF | 0x0,
	OP_SRAND	= ANT_OPT_SYS_PREF | 0x1,
	OP_CIN		= ANT_OPT_USR_PREF | 0x4,
	OP_COUT		= ANT_OPT_USR_PREF | 0x5,

	OP_TLBPI	= ANT_SYS_PREF | 0x0,
	OP_TLBLE	= ANT_SYS_PREF | 0x1,
	OP_TLBSE	= ANT_SYS_PREF | 0x2,
	OP_LEH		= ANT_SYS_PREF | 0x4,
	OP_RFE		= ANT_SYS_PREF | 0x5,

	OP_STI		= ANT_SYS_PREF | 0x8,
	OP_CLI		= ANT_SYS_PREF | 0x9,
	OP_STE		= ANT_SYS_PREF | 0xA,
	OP_CLE		= ANT_SYS_PREF | 0xB,

	OP_TIMER	= ANT_SYS_PREF | 0xD,	/* ??? */
	OP_IDLE		= ANT_SYS_PREF | 0xE,	/* ??? */
	OP_HALT		= ANT_SYS_PREF | 0xF,

	/*
	 * Pseudo-ops BEGIN HERE.
	 */

	OP_LTS		= ANT_POP_PREF | ANT_COMPARE_PREF | 0x1,
	OP_LES		= ANT_POP_PREF | ANT_COMPARE_PREF | 0x3,
	OP_LTU		= ANT_POP_PREF | ANT_COMPARE_PREF | 0x5,
	OP_LEU		= ANT_POP_PREF | ANT_COMPARE_PREF | 0x7,

	OP_B		= ANT_POP_PREF | ANT_BRANCH_PREF | 0x8,
	OP_J		= ANT_POP_PREF | ANT_BRANCH_PREF | 0x9,
	OP_JEZI		= ANT_POP_PREF | ANT_BRANCH_PREF | 0xA,
	OP_JNZI		= ANT_POP_PREF | ANT_BRANCH_PREF | 0xB,

	OP_LC 		= ANT_POP_PREF | ANT_CONST_PREF | 0x2,

	OP_MOV		= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x2,
	OP_PUSH		= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x3,
	OP_POP		= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x4,
	OP_CALL		= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x5,
	OP_RETURN	= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x6,
	OP_ENTRY	= ANT_POP_PREF | ANT_SPECIAL_PREF | 0x7,

	OP_ORI		= ANT_POP_PREF | ANT_ARITHI_PREF | 0x5,
	OP_NORI		= ANT_POP_PREF | ANT_ARITHI_PREF | 0x6,
	OP_XORI		= ANT_POP_PREF | ANT_ARITHI_PREF | 0x7,
	OP_ANDI		= ANT_POP_PREF | ANT_ARITHI_PREF | 0x8

} ant_op_t;

typedef	enum	{
	ANT_INFO_NREG		= 0,
	ANT_INFO_NTLB		= 2,
	ANT_INFO_NSRAND		= 3,
	ANT_INFO_OPTS		= 5,
	ANT_INFO_MANUFAC_ID	= 6,
	ANT_INFO_SPEC_VER	= 7,
	ANT_INFO_CPU_NUM	= 8,
	ANT_INFO_IMP_VER	= 9
} ant_info_t;

	/*
	 * The execution mode is either super (supervisory) or user. 
	 * In user mode, only some of the segments are accessible, and
	 * some instructions cannot be performed.  In super mode,
	 * anything goes.
	 */

typedef	enum	{
	ANT_USER_MODE	= 0x0,
	ANT_SUPER_MODE	= 0x1
} ant_exec_mode_t;

typedef	struct	{
	unsigned int	upper;	/* was phys */
	unsigned int	lower;	/* was attr */
} ant_tlbe_t;

#define	ANT_TLB_PHYS_PN(t)	(((t).upper >> 12) & 0x3ffff)
#define	ANT_TLB_ATTR(t)		((t).upper & 0xfff)

#define	ANT_TLB_VIRT_SEG(t)	(((t).lower >> 30) & 0x3)
#define	ANT_TLB_VIRT_PN(t)	(((t).lower >> 12) & 0x3ffff)
#define	ANT_TLB_VIRT_SEGPN(t)	(((t).lower >> 12) & 0xfffff)
#define	ANT_TLB_OS_INFO(t)	((t).lower & 0xfff)


unsigned int	ant_get_op (ant_inst_t inst);
unsigned int	ant_get_reg1 (ant_inst_t inst);
unsigned int	ant_get_reg2 (ant_inst_t inst);
unsigned int	ant_get_reg3 (ant_inst_t inst);
unsigned int	ant_get_const8u (ant_inst_t inst);
int		ant_get_const8 (ant_inst_t inst);
unsigned int	ant_get_const16u (ant_inst_t inst);
int		ant_get_const16 (ant_inst_t inst);

/*
 * from ant32_bits.h
 */

/*
 * ant32_bits.h -- Some ugly macros for dealing with bit-level details
 * of the ANT architecture, and how to express these details in C.
 */

	/*
	 * &&& ASSUMPTION:  the machine we're using to host the ANT
	 * virtual machine has 8-bit bytes, and 32-bit integers (or
	 * integers of more than 32-bits).  If this is not true, then
	 * a lot of this gets quite clumsy.
	 *
	 * &&& ASSUMPTION:  the machine that we're using uses standard
	 * two's-complement binary notation to represent integers
	 * (which is extrememly common today).  The MASK macros could
	 * fail on some old and/or weird machines.
	 */

#define	BITS_PER_BYTE		8
#define	BITS_PER_HWORD		(2 * BITS_PER_BYTE)
#define	BYTE_MASK		(unsigned int)((1 << BITS_PER_BYTE) - 1)
#define	HWORD_MASK		(unsigned int)((1 << BITS_PER_HWORD) - 1)

	/*
	 * Macros to GET the n'th byte (counting from the RIGHT) from
	 * the given binary word x.
	 */

#define	GET_BYTE(x,n)	(((x) >> (n * BITS_PER_BYTE)) & BYTE_MASK)
#define	GET_HWORD(x,n)	(((x) >> (n * BITS_PER_HWORD)) & HWORD_MASK)

	/*
	 * Macros to SET the n'th byte (counting from the RIGHT) of
	 * the given binary word x to q.
	 */

#define	PUT_BYTE(x,q,n)		\
	((((q) & BYTE_MASK) << (n * BITS_PER_BYTE)) | \
			((x) & ~(BYTE_MASK) << (n * BITS_PER_BYTE)))
#define	PUT_HWORD(x,q,n)		\
	((((q) & HWORD_MASK) << (n * BITS_PER_HWORD)) | \
			((x) & ~(HWORD_MASK) << (n * BITS_PER_HWORD)))

	/*
	 * A few handy wrappers for GET_HWORD.
	 */

#define	HI_16(x)	GET_HWORD(x, 1)
#define	LO_16(x)	GET_HWORD(x, 0)

#define	LOWER_BYTE(x)	((x) & 0xff)
#define	LOWER_WORD(x)	((x) & 0xffffffff)

/*
 * This should be in ant32_pmem.h
 */

/*
 * virtual addresses are unsigned because there is no such thing as an
 * invalid virtual address.  (It might invalid to *do* anything with
 * that address, but every 32-bit number has the potential to be a
 * valid virtual address...)
 *
 * physical addresses are signed because they aren't all valid, but
 * all valid addresses will be less than 2^30.  This means we can use
 * sign to indicate validity.
 *
 * VM addresses are just good old generic char pointers, pointing to
 * some (hopefully valid!) location inside the address space of the
 * VM.  I use char instead of void so that address arithmetic works in
 * a way that makes sense here.  In almost all cases, the pointer
 * should be cast before use, however.
 */

typedef	unsigned int	ant_vaddr_t;
typedef	int		ant_paddr_t;
typedef char		*ant_vma_t;

/*
 * Deal with discontinous memory.
 *
 * Physical memory is implemented as a linked list of blocks of
 * memory.  This is crude but should get the job done for now.
 *
 * Each block of memory can have a callback associated with it.  This
 * callback is invoked every time the memory is read or written.
 */

typedef struct _ant_mblk_t {
	ant_vma_t	mem;
	ant_paddr_t	base;	/* ant phys addr */
	int		len;	/* in bytes */
	int		type;	/* memory operations supported. */
	void		(*cb)(ant_paddr_t paddr);
	struct _ant_mblk_t *next;
} ant_mblk_t;

	/*
	 * Shorthand for how the physical memory is actually
	 * implemented.  This will make it easier to rip this
	 * implementation out, if/when we discover that the current
	 * implementation is not good.
	 */

typedef	ant_mblk_t	*ant_pmem_t;

ant_vma_t	ant32_p2vm (ant_paddr_t paddr, ant_pmem_t pmem,
			unsigned int mode);
ant_pmem_t	ant32_add_mblk (ant_mblk_t *blk, ant_pmem_t pmem);
ant_mblk_t	*ant32_make_mblk (ant_paddr_t paddr, int len, int mode,
			void (*cb)(ant_paddr_t paddr));
void		ant_pmem_clear (ant_pmem_t head, int clear_rom);

/*
 * from ant32_vm.h
 */

typedef	struct	{

		/* n_reg is the number of "regular" registers,
		 * starting with r0.  This does not count all the
		 * cycle counters, exception registers, etc.
		 */

	unsigned int	n_reg;
	
		/*
		 * number of TLB entries
		 */
	unsigned int	n_tlb;
	
		/*
		 * The number of physical pages of RAM.  (assumed to
		 * start at physical location 0, and be contiguous.
		 *
		 * Does not include ROM and bus devices.
		 */

	unsigned int	n_pages;	/* pages of RAM */

		/*
		 * The number of physical pages of ROM.  These are
		 * assumed to be contiguous and start at the end of
		 * physical memory.  There is always at least one.
		 */

	unsigned int	n_rom_pages;	/* pages of ROM */

} ant_param_t;

extern	ant_param_t	AntParameters;

typedef	struct	{
	FILE		*in;
	int		in_val, in_new;
	FILE		*out;
	int		out_val, out_new;
} ant_console_t;

/*
 * A structure that contains all of the information about the state of
 * an ANT-32:  the program counter (pc), all the registers, and the
 * memory.
 */

typedef	struct	{
	ant_exec_mode_t	mode;
	ant_pc_t	pc;
	ant_reg_t	reg [ANT_REG_RANGE];
	ant_pc_t	eh;		/* Exception handler address */
	ant_reg_t	exc_disable;	/* Exception disable flag. */
	ant_reg_t	int_disable;	/* Interrupt disable flag. */
	ant_reg_t	timer;		/* count-down timer */
	int		timer_set;	/* !0 if the timer is active. */
	ant_console_t	console;	/* a single console. */
	ant_tlbe_t	tlb [ANT_MAX_TLB_ENTRIES];
	ant_pmem_t	pmem;		/* See pmem_t for details. */
	ant_param_t	params;
} ant_t;

/*
 * The default memory size of an ANT, which can be overridden during
 * intialization.  This size was chosen because it seems reasonable
 * for wide variety of exercises, but small enough so that it doesn't
 * place a huge burden on the computer that is running the VM.
 */

#define	ANT_DEFAULT_MEM_SIZE	(1024 * 1024)

/* the default number of registers can be changed, this value is 
   stored in AntParameters, defined in ant32_vm.c */

#define	ANT_DEFAULT_NUM_REGS	32

/*
 * &&& Note the cheesy assumption that ANT32 programs are contiguous
 * in memory, start at location 0 (in VM space), and are never longer
 * than ANT_DEFAULT_MEM_SIZE.  This has to go!!
 *
 * This is OK for prototyping but we'll need something better.
 */

#define	ANT_MAX_INSTS	(ANT_DEFAULT_MEM_SIZE)

/*
 * Define the longest line allowable in an ANT program file (in the
 * text format described in ant.txt).
 */

#define	ANT_MAX_LINE_LEN	512

/*
 * in ant32_symtab.h (from ant32.h)
 */
char	*dump32_symtab_human (ant_symtab_t *table, int all);
int	dump32_symtab_machine (ant_symtab_t *table, FILE *stream);

/*
 * in ant32_load.h (from ant32.h)
 */

int	ant_load_text (char *filename, ant_t *ant, int save_code);
int	ant_load_text_info (char *filename, unsigned int *inst_cnt);
int	ant_load_labels (char *filename, ant_symtab_t **table);
int	a32_store_instruction (ant_t *ant,
			unsigned int v_addr, ant_inst_t inst);
/* missing? ant32.h:int             ant_load_bin (char *filename, ant_t *ant);
*/

/*
 * in ant32_code.c
 */

typedef	enum {
	LITERAL, SYNTHETIC, UNKNOWN
} ant32_lcode_t;

void	ant32_code_init (void);
int	ant32_code_line_insert (unsigned int addr, char *line,
		ant32_lcode_t lcode);
char	*ant32_code_line_lookup (unsigned int addr, ant32_lcode_t *lcode);

/*
 * in ant32_vm.h (from ant32_vm.h)
 */


 	/*
	 * The MODE definitions are used in the VM, not the hardware. 
	 * They are used to specify different operations to the
	 * simulator for the memory system.
	 *
	 * EXEC is only necessary for diagnostics.  There isn't any
	 * distinction between read and fetch in the memory system,
	 * just in the MMU.
	 */

typedef	enum	{
		ANT_MEM_READ	= (1 << 2),
		ANT_MEM_WRITE	= (1 << 1),
		ANT_MEM_EXEC	= (1 << 0)
} ant_mem_op_t;

#define	ANT_VM_VERSION		0x0301000b
#define	ANT_VM_MANUFACTURER	0

int		ant_check_params (ant_param_t *params);
ant_t		*ant_create (ant_param_t *params);
int		ant32_cout (ant_t *ant, int val);
int		ant32_cin (ant_t *ant, int *val);

/*
 * in ant32_dump.h (from ant32.h)
 */

int	ant_dump_text (char *filename, ant_t *ant);
char	*ant32_page2str (ant_t *ant, ant_paddr_t paddr, int fmt);
int	ant32_is_zero_page (ant_t *ant, ant_paddr_t paddr);
int	ant32_dump_page (FILE *fout, ant_t *ant, ant_paddr_t paddr, int fmt);

/*
 * in ant32_core.h (from ant32_core.h)
 */

void	ant_asm_init (void);
int	ant_asm_lines (char *asm_filename, char **lines, int line_cnt,
		char *b_mem, unsigned int *inst_cnt, unsigned int *last_addr);
int	ant_asm_init_ant (ant_t *ant, int inst_cnt, ant_inst_t *instTable);
int	ant_asm_assemble_inst (ant_asm_stmnt_t *stmnt, char *b_mem,
		unsigned int b_offset, unsigned int remaining,
		unsigned int *consumed);
int	ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, char *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);

/*
 * should be ant32_exc.h
 */

typedef	enum	{

	/*
	 * All ``real'' exceptions are greater than 0, OK is 0, and
	 * when the processor stops for some reason we get a negative
	 * pseudo-exception.
	 *
	 * HALT, IDLE, and EXC are NOT exceptions, but are cases that
	 * need to be handled in a special manner, and it seems better
	 * to handle this in the general framework of exceptions than
	 * any other way.
	 *
	 * EXC happens when an exception occurs when exceptions are
	 * disabled, a fatal event.  HALT happens when the processor
	 * executes a halt instruction, sending the machine into
	 * limbo.  IDLE is like HALT, execpt the machine just snoozes
	 * until an interrupt occurs or the timer expires.  BREAK
	 * occurs when execution reaches a breakpoint in the debugger. 
	 * USER_INT occurs when the user interrupts the processor via
	 * the debugger.
	 */

	ANT_EXC_USER_INT	= -5,
	ANT_EXC_BREAK		= -4,
	ANT_EXC_EXC		= -3,
	ANT_EXC_HALT		= -2,
	ANT_EXC_IDLE		= -1,

	ANT_EXC_OK		= 0,	/* All is well.		*/

	ANT_EXC_IRQ		= 1,
					/* Exception 2 is reserved. */
	ANT_EXC_BUS_ERR		= 3,
	ANT_EXC_ILL_INS		= 4,
	ANT_EXC_PRIV_INS	= 5,
	ANT_EXC_TRAP		= 6,
	ANT_EXC_DIV0		= 7,
	ANT_EXC_ALIGN		= 8,
	ANT_EXC_PRIV_SEG	= 9,
	ANT_EXC_REG_VIOL	= 10,
	ANT_EXC_TLB_MISS	= 11,
	ANT_EXC_TLB_PROT	= 12,
	ANT_EXC_TLB_MULTI	= 13,
	ANT_EXC_TLB_INV		= 14,

				/*
				 * &&& Not ratified as part of the new
				 * spec, will probably become an
				 * interrupt in the near future.  -DJE
				 * 7/16/01
				 */

	ANT_EXC_TIMER		= 20
} ant_exc_t;

void		ant32_exc_update (ant_t *ant);
int		ant32_exc_throw (ant_t *ant);
int		ant32_exc_catch (ant_t *ant, ant_mem_op_t mem_action,
				ant_exc_t exc);
int		ant32_mem_op2exc (ant_mem_op_t op);

/*
 * in ant32_exec.h (from ant32.h)
 */

int		ant_exec (ant_t *ant);
int		ant_exec_inst (ant_t *ant);
int		do_load_store (u_int size, ant_mem_op_t mode,
			ant_t *ant, ant_vaddr_t vaddr, void *des,
			int update_e2);
ant_inst_t	ant32_fetch_inst (ant_t *ant, ant_pc_t pc, ant_exc_t *fault,
			int update_e2);

/*
 * in ant32_fault.h (from ant32_fault.h)
 */

void		ant_fault (ant_exc_t code, int pc, ant_t *ant, int dump);
char		*ant_status_desc (ant_exc_t status);
void		ant_status (ant_exc_t code);
ant_exc_t	ant_get_status (void);
char		*ant_get_status_str (void);


/*
 * from ant32_boot.h
 */

		/*
		 * The address where the start PC is stored.  (Set to
		 * the PC to whatever is AT this address, not this
		 * address!)
		 */

#define	ANT_RESET_PC_ADDR	0xfffffffc

int		ant_reset (ant_t *ant);

/*
 * from ant32_mmu.h
 */

/*
 * ant32_mmu.h -- MMU emulation for the VM.
 * &&& This is just a sketch, not a complete implementation.
 */

/*
 * Bit fields within a virtual address:
 *
 * &&& These are all hardwired, and mutually dependent.  If you change
 * *anything*, you might have to change nearly *everything*.
 */

#define	ANT_MMU_SEG_BITS	2
#define	ANT_MMU_SEG_MASK	0xc0000000
#define	ANT_MMU_GET_SEGMENT(x)	((((x) & ANT_MMU_SEG_MASK) >> 30) & 0x3)

#define	ANT_MMU_PAGE_BITS	18
#define	ANT_MMU_PAGE_MASK	0x3ffff000
#define	ANT_MMU_GET_PAGE(x)	((((x) & ANT_MMU_PAGE_MASK) >> 12) & 0x3ffff)

#define	ANT_MMU_OFFSET_BITS	12
#define	ANT_MMU_OFFSET_MASK	0x00000fff
#define	ANT_MMU_GET_OFFSET(x)	((x) & ANT_MMU_OFFSET_MASK)
#define	ANT_MMU_PAGE_SIZE	(1 << ANT_MMU_OFFSET_BITS)

#define	ANT_MMU_SEG_USER		0
#define	ANT_MMU_SEG_SUP_MAP		1
#define	ANT_MMU_SEG_SUP_NOMAP		2
#define	ANT_MMU_SEG_SUP_NOMAP_NOCACHE	3

#define	ANT_MMU_EXEC_BIT	0x01
#define	ANT_MMU_WRITE_BIT	0x02
#define	ANT_MMU_READ_BIT	0x04
#define	ANT_MMU_VALID_BIT	0x08
#define	ANT_MMU_DIRTY_BIT	0x10
#define	ANT_MMU_UNCACHE_BIT	0x20

ant_paddr_t	ant32_v2p (ant_vaddr_t v, ant_t *tlb,
			ant_exec_mode_t run_mode,
			unsigned int access_mode,
			ant_exc_t *fault,
			int update_e2);
int		ant32_find_tlb_entry (ant_tlbe_t *tlb, int n_tlbe,
			unsigned int seg, unsigned int vpn,
			ant_exc_t *fault);
int		ant32_vaddr_split (ant_addr_t v, unsigned int *seg,
			unsigned int *vpn, unsigned int *po);
int		ant32_tlb_init (ant_tlbe_t *tlb, int n_tlbe);

/*
 * end of ant32_mmu.h
 */

/*
 * in ant32_check.c
 */

int	ant_asm_args_check (ant_asm_stmnt_t *s);

typedef	enum	{
	DBG_HELP,
	DBG_QUIT,
	DBG_RUN,
	DBG_RELOAD,
	DBG_GO,
	DBG_JUMP,
	DBG_TRACE,
	DBG_NEXT,
	DBG_SET_BP,
	DBG_CLEAR_BP,
	DBG_PRINT_REG,
	DBG_PRINT_BDATA,
	DBG_PRINT_WDATA,
	DBG_PRINT_INST,
	DBG_PRINT_PDATA,
	DBG_PRINT_PINST,
	DBG_PRINT_LABEL,
	DBG_PRINT_ALL_LABEL,
	DBG_PRINT_CYCLE,
	DBG_ZERO,
	DBG_LC,
	DBG_ST4,
	DBG_ST1,
	DBG_EXEC,
	DBG_V2P,
	DBG_STATUS,
	DBG_TLB,
	DBG_REG_NAMES,
	DBG_INST_MODE
} ant_dbg_op_t;

/*
 * ant32_dbg.c
 */

void		ant32_dbg_intr (int val);
int		ant_exec_dbg (ant_t *ant, int trace, int surface);
int		ant_exec_dbg_exc (ant_t *ant, ant_exc_t rc);
int		ant_exec_inst_dbg (ant_t *ant, int trace, int surface);
void		ant_dbg_show_curr_inst (ant_t *ant, int surface);
int		ant32_set_breakpoint (ant_pc_t pc);
int		ant32_check_breakpoint (ant_pc_t pc);
int		ant32_clear_breakpoint (ant_pc_t pc);
int		ant32_clear_breakpoints (void);

/*
 * ant32_reg.c
 */

extern	int	regNamesType;
int		ant32_reg_names_change (int names);
char		*ant32_reg_name (unsigned int reg);

/*
 * ant32_debug.c
 */

void		ant32_show_state (FILE *fout, ant_t *ant, int fmt);
void		ant32_print_reg (FILE *fout, ant_t *ant, int reg);

char		*ant32_dump_cntrl (ant_t *ant, int fmt);
char		*ant32_dump_regs (ant_t *ant, int fmt);
char		*ant32_dump_cycle (ant_t *ant, int fmt);
char		*ant32_dump_eregs (ant_t *ant, int fmt);
char		*ant32_dump_kregs (ant_t *ant, int fmt);
char		*ant32_dump_tlb (ant_t *ant, int fmt);
char		*ant32_dump_vmem_words (ant_t *ant,
			int base, int count, int fmt);
char		*ant32_dump_vmem_bytes (ant_t *ant,
			int base, int count, int fmt);
char		*ant32_dump_vmem_insts (ant_t *ant,
			int base, int count, int fmt);

/*
 * ant32_rand.c
 */

void		ant32_srand (ant_reg_t a, ant_reg_t b, ant_reg_t c);
int		ant32_rand (void);
int		ant32_rand_nbits (void);

/*
 * in ant32_expand_op.c
 */

int asm_expand_op(ant_op_t op_code, ant_asm_stmnt_t *stmnt, char *b_memory,
  unsigned int b_offset, unsigned int remaining, unsigned int *consumed);

/*
 * in ant32_disasm.c
 */

int		ant_disasm_inst (ant_inst_t inst, unsigned int offset,
			ant_reg_t *regs, char *buf, int show_pc);
int		ant_inst_src (ant_inst_t inst, ant_reg_t *reg,
			int *_src1, int *_src2, int *_src3,
			int *_des1, int *_des2,
			int *_waddr, int *_raddr, int *_ovalue,
			char **buf);

/*
 * in ant32_exec.c
 */

int		ant_load_dbg (char *filename, ant_t *ant,
			ant_symtab_t **table);

/* the following were in ant8_external.h and are needed for aide32 ...SS */

typedef char            ant_data_t;
typedef struct  {
        char breakpoints [ANT_MAX_INSTS];
} ant_dbg_bp_t;

#endif	/* _ANT32_EXTERNAL_H_ */
