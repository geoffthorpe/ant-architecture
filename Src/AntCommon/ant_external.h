#ifndef _ANT_EXTERNAL_H_
#define _ANT_EXTERNAL_H_

/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_external.h
 */

/*
 * from ant_assert.h
 */

#define	ANT_ASSERT(cond)	\
 	if (!(cond)) { \
		printf ("Assertion failed at line %d of %s.\n", \
				__LINE__, __FILE__); \
		fflush (stdout); \
		exit (1); \
	}

/*
 * in ant_error.c
 */

#define	MAX_ERROR_LEN	8192
extern	char	AntErrorStr [MAX_ERROR_LEN];
void	ant_err_clr (void);

/*
 * from ant_fault.h
 */
typedef	enum	{

		/* Things are generally OK... */
	STATUS_RUN	= 0x40,
		/* Things are NOT generally OK... */
	STATUS_FAULT	= 0x80,

	STATUS_OK	= STATUS_RUN | 0x00,
	STATUS_HALT	= STATUS_RUN | 0x01,
	STATUS_INPUT	= STATUS_RUN | 0x02,

	FAULT_ADDR	= STATUS_FAULT | 0x01,
	FAULT_ILL	= STATUS_FAULT | 0x02,

	FAULT_INV	= STATUS_FAULT | 0x03,
	FAULT_ZERO	= STATUS_FAULT | 0x04,
	FAULT_ALIGN	= STATUS_FAULT | 0x05,
	FAULT_SEG	= STATUS_FAULT | 0x06,
	FAULT_BUS	= STATUS_FAULT | 0x07,
	FAULT_MREAD	= STATUS_FAULT | 0x08,
	FAULT_MWRITE	= STATUS_FAULT | 0x09,
	FAULT_MFETCH	= STATUS_FAULT | 0x0A,
	FAULT_PRIV	= STATUS_FAULT | 0x0B

} ant_status_t;

/*
 * in ant_file.c
 */
char **file2lines (char *filename, int *line_cnt);
char **buf2lines (char *buffer, int *line_cnt);

/*
 * from llist.h
 */

//NCM 6/19/01
typedef enum {
	JUMP_ABS = -1, 
	JUMP_REL_0 = 0,
	JUMP_REL_1 = 1,
	JUMP_REL_2 = 2
} ant_jumpmode_t;

/*
 * llist_t -- a structure for building doubly-linked lists.
 */

typedef	struct	_ll_t	{
	struct	_ll_t	*next;	/* ptr to the next cell	*/
	struct	_ll_t	*prev;	/* ptr to the prev cell	*/
	char 		*string;
	int		value;	/* the cell's value.	*/
	int		type;	/* used for a32 backpatching, indicates how label is used, 
					 * ie low 16, hi 16, etc. */
	/* NCM 6/19/01 */
	ant_jumpmode_t jumpmode; /*added to support relative jumps (branches) */
					
} llist_t;

typedef	llist_t	ant_symtab_t;

/*
 * Functions that operate on linked lists:
 */

/*
 * in ant_symtab.c
 */
int		add_symbol (ant_symtab_t **table, char *name, int value,
			char *type);
int		del_symbol (ant_symtab_t **table, char *name);
int		find_symbol (ant_symtab_t *table, char *name, int *value);
int		find_value (ant_symtab_t *table, char **name, int value);
int		add_unresolved (ant_symtab_t **table, char *name,
			int offset, int type);

/* NCM 6/19/01 */
int		add_relative_unresolved 
		(ant_symtab_t **table, char *name, int offset, int type, 
		 ant_jumpmode_t jumpmode);

void		clear_symtab (ant_symtab_t *table);

/*
 * in ant_backpatch.c
 */ 
int		ant8_asm_backpatch (char *instTable, char *dataTable);
int		ant32_asm_backpatch (char *memory);

/*
 * from ant_parse.h
 */

#define	ANT_ASM_MAX_ARGS	8

/*
 * Assembler directives:
 */

#define	ASM_OP_NONE		(-1)
#define	ASM_OP_BYTE		(-2)
#define	ASM_OP_WORD		(-3)
#define	ASM_OP_DEFINE		(-4)
#define	ASM_OP_ALIGN		(-5)
#define	ASM_OP_ASCII		(-6)
#define	ASM_OP_ASCIIZ		(-7)
#define	ASM_OP_TEXT		(-8)
#define	ASM_OP_DATA		(-9)
#define	ASM_OP_ADDR		(-10)

typedef	enum	{
	UNKNOWN_ARG,
	INT_ARG,
	REG_ARG,
	FREG_ARG,
	LABEL_ARG,
	SYS_CONST_ARG,
	SYMBOL_ARG,
	STRING_ARG
} ant_arg_type_t;

typedef	struct	{
	ant_arg_type_t	type;
	int		val;
	int		reg;
	char		*label;
	char		*string;
	unsigned int	strlen;
	int		offset;
} ant_asm_arg_t;

/*
 * A ANT assembly language "statement" is described by the data
 * structure define below.  A statement represents a single line of
 * assembly.
 *
 * Note that the same instruction (or location in data memory) may
 * have several labels, but each "statement" has only one.
 */

typedef	struct	{
	char		*label;
	int		op;
	unsigned int	num_args;
	ant_asm_arg_t	args [ANT_ASM_MAX_ARGS];
} ant_asm_stmnt_t;

typedef	struct	{
	char		*str;
	int		id;
} ant_asm_str_id_t;

extern	int	DesWarnOnly;

/*
 * in ant_parse.c
 */
int		ant_asm_parse_str (char *str, ant_asm_stmnt_t *stmnt,
			ant_symtab_t **constants, int allow_offsets);
void		ant_asm_stmnt_clear (ant_asm_stmnt_t *stmnt);
int		parse_stmnt (char *str, ant_asm_stmnt_t *stmnt,
			ant_asm_str_id_t *mnemonics, int allow_label,
			int allow_offsets);
int		ant_parse_setup (ant_asm_str_id_t *mnemonics);
char		*ant_asm_clean_str (char *str);
int		match_str_id (char *str, unsigned int len,
			ant_asm_str_id_t *array);

/*
 * in ant_console.c
 */

void		ant_console_reset (void);
int		ant_console_enqueue (char *str, unsigned int len);
int		ant_console_dequeue (void);
int		ant_console_peek (void);
int		ant_console_qlen (void);

/*
 * in ant_string.c
 */

char		*skip_whitespace (char *str);

#ifdef	__MWERKS__
char *strdup (char *str);
#endif	/* __MWERKS__ */

/*
 * in ant_sys.h
 */
int             ant_get_int (int *status, int base);

#ifdef	__MWERKS__
#define	ANT_LIB_VERSION		"3.1"
#endif	/* __MWERKS__ */

#ifndef	ANT_LIB_VERSION
#define	ANT_LIB_VERSION		\
"3.1 Devel $Id: ant_external.h,v 1.13 2002/10/08 19:13:32 ellard Exp $ "
#endif	/* ANT_LIB_VERSION */

extern char    *ant_build_version;

/*
 * used in ant_backpatch.c, ant32_expand_op.c
 * in table for unresolved labels, to indicate which byte should be updated
 */

#define BYTE3 13
#define BYTE2 12
#define BYTE1 11
#define BYTE0 10

/*
 * Defined elsewhere:
 */

extern int ant_find_reg (char *str, unsigned int len);

#endif	/* _ANT_EXTERNAL_H */
