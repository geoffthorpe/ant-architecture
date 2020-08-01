/*
 * $Id: ant_parse.c,v 1.19 2002/05/20 18:40:02 ellard Exp $
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

/*

	&&& This comment is somewhat out of date.  It doesn't include
		the latest 2.0 changes yet.

	Lines of ANT assembly language (ANT_ASM) have the following form:

	Label:	Op Arg-list

	Label:

		The Label is optional.

		Labels follow the same rules as C identifiers.  A
		Label is terminated by a colon (:), and there cannot
		be any whitespace between the end of the label and the
		colon.

		If there is a label, then it must begin in column zero
		(i.e.  on the very first character of the line).  Note
		that only labels and comments can begin in the zero
		column; lines that do not have a label, or do not
		consist entirely of comments or whitespace MUST have
		whitespace in column zero.


	Op

		The Op is either one of the standard ANT_ASM
		instructions (i.e.  add, sub, mul, beq, etc) or the
		special directive ".byte" or ".define".

	Arg-list

		Arg-list is a comma-seperated list of operands for the
		Op.  Each operand is can be one of the following:

		Integer

			An integer constant.  Integer constants can be
			expressed in decimal, hex, or binary.  If the
			integer begins with a "-", then it is treated
			as a negative number.  If (following the "-",
			if any) the next two characters are "0x" then
			the rest of the string is interpreted as hex,
			and if the first two characters are "0b" then
			the rest of the string is interpreted as
			binary.  Otherwise, the characters are
			interpreted as decimal.

		Character

			A character constant.  Similar to C character
			constants, except that the hex and octal
			formats are not supported.

		$Label

			The name of a label.  The label name is
			prefixed by a "$".

		Register

			The name of a ANT register.  (r0 through r15)

	Note that comments may appear anywhere on a line of assembler. 
	A comment is any text starting with a hash sign (#) and
	continuing until the end of the line.  (The only exception to
	this rule is that # can be placed inside a character constant
	(i.e.  '#') without being treated as the beginning of a
	comment.) Comments and the text inside them are completely
	ignored by the parser.

	For example, the following are all valid lines (as far as the
	parsing routines are concerned (although they don't make any
	sense as far as the actual operations are concerned):

	foo:	add r0, r1, 123
		sub $foo, $bar, $qux
		mul ' ', '\n', 0b11
		div 12, 0x12, r12
		.byte '#', 'h', 'i', '.'	# this is a comment


*/

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<ctype.h>
#include	<limits.h>

#include        "ant_external.h"
#include        "ant_internal.h"

static	ant_asm_str_id_t	io_names []	= {
	{ "Hex",	0 },
	{ "Binary",	1 },
	{ "ASCII",	2 },
	{ NULL,		0 }
};

static	int	make_const (ant_asm_stmnt_t *stmnt, ant_symtab_t **constants);
static	int	subst_const (ant_asm_stmnt_t *stmnt, ant_symtab_t *constants);

static	int	find_label (char *str, char **end_ptr, char **label);
static	int	find_op (char *str, char **end_ptr, int *op,
			ant_asm_str_id_t *mnemonics);
static	int	find_arg (char *str, char **end_ptr, ant_asm_arg_t *arg);
static	int	find_offset (char *str, char **end_ptr, ant_asm_arg_t *arg);
static	int	ant_asm_get_integer (char *str, int len, int *val);
static	void	remove_comments (char *str);
static	int	ant_asm_find_char (char *str, char **next, int *val);
static	int	ant_asm_find_string (char *str, char **next, char **res, unsigned int *reslen);

static	ant_asm_str_id_t *Mnemonics	= NULL;

int ant_parse_setup (ant_asm_str_id_t *mnemonics)
{

	Mnemonics = mnemonics;

	return (0);
}

/*
 * ant_parse_str
 *
 * Given a string, parse it as a single stmnt (usually a single line)
 * of ANT assembly, filling in the given stmnt structure with the
 * result.  If this function returns 0, then the string represents a
 * valid ANT instruction.  It may not EXECUTE successfully, and it may
 * contain undefined label references, etc, but at least it is
 * syntactically correct and can be assembled.
 *
 * If this function returns non-zero, then the parse of the string
 * failed and the contents of the stmnt are undefined.  If the parse
 * fails, the parsing routines will attempt to print something
 * meaningful to stdout, in the hope that the user will be able to do
 * something constructive with these error messages.
 *
 */

int ant_asm_parse_str (char *str, ant_asm_stmnt_t *stmnt,
			ant_symtab_t **constants, int allow_offsets)
{
	char *copy;

	ANT_ASSERT (str != NULL);
	ANT_ASSERT (stmnt != NULL);

	ant_asm_stmnt_clear (stmnt);

	copy = ant_asm_clean_str (str);

	ANT_ASSERT (copy != NULL);

	if (strlen (copy) == 0) {
		free (copy);
		return (0);
	}

	if (parse_stmnt (copy, stmnt, Mnemonics, 1, allow_offsets) != 0) {
		free (copy);
		return (-1);
	}

	/*
	 * If there's isn't a label, but there also isn't any
	 * whitespace at the start of the line, then bark at the user
	 * again.  Currently, everything except comments and labels
	 * must be indented.
	 */

	if ((stmnt->label == NULL) && !isspace ((unsigned) *str)) {
		sprintf (AntErrorStr,
			"instructions and directives must be indented");
		return (-1);
	}

	/*
	 * &&& We treat .define somewhat differently than any other
	 * operation or directive-- in a .define statement, we don't
	 * attempt to substitute the value of constants for the first
	 * operand.  For any other kind of statement, we do substitute
	 * for all of the operands.
	 */

	if (stmnt->op == ASM_OP_DEFINE) {
		if (constants == NULL) {

			/*
			 * There may someday be contexts in which new
			 * constants cannot be defined...
			 */

			sprintf (AntErrorStr, "WARNING: "
					"New constants cannot be added");
			free (copy);
			return (0);
		}
		else if (make_const (stmnt, constants) != 0) {
			free (copy);
			return (-1);
		}
		else {
			free (copy);
			return (0);
		}
	}

	if ((constants != NULL) && (subst_const (stmnt, *constants) != 0)) {
		free (copy);
		return (-1);
	}
	else {
		free (copy);
		return (0);
	}
}

/*
 * ant_asm_stmnt_clear --
 *
 * Initialize the contents of the given stmnt to an empty state.
 */

void		ant_asm_stmnt_clear (ant_asm_stmnt_t *stmnt)
{
	int		i;

	stmnt->label	= NULL;
	stmnt->op	= ASM_OP_NONE;
	stmnt->num_args	= 0;

	for (i = 0; i < ANT_ASM_MAX_ARGS; i++) {
		stmnt->args [i].type = UNKNOWN_ARG;
		stmnt->args [i].val = 0;
		stmnt->args [i].reg = 0;
		stmnt->args [i].label = NULL;
		stmnt->args [i].offset = 0;
	}

	return ;
}

static int make_const (ant_asm_stmnt_t *stmnt, ant_symtab_t **constants)
{
	int value;
	ant_asm_arg_t *args;
	int temp;

	ANT_ASSERT (stmnt != NULL);

	args = stmnt->args;

	if (args [0].type != SYMBOL_ARG) {
		sprintf (AntErrorStr,
			"first operand to .define must be a symbol name");
		return (-1);
	}

	if (args [1].type == SYMBOL_ARG) {
		if (find_symbol (*constants, args [1].label, &value)) {
			sprintf (AntErrorStr,
					"undefined symbol (%s)",
					args [1].label);
			return (-1);
		}
	}
	else if (args [1].type == INT_ARG) {
		value = args [1].val;
	}
	else {
		sprintf (AntErrorStr,
			"value of a .define must be an integer or constant");
		return (-1);

	}

	if (find_symbol (*constants, args [0].label, &temp) == 0) {
		del_symbol (constants, args [0].label);
	}

	return (add_symbol (constants, args [0].label, value,
				"Constant"));
}

static int subst_const (ant_asm_stmnt_t *stmnt, ant_symtab_t *constants)
{
	ant_asm_arg_t *a;
	unsigned int i;

	for (i = 0; i < stmnt->num_args; i++) {
		a = &stmnt->args [i];
		if (a->type == SYMBOL_ARG) {
			if (find_symbol (constants,
					a->label, &a->val) == 0) {
				a->type = INT_ARG;
			}
			else {
				sprintf (AntErrorStr,
						"unrecognized constant (%s)",
						a->label);
				return (-1);
			}
		}
	}

	return (0);
}


/*
 * parse_stmnt --
 *
 */

int		parse_stmnt (char *str, ant_asm_stmnt_t *stmnt,
			ant_asm_str_id_t *mnemonics, int allow_label,
			int allow_offsets)
{
	char		*next;
	int		rc;
	int		args;

	next = str;

	if (allow_label) {
		rc = find_label (next, &next, &stmnt->label);
		if (rc != 0) {
			sprintf (AntErrorStr, "bad label");
			return (-1);
		}

		/*
		 * By definition, labels must start in column zero,
		 * and nothing else (except a comment) can start in
		 * column zero.  Comments have already been removed by
		 * this point, so if there's something in column zero,
		 * we assume that it might be a label, and proceed
		 * accordingly.
		 *
		 * If the string doesn't start in column zero, then we
		 * know it's not a *legal* label-- but we check
		 * whether it is an illegally indented label just in
		 * case, so we can chastise the programmer
		 * appropriately.
		 */

		if ((stmnt->label != NULL) && isspace ((unsigned) *str)) {
			sprintf (AntErrorStr,
					"labels must start in column zero");
			return (-1);
		}
	}

	next = skip_whitespace (next);

	if (allow_label) {

		/*
		 * It's valid for there to be just a label (and
		 * nothing else) on a line.
		 */

		if ((stmnt->label != NULL) && (*next == '\0')) {
			return (0);
		}
	}

	rc = find_op (next, &next, &stmnt->op, mnemonics);
	if (rc != 0) {
		sprintf (AntErrorStr, "unrecognized instruction");
		return (-1);
	}

	next = skip_whitespace (next);

	if (*next == '\0') {
		return (0);
	}

	for (args = 0; args < ANT_ASM_MAX_ARGS; args++) {
		char *tmp;

		AntErrorStr [0] = '\0';
		rc = find_arg (next, &tmp, &stmnt->args [args]);
		if (rc != 0) {

			/*
			 * If there isn't already an error string,
			 * then shove in this generic one.  Otherwise,
			 * if there's an error use the current error
			 * string.
			 */

			if (! AntErrorStr [0]) {
				sprintf (AntErrorStr, "illegal operand: (%s)", next);
			}
			return (-1);
		}

		next = tmp;
		next = skip_whitespace (next);

		if ((*next == '+') || (*next == '-')) {
			int sign = *next;

			if (!allow_offsets) {
				sprintf (AntErrorStr, "offset not permitted");
				return (-1);
			}

			next = skip_whitespace (next + 1);
			rc = find_offset (next, &tmp, &stmnt->args [args]);
			if (rc != 0) {
				sprintf (AntErrorStr, "illegal offset: (%s)",
						next);
				return (-1);
			}

			if (sign == '-') {
				stmnt->args [args].offset *= -1;
			}

			next = tmp;
			next = skip_whitespace (next);
		}

		stmnt->num_args = args + 1;

		if (*next != ARG_SEP_CHAR) {
			break;
		}

		next = skip_whitespace (next + 1);
		if (*next == '\0') {
			sprintf (AntErrorStr, "extra comma?");
			return (-1);
		}
	}

	if (*next != '\0') {
		sprintf (AntErrorStr, "extra text after args");
		return (-1);
	}

	return (0);
}

/*
 * find_label is responsible for determining whether the line begins
 * with a label definition, and if so, figuring out where it starts
 * and ends.  When things go right, this is very simple.  The main
 * challenge is printing out a decent error message when things go wrong
 * and the programmer has botched the code.
 *
 * There's all kinds of heuristics we could toss in here, to deal with
 * all kinds of errors, but for now we'll keep things simple and
 * assume that programmers understand the basics.
 */

static	int	find_label (char *str, char **end_ptr, char **label)
{
	int		len	= strlen (str);
	int		i;

	ANT_ASSERT (label != NULL);

	*label = NULL;

	str = skip_whitespace (str);

	for (i = 0; i < len && !isspace ((unsigned) str [i]); i++) {
		if (str [i] == LABEL_TERM_CHAR) {
			break;
		}
	}

	/*
	 * If there isn't a label, that's OK.  Just return 0,
	 * indicating that the str doesn't contain an *invalid* label.
	 */

	if (str [i] != LABEL_TERM_CHAR) {
		return (0);
	}

	if (i < 1) {
		sprintf (AntErrorStr, "invalid label");
		return (-1);
	}
	
	if (end_ptr != NULL) {
		*end_ptr = &str [i + 1];
	}

	if (check_label_name (str, i) == 0) {
		sprintf (AntErrorStr, "label contains invalid characters");
		return (-1);
	}

	*label = substring (str, 0, i);

	ANT_ASSERT (*label != NULL);

	return (0);
}

/*
 * Pluck out the opcode, if any, used in this str.
 */

static	int	find_op (char *str, char **end_ptr, int *op,
			ant_asm_str_id_t *mnemonics)
{
	int		len	= strlen (str);
	int		op_len;
	int		entry;

	for (op_len = 0;
			op_len < len && !isspace ((unsigned) str [op_len]);
			op_len++)
		;

	if (op_len < 1) {
		return (-1);
	}

	entry = match_str_id (str, op_len, mnemonics);
	if (entry >= 0) {
		*op = mnemonics [entry].id;
		*end_ptr = &str [op_len];
		return (0);
	}
	else {
		return (-1);
	}
}

/*
 * Pluck out the next operand, if any, used in this str.
 *
 * Returns zero if no properly formed operand, nonzero otherwise.
 */

static	int	find_arg (char *str, char **end_ptr, ant_asm_arg_t *arg)
{
	int		len	= strlen (str);
	int		a_len;
	int		entry;
	int		rc;
	int 		ind;

	/*
	 * Quoted characters are an annoying special case.  We need to
	 * handle them seperately from the rest of the cases, since
	 * they may contain spaces or the ARG_SEP_CHAR (or anything
	 * else...).
	 */

	if (str [0] == CHAR_QUOTE_CHAR) {
		rc = ant_asm_find_char (str, end_ptr, &arg->val);
		if (rc == 0) {
			arg->type = INT_ARG;
		}
		return (rc);
	}

	/*
	 * Strings are an even more annoying special case...
	 */

	if (str [0] == STRING_CHAR) {
		rc = ant_asm_find_string (str, end_ptr, &arg->string, &arg->strlen);
		if (rc == 0) {
			arg->type = STRING_ARG;
		}
		return (rc);
	}

	for (a_len = 0; a_len < len && !isspace ((unsigned) str [a_len]);
			a_len++) {
		if (str [a_len] == ARG_SEP_CHAR) {
			break;
		}

		/*
		 * If we've already read *something*, and we suddenly
		 * come across a + or -, then assume that it is the
		 * start of an offset, stop and pretend it's the end
		 * of the string.
		 */

		if (a_len > 0 && (str [a_len] == '+' || str [a_len] == '-')) {
			break;
		}
	}

	/*
	 * If we stopped because we encountered whitespace or the end
	 * of the string, then we're OK.  If we stopped because we hit
	 * the ARG_SEP_CHAR, however, then we need to back up one.
	 *
	 * Note the special case when a_len is 1; we don't want to
	 * back up past the beginning of the string!
	 */

	if ((a_len > 1) && (str [a_len - 1] == ARG_SEP_CHAR)) {
		a_len--;
	} 

	if (a_len < 1) {
		return (-1);
	}

	if (end_ptr != NULL) {
		*end_ptr = &str [a_len];
	}

	if ((ind = ant_find_reg (str, a_len)) >= 0) {
		arg->type = REG_ARG;
		arg->reg = ind;
	}
	else if (isdigit ((unsigned) str [0]) || (str [0] == '-')) {
		rc = ant_asm_get_integer (str, a_len, &arg->val);
		if (rc != 0) {
			return (-1);
		}

		arg->type = INT_ARG;
	}
	else if (str [0] == LABEL_PREFIX) {
		if (check_label_name (str + 1, a_len - 1) == 0) {
			sprintf (AntErrorStr, "invalid label name");
			return (-1);
		}
		arg->type = LABEL_ARG;
		arg->label = substring (str, 1, a_len - 1);
	}
	else if ((entry = match_str_id (str, a_len, io_names)) >= 0) {
		arg->type = SYS_CONST_ARG;
		arg->val = io_names [entry].id;
	}
	else if (check_label_name (str, a_len) != 0) {
		arg->type = SYMBOL_ARG;
		arg->label = substring (str, 0, a_len);
		return (0);
	}
	else {
		sprintf (AntErrorStr,
				"unrecognized operand type (%s)", str);
		return (-1);
	}

	return (0);
}

/*
 * Pluck out the offset for an operand, if any, used in this str.
 *
 * Returns zero if no properly formed offset, nonzero otherwise.
 */

static	int	find_offset (char *str, char **end_ptr, ant_asm_arg_t *arg)
{
	int		len	= strlen (str);
	int		a_len;
	int		rc;

	/*
	 * Quoted characters are an annoying special case.  We need to
	 * handle them seperately from the rest of the cases, since
	 * they may contain spaces or the ARG_SEP_CHAR (or anything
	 * else...).
	 */

	if (str [0] == CHAR_QUOTE_CHAR) {
		rc = ant_asm_find_char (str, end_ptr, &arg->offset);
		return (rc);
	}

	for (a_len = 0; a_len < len && !isspace ((unsigned) str [a_len]);
			a_len++) {
		if (str [a_len] == ARG_SEP_CHAR) {
			break;
		}
	}

	/*
	 * If we stopped because we encountered whitespace or the end
	 * of the string, then we're OK.  If we stopped because we hit
	 * the ARG_SEP_CHAR, however, then we need to back up one.
	 *
	 * Note the special case when a_len is 1; we don't want to
	 * back up past the beginning of the string!
	 */

	if ((a_len > 1) && (str [a_len - 1] == ARG_SEP_CHAR)) {
		a_len--;
	} 

	if (a_len < 1) {
		return (-1);
	}

	if (end_ptr != NULL) {
		*end_ptr = &str [a_len];
	}

	if (isdigit ((unsigned) str [0]) || (str [0] == '-')) {
		rc = ant_asm_get_integer (str, a_len, &arg->offset);
		if (rc != 0) {
			return (-1);
		}
	}
	else {
		sprintf (AntErrorStr,
				"unrecognized offset type (%s)", str);
		return (-1);
	}

	return (0);
}

/*
 * ant_asm_find_char --
 *
 * Plucks out character constants in almost the same form as C
 * character constants.  It handles all the character constants with
 * "special" names but does NOT handle the octal and hex method of
 * specifying character constants.  (These can be specified by
 * decimal, binary, or hex numbers elsewhere, using integer constants,
 * so no great loss.)
 *
 * A character constant begins with a CHAR_QUOTE_CHAR and ends with a
 * CHAR_QUOTE_CHAR.  In between, there is either a single character or
 * a backslash followed by another character.  If there is just a
 * single character, then the ASCII value of that character is used
 * for val.  If there is a backslash followed by a second character,
 * then a translation is performed.
 */

static	int	ant_asm_find_char (char *str, char **next, int *val)
{
	char		c;
	int		last;

	if (str [0] != CHAR_QUOTE_CHAR) {
		sprintf (AntErrorStr, "missing quote?");
		return (-1);
	}

	if ((str [1] == '\0') || (str [1] == CHAR_QUOTE_CHAR)) {
		sprintf (AntErrorStr, "empty quotes?");
		return (-1);
	}

	if (str [1] == '\\') {
		if (str [2] == '\0') {
			sprintf (AntErrorStr, "quoted char ended abruptly");
			return (-1);
		}
		switch (str [2]) {
			case '\\'	: c = '\\';	break;
			case '\?'	: c = '\?';	break;
			case '\''	: c = '\'';	break;
			case '\"'	: c = '\"';	break;
			case 'a'	: c = '\a';	break;
			case 'b'	: c = '\b';	break;
			case 'f'	: c = '\f';	break;
			case 'n'	: c = '\n';	break;
			case 'r'	: c = '\r';	break;
			case 't'	: c = '\t';	break;
			case 'v'	: c = '\v';	break;
			case '0'	: c = '\0';	break;
			default		:
				sprintf (AntErrorStr,
					"unknown escaped quoted char");
				return (-1);
		}
		last = 3;
	}
	else {
		c = str [1];
		last = 2;
	}

	if (str [last] != CHAR_QUOTE_CHAR) {
		sprintf (AntErrorStr, "missing quote?");
		return (-1);
	}
	else {
		*val = c;
		*next = &str [last + 1];
		return (0);
	}
}

/*
 * ant_asm_find_string --
 *
 * Snatch out a string.  Strings contain ordinary characters or escape
 * sequences.  Escape sequences begin with '\' and then are either
 * followed by a single letter (i.e.  \n, \t, \\, \", etc) or three
 * octal digits.  Note that '\0' is not valid; it must be spelled out
 * as '\000'.
 */

static int  ant_asm_find_string (char *str, char **next, char **res, unsigned int *reslen)
{
	char *p;
	unsigned int maxlen;
	char *maxbuf;
	char *res_p;
	char *end_ptr;

	if (str [0] != STRING_CHAR) {
		return (-1);
	}

	maxlen = strlen (str);
	maxbuf = malloc ((maxlen + 1) * sizeof (char));
	ANT_ASSERT (maxbuf != NULL);

	end_ptr = str + maxlen;

	res_p = maxbuf;

	for (p = str + 1; (*p != '\0') && (*p != STRING_CHAR); p++) {
		int c;

		if (*p == '\\') {
			c = *(p + 1);

			if (c == 0) {
				sprintf (AntErrorStr,
					"improperly terminated escape sequence in string");
				goto badString;
			}
			if (c >= '0' && c <= '7') {
				int i;

				if (p + 3 > end_ptr) {
					sprintf (AntErrorStr,
						"improperly terminated escape sequence in string");
					goto badString;
				}

				*res_p = 0;

				for (i = 1; i <= 3; i++) {
					if (p [i] < '0' || p [i] > '7') {
						sprintf (AntErrorStr,
							"improper character in string escape sequence");
						goto badString;
					}
					*res_p *= 8;
					*res_p += p [i] - '0';
				}

				p += 3;
			}
			else {
				switch (c) {
				case '\\' : *res_p = '\\'; break;
				case '\?' : *res_p = '\?'; break;
				case '\'' : *res_p = '\''; break;
				case '\"' : *res_p = '\"'; break;
				case 'a'  : *res_p = '\a'; break;
				case 'b'  : *res_p = '\b'; break;
				case 'f'  : *res_p = '\f'; break;
				case 'n'  : *res_p = '\n'; break;
				case 'r'  : *res_p = '\r'; break;
				case 't'  : *res_p = '\t'; break;
				case 'v'  : *res_p = '\v'; break;
				default   :
					sprintf (AntErrorStr,
							"illegal character in string escape sequence");
					goto badString;
				}
				p += 1;
			}
		}
		else {
			*res_p = *p;
		}

		res_p++;
	}

	*res_p = '\0';

	if (*p == STRING_CHAR) {
		*next = p + 1;
		*reslen = res_p - maxbuf;
		*res = maxbuf; /* could realloc here. */
		return (0);
	}

badString:
	free (maxbuf);
	return (-1);

}

/*
 * ant_asm_get_integer --
 *
 * Get an integer constant.
 *
 * An integer constant string begins with either a digit or a dash. 
 * If the string begins with a dash, then the number is considered
 * negative; otherwise it is positive.
 *
 * If the first two characters (following the dash, if present) are
 * BIN_PREFIX, HEX_PREFIX or OCT_PREFIX, then the string is
 * interpreted as a binary, hexadecimal, or octal number.  Otherwise,
 * the number is interpreted as decimal.
 */

static	int	ant_asm_get_integer (char *str, int len, int *val)
{
	int		sign	= 1;
	char		*start	= str;
	int		base	= 10;
	char		*end;
	unsigned int	uval;

	if (str [0] == '-') {
		sign = -1;
		start++;
	}

	if (strncmp (start, BIN_PREFIX, strlen (BIN_PREFIX)) == 0) {
		start += strlen (BIN_PREFIX);
		base = 2;
	}
	else if (strncmp (start, HEX_PREFIX, strlen (HEX_PREFIX)) == 0) {
		start += strlen (HEX_PREFIX);
		base = 16;
	}
	else if (strncmp (start, OCT_PREFIX, strlen (OCT_PREFIX)) == 0) {
		start += strlen (OCT_PREFIX);
		base = 8;
	}

	uval = strtoul (start, &end, base);
	if (sign == -1 && (uval - 1) > INT_MAX) {
		sprintf (AntErrorStr, "value too large to be signed");
		return (-1);
	}
	*val = (int) (sign * uval);

	if (end != (str + len)) {
		sprintf (AntErrorStr,
				"number contains non-numeric characters");
		return (-1);
	}

	return (0);
}

/*
 * match_str_id --
 *
 * Scan an array of ant_asm_str_id_t's, looking for a match for the given
 * str.  If found, returns the index into the array.  Otherwise,
 * returns -1.
 */

int	match_str_id (char *str, unsigned int len,
			ant_asm_str_id_t *array)
{
	int		i;

	if (array == NULL) {
		return (-1);
	}

	for (i = 0; array [i].str != NULL; i++) {
		if ((strlen (array [i].str) == len) &&
				(strncmp (array [i].str, str, len) == 0)) {
			return (i);
		}
	}

	return (-1);
}

/*
 * ant_asm_clean_str --
 *
 * Make a copy of the given string, minus any comments or
 * trailing whitespace.
 *
 */

char	*ant_asm_clean_str (char *str)
{
	char		*copy;

	ANT_ASSERT (str != NULL);

	copy = strdup (str);

	ANT_ASSERT (copy != NULL);

	remove_comments (copy);
	remove_trailing_blanks (copy);

	return (copy);
}

/*
 * A comment consists of all characters including or after the first
 * instance of COMMENT_CHAR in the string UNLESS the COMMENT_CHAR
 * appears on a quoted context.
 *
 * A comment is "removed" from the string by replacing the first
 * non-quoted instance of COMMENT_CHAR with a string terminator.
 */

static	void	remove_comments (char *str)
{
	int		len		= strlen (str);
	int		i;

	if (str [0] == COMMENT_CHAR) {
		str [0] = '\0';
		return ;
	}

	for (i = 1; i < len; i++) {
		if (str [i] == COMMENT_CHAR) {
			if ((str [i - 1] != CHAR_QUOTE_CHAR) ||
					(str [i + 1] != CHAR_QUOTE_CHAR)) {
				str [i] = '\0';
				return ;
			}
		}
	}
}

/*
 * end of ant_asm_parse.c
 */
