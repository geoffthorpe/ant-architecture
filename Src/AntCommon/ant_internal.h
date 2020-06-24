#ifndef _ANT_INTERNAL_H
#define _ANT_INTERNAL_H

/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 * ant_internal.h
 */

/*
 * from ant_error.h
 */

char	*ant_err_get (void);

/*
 * in llist.c  Functions that operate on linked lists:
 */
llist_t		*llist_create(char *string, int value, int type, 
						  ant_jumpmode_t jumpmode);
void		llist_destroy(llist_t *cell);
llist_t		*llist_insert(llist_t *cell, char *string, int value, int type,
						  ant_jumpmode_t jumpmode);
llist_t		*llist_lookup_str(llist_t *cell, char *string);
llist_t		*llist_lookup_val (llist_t *cell, int value);
llist_t		*llist_delete(llist_t *cell, llist_t *dead);

/*
 * from ant_asm_symtab.h
 */
typedef	llist_t	ant_sym_t;

/*
 * from ant_parse.h
 */
#define	COMMENT_CHAR	'#'
#define	LABEL_TERM_CHAR	':'
#define	ARG_SEP_CHAR	','
#define	CHAR_QUOTE_CHAR	'\''
#define	STRING_CHAR	'"'
#define	REG_PREFIX	'r'
#define	FREG_PREFIX	'f'
#define	LABEL_PREFIX	'$'
#define	BIN_PREFIX	"0b"
#define	HEX_PREFIX	"0x"
#define	OCT_PREFIX	"0"

char		*parse_stmnt_err (void);

/*
 * in ant_string.c
 */
char		*substring (char *str, unsigned int start, unsigned int len);
void 		remove_trailing_blanks (char *str);
int		check_label_name (char *label, int len);

/* for backpatching
 * moved from ant_backpatch.c by NCM 6/19/01
 */
typedef	enum	{
	PATCH_BYTE,
	PATCH_HWORD,
	PATCH_WORD,
	PATCH2_HWORD
} ant_bpatch_mode_t;

int		do_patch (char *memory, unsigned int index, 
				  unsigned int size, int val);
int		ant_backpatch (char *memory, ant_symtab_t *syms, int offset, int mode);

#endif	/* _ANT_INTERNAL_H */
