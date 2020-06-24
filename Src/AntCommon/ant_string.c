/*
 * $Id: ant_string.c,v 1.5 2002/08/19 15:31:37 mtucker Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 11/02/96 -- cs50
 *
 * ant_string.c --
 *
 * Miscellaneous string routines that get used in a bunch of different
 * places.
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<ctype.h>

#include        "ant_external.h"
#include        "ant_internal.h"

/*
 * Returns the pointer of the first non-blank character in the given
 * string, or a pointer to the terminating '\0' if there is no such
 * character.  str is not modified at all.
 *
 * If str is NULL, NULL is returned.  This case doesn't make much
 * sense and isn't supposed to happen...
 */

char *skip_whitespace (char *str)
{

	if (str == NULL) {
		return (NULL);
	}

	while (isspace ((unsigned) *str)) {
		str++;
	}

	return (str);
}

/*
 * Returns a COPY of the substring of str starting at start and
 * extending for len bytes.
 *
 * If str isn't long enough, then as much as possible of the str is
 * copied.
 */

char *substring (char *str, unsigned int start, unsigned int len)
{
	char *new_str = NULL;

	if (len > strlen (str + start)) {
		len = strlen (str + start);
	}

	new_str = malloc (len + 1);

	ANT_ASSERT (new_str != NULL);

	strncpy (new_str, str + start, len);
	new_str [len] = '\0';

	return (new_str);
}

/*
 * DESTRUCTIVELY removes any trailing blanks on the string (whitespace
 * after the end of the last real token) by overwriting them with
 * '\0'.
 */

void remove_trailing_blanks (char *str)
{
	int i, end;

	if (str == NULL) {
		return ;
	}

	end = strlen (str) - 1;

	for (i = end; i >= 0 && isspace ((unsigned) str [i]); i--) {
		str [i] = '\0';
	}

	return ;
}

/*
 * check_label_name --
 *
 * Returns 0 if the specified label is NOT a valid label, or non-zero
 * if it is valid.
 *
 * Labels must obey the same rules as C identifiers:  the first char
 * can be an underscore or a letter, and the rest of the chars may be
 * letters, numbers, or underscores.
 */

int check_label_name (char *label, int len)
{
	int i;
	unsigned char c;

	if (len < 1) {
		return (0);
	}

	c = label [0];
	if (!isalpha (c) && (c != '_')) {
		return (0);
	}

	for (i = 1; i < len; i++) {
		c = label [i];
		if (!isalnum (c) && (c != '_')) {
			return (0);
		}
	}

	return (1);
}

#ifdef	__MWERKS__

/*
 * The metrowerks library apparently does not include strdup, so here
 * is a simple implementation.
 */

char *strdup (char *str)
{
	char *new_str;
	
	if (str == NULL) {
		return (NULL);
	}

	new_str = malloc (strlen (str) + 1);

	if (new_str == NULL) {
		return (NULL);
	}
	else {
		return (strcpy (new_str, str));
	}
}
#endif	/* __MWERKS__ */

/*
 * end of ant_string.c
 */
