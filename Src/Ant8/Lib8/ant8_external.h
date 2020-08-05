#ifndef	_ANT8_EXTERNAL_H_
#define	_ANT8_EXTERNAL_H_

/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant8_external.h 
 */

#include	<stdio.h>
#include        "ant_external.h"

/*
 * from ant8_mach.h
 */

/* The following macros define the number of bits are in the various
 * sorts of addresses: instruction addresses, data addresses, and
 * register numbers.  ANT_OP_CODE_BITS defines the number of bits in
 * the op field of an ANT instruction.
 * ANT_DATA_BITS is the number of bits in each location in data memory
 * and each register:
 */

#define	ANT_INST_ADDR_BITS	8
#define	ANT_DATA_ADDR_BITS	8
#define	ANT_REG_ADDR_BITS	4
#define	ANT_OP_CODE_BITS	4
#define	ANT_DATA_BITS		8

	/*
	 * Assuming 2's complement representation, the largest int we
	 * can represent in ANT_DATA_BITS is 2^(ANT_DATA_BITS-1)-1,
	 * and the smallest is -(2^(ANT_DATA_BITS-1)).
	 *
	 * These definitions only work as long as ANT_DATA_BITS is
	 * smaller than the number of bits in an int on the native
	 * machine!
	 */

#define	MAX_ANT_INT		((1 << (ANT_DATA_BITS - 1)) - 1)
#define	MIN_ANT_INT		(-(1 << (ANT_DATA_BITS -1)))

/* The data and instruction address spaces start at zero and have a
 * top address of ANT_INST_ADDR_RANGE-1 and ANT_DATA_ADDR_RANGE-1. 
 * Similarly, register numbers range from 0 to ANT_REG_RANGE-1.
 *
 * These constants are currently defined to have the largest possible
 * values, given the number of bits available for each type of
 * address.  However, this is not necessarily the case; you could
 * imagine a version of the ANT with less data memory or fewer
 * registers (so before accessing any address, check against these
 * constants to see if it's OK).
 */

#define	ANT_INST_ADDR_RANGE	(1 << ANT_INST_ADDR_BITS)
#define	ANT_DATA_ADDR_RANGE	(1 << ANT_DATA_ADDR_BITS)
#define	ANT_REG_RANGE		(1 << ANT_OP_CODE_BITS)

/* The following instruction is used to specify an uninitialized word
 * in instruction memory.  By definition, it cannot represent a valid
 * instruction.  It is an I/O to an illegal channel.
 */

/* The ANT architecture reserves two special registers: One that
 * always holds the constant zero, and the other that holds various
 * useful side-effects from many of the instructions.  In the current
 * version of ANT, these are always registers 0 and 1, respectively,
 * but you should use these definitions in case the designers change
 * their minds later.
 */

#define	ZERO_REG		0
#define	SIDE_REG		1

/* The following macros define what each nibble or word in an
 * instruction signifies, counting up from the right (the low-order
 * bits).  See ant.txt for more information, and ant_bits.c for
 * related functions.
 */

/* Listings (and types) for the constants for all the opcodes.
 */

typedef	enum	{
	OP_HALT	= 0x0,

	OP_LC	= 0x1,
	OP_INC	= 0x2,
	OP_JMP	= 0x3,

	OP_BEQ	= 0x4,
	OP_BGT	= 0x5,
	OP_LD1	= 0x6,
	OP_ST1	= 0x7,

	OP_ADD	= 0x8,
	OP_SUB	= 0x9,
	OP_MUL	= 0xa,
	OP_SHF	= 0xb,
	OP_AND	= 0xc,
	OP_NOR	= 0xd,

	OP_IN	= 0xe,
	OP_OUT	= 0xf

} ant_op_t;

/*
 * Define the longest line allowable in an ANT program file (in the
 * text format described in ant.txt).
 */

/*
 * from ant8_bits.h 
 */

#define	BITS_PER_NIBBLE		4
#define	BITS_PER_BYTE		(2 * BITS_PER_NIBBLE)

	/*
	 * ASSUMPTION:  the machine that we're using uses standard
	 * two's-complement binary notation to represent integers
	 * (which is extrememly common today).  The MASK macros could
	 * fail on some old and/or weird machines.
	 */

#define	NIBBLE_MASK		(unsigned int)((1 << BITS_PER_NIBBLE) - 1)
#define	BYTE_MASK		(unsigned int)((1 << BITS_PER_BYTE) - 1)

	/*
	 * Macros to GET the n'th nibble or byte (counting from the
	 * RIGHT) from the given binary word x.
	 */

#define	GET_NIBBLE(x,n)		(((x) >> (n * BITS_PER_NIBBLE)) & NIBBLE_MASK)
#define	GET_BYTE(x,n)		(((x) >> (n * BITS_PER_BYTE)) & BYTE_MASK)

#define	LOWER_BYTE(x)		GET_BYTE((x),0)
#define	UPPER_BYTE(x)		GET_BYTE((x),1)

	/* Macros to SET the n'th nibble or byte (counting from the
	 * RIGHT) of the given binary word x to q.
	 *
	 * Note that you probably WILL NOT need these to write your
	 * own ANT VM, but feel free to use these in whatever way you
	 * see fit.
	 */

/*
 * from ant8_vm.h
 */

typedef	unsigned short	ant_inst_t;
typedef	char		ant_data_t;
typedef	ant_data_t	ant_reg_t;
typedef	unsigned char	ant_pc_t;

/*
 * A structure that contains all of the information about the state of
 * an ANT:  the program counter (pc), all the registers, and the data
 * and instruction memories.
 *
 * The inst_cnt field is initialized by the loader to be the number of
 * instructions in the program, and used by the debugger to know where
 * the instructions end and the data begins (which is important in the
 * SINGLE_ADDRESS_SPACE version of ANT, which uses the same memory for
 * both data and instructions).
 */

typedef	struct	{
	ant_pc_t	pc;
	ant_reg_t	reg [ANT_REG_RANGE];
	ant_data_t	data [ANT_DATA_ADDR_RANGE];

		/*
		 * Only use with single address space!  Keeps track of
		 * the frontier between instructions and data (at
		 * least, where the *assembler*) thinks that this
		 * boundary is).
		 */
	int		inst_cnt;

} ant_t;

/*
 * from ant8.h
 */

/*
 * in ant8_load.c
 */
int		ant_load_text (const char *filename, ant_t *ant);
void		ant_clear (ant_t *ant);

/*
 * in ant8_dump.c
 */
int		ant_dump_text (char *filename, ant_t *ant);
int		ant_print_reg (FILE *stream, ant_t *ant);
int		ant_print_reg_vec (FILE *stream, ant_t *ant,
			int *vec, int vec_len);

/*
 * in ant8_util.c
 */
void		ant_print_value_str (char *buf, int value, char *label);

/*
 * in ant8_exec.c
 */

int		ant_exec (ant_t *ant);
int		ant_exec_inst (ant_t *ant,
			int *input_reg_index, int *input_type, FILE *out);
ant_inst_t	ant_fetch_instruction (ant_t *ant, ant_pc_t pc);
int		ant8_do_in_buf (int format, char *side_reg);

/*
 * in ant8_core.c
 */
int ant_asm_lines (char *asm_filename, char **lines, int line_cnt,
		ant_inst_t *instTable, int *curr_inst,
		ant_data_t *dataTable, int *curr_data);
int ant_asm_init_ant (ant_t *ant,
		int inst_cnt,
		ant_data_t *dataTable, int data_cnt);
int ant_asm_assemble_inst (ant_asm_stmnt_t *stmnt, ant_inst_t *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);
int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, ant_data_t *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);

/*
 * from ant8_dbg.h
 */

#define	MAX_INST	ANT_INST_ADDR_RANGE
#define	MAX_DATA	ANT_DATA_ADDR_RANGE

typedef	struct	{
	char breakpoints [ANT_INST_ADDR_RANGE];
} ant_dbg_bp_t;

typedef	enum	{
	DBG_UNKNOWN	= -1,
	DBG_HELP	= 'h',
	DBG_QUIT	= 'q',
	DBG_RUN		= 'r',
	DBG_RELOAD	= 'R',
	DBG_GO		= 'g',
	DBG_JUMP	= 'j',
	DBG_BREAK	= 'b',
	DBG_TRACE	= 't',
	DBG_NEXT	= 'n',
	DBG_CLEAR_BP	= 'c',
	DBG_PRINT_REG	= 'p',
	DBG_PRINT_DADDR	= 'd',
	DBG_PRINT_IADDR	= 'i',
	DBG_PRINT_LABEL	= 'l',
	DBG_ZERO	= 'z',
	DBG_STORE	= 's',
	DBG_EXEC	= 'e',
	DBG_WATCH	= 'w',
	DBG_CLEAR_WP	= 'W'
} ant_dbg_op_t;

/* 
 * in ant8_symtab.c
 */
int             dump8_symtab_human (ant_symtab_t *table, char *buf);
int             dump8_symtab_machine (ant_symtab_t *table, FILE *stream);
void            symtab2array (ant_symtab_t *symtab, char *array []);
void            free_label_array (char *array []);

/* 
 * in ant8_dbg.c
 */
void		ant8_dbg_intr (int val);
int		ant_exec_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace);
int		ant_exec_inst_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace);
void 		ant_dbg_clear_bp (ant_dbg_bp_t *a);
void		ant8_dbg_bp_set (ant_dbg_bp_t *b, int offset, int val);
int		ant_load_dbg (const char *filename, ant_t *ant,
			ant_symtab_t **table);

extern	ant_symtab_t	*labelTable;

/*
 * in ant8_dis.c
 */
void		ant_disasm_i_mem_print (ant_t *ant);
void		ant_disasm_d_mem_print (ant_t *ant);
char		*ant_disasm_i_mem (ant_t *ant, int include_all);
char		*ant_disasm_d_mem (ant_t *ant, int show_x, int no_show_empty);
int		ant_disasm_inst (ant_inst_t inst, unsigned int offset,
			ant_data_t *regs, char *buf, int show_pc);
int		ant_inst_src (ant_inst_t inst, ant_data_t *reg,
			int *_src1, int *_src2, int *_src3, int *_des,
			int *_iperiph, int *_operiph, int *_ovalue,
			int *_waddr, int *_raddr);
void		ant_disasm_data_block (ant_data_t *data, unsigned int offset,
			unsigned int count, char *buf, int show_x);

/*
 * in ant8_fault.c
 */
extern	void		ant_status (ant_status_t code);
extern	ant_status_t	ant_get_status (void);
extern	char		*ant_get_status_str (void);

/*
 * int ant8_watch.c
 */

extern	int		ant8_wp_init (void);
extern	int		ant8_wp_set (ant_t *ant, int addr);
extern	int		ant8_wp_clear (int addr);
extern	int		ant8_wp_clear_all (void);
extern	int		ant8_wp_cycle (ant_t *ant, int *oval, int *nval);
extern	int		ant8_wp_update (ant_t *ant);

#endif /* _ANT8_EXTERNAL_H_ */
