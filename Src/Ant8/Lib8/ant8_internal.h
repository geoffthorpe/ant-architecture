#ifndef	_ANT8_INTERNAL_H
#define	_ANT8_INTERNAL_H

/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant8_external.h 
 */

/*
 * from ant8_mach.h
 */

	/*
	 * Assuming 2's complement representation, the largest int we
	 * can represent in ANT_DATA_BITS is 2^(ANT_DATA_BITS-1)-1,
	 * and the smallest is -(2^(ANT_DATA_BITS-1)).
	 *
	 * These definitions only work as long as ANT_DATA_BITS is
	 * smaller than the number of bits in an int on the native
	 * machine!
	 */

#define	MAX_ANT_UINT		((1 << ANT_DATA_BITS) - 1)
#define	MIN_ANT_UINT		0

/* The following instruction is used to specify an uninitialized word
 * in instruction memory.  By definition, it cannot represent a valid
 * instruction.  It is an I/O to an illegal channel.
 */

#define	ILLEGAL_INSTRUCTION	0xffff

/* The following macros define what each nibble or word in an
 * instruction signifies, counting up from the right (the low-order
 * bits).  See ant.txt for more information, and ant_bits.c for
 * related functions.
 */

#define	OP_NIBBLE		3
#define	REG1_NIBBLE		2
#define	REG2_NIBBLE		1
#define	REG3_NIBBLE		0
#define	CONST_BYTE		0
#define	CONST_NIBBLE		0

/*
 * Define the longest line allowable in an ANT program file (in the
 * text format described in ant.txt).
 */

#define	ANT_MAX_LINE_LEN	512

/*
 * from ant8_bits.h 
 */

	/* Macros to SET the n'th nibble or byte (counting from the
	 * RIGHT) of the given binary word x to q.
	 *
	 * Note that you probably WILL NOT need these to write your
	 * own ANT VM, but feel free to use these in whatever way you
	 * see fit.
	 */

#define	PUT_NIBBLE(x,q,n)	\
        ((((unsigned int)(q) & NIBBLE_MASK) << (n * BITS_PER_NIBBLE)) | \
			((x) & ~(NIBBLE_MASK) << (n * BITS_PER_NIBBLE)))
#define	PUT_BYTE(x,q,n)		\
	((((q) & BYTE_MASK) << (n * BITS_PER_BYTE)) | \
			((x) & ~(BYTE_MASK) << (n * BITS_PER_BYTE)))
#define	PUT_SHORT(x,q,n)		\
	((((q) & SHORT_MASK) << (n * BITS_PER_SHORT)) | \
			((x) & ~(SHORT) << (n * BITS_PER_SHORT)))

/*
 * in ant8_bits.c
 */
unsigned int	ant_get_op (long inst);
unsigned int	ant_get_reg1 (long inst);
unsigned int	ant_get_reg2 (long inst);
unsigned int	ant_get_reg3 (long inst);
unsigned int	ant_get_uconst4 (long inst);
int		ant_get_const8 (long inst);

/*
 * in ant8_load.c
 */
int		ant_load_labels (char *filename, ant_symtab_t **table);

/*
 * in ant8_dump.c
 */
int		ant_print_data (FILE *stream, ant_t *ant);

/*
* in ant8_util.c
*/
void		ant_assign_des_reg (ant_data_t *reg, int des_reg,
			ant_data_t val);
void 		ant_word2bits (int word, char *buf);
void 		ant_print_value (FILE *stream, int value, char *label);
void		ant_print_value_str (char *buf, int value, char *label);

/*
 * in ant8_exec.c
 */
ant_pc_t	ant_increment_pc (ant_pc_t pc);

/*
 * in ant8_core.c
 */
int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, ant_data_t *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);

/*
 * in ant8_check.c
 */
int             ant_asm_args_check (ant_asm_stmnt_t *s);

/*
 * in ant8_fault.c
 */
extern	void		ant_fault (ant_status_t code,
				int pc, ant_t *ant, int dump);
#endif /* _ANT8_INTERNAL_H */
