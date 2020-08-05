/*
 * $Id: ant_console.c,v 1.3 2002/06/28 20:56:46 ellard Exp $
 *
 * Copyright 2002 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_console.c --
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant_internal.h"

static	char		*conInBuff	= NULL;
static	unsigned int	conInBuffLen	= 0;
static	unsigned int	con_start	= 0;
static	unsigned int	con_end		= 0;

void ant_console_reset (void)
{

	if (conInBuff != NULL) {
		free (conInBuff);
	}

	conInBuff = NULL;
	conInBuffLen = 0;
	con_start = 0;
	con_end = 0;

	return ;
}

int ant_console_enqueue (const char *str, unsigned int len)
{

	if (con_end + len > conInBuffLen) {
		unsigned int new_len;
		char *new_ptr;

		/* Set the increment to something small for
		 * debugging-- it really should be something like 4K,
		 * to avoid incessant reallocation.
		 */

		new_len = (con_end - con_start) + len + (4 * 1024);
		new_ptr = malloc (new_len);

		ANT_ASSERT (new_ptr != NULL);

		memcpy (new_ptr, conInBuff + con_start, con_end - con_start);
		free (conInBuff);

		conInBuff = new_ptr;
		conInBuffLen = new_len;
		con_end -= con_start;
		con_start = 0;
	}

	memcpy (conInBuff + con_end, str, len);
	con_end += len;

	return (0);
}

int ant_console_dequeue (void)
{
	int val;

	if (con_start == con_end) {
		val = -1;
	}
	else {
		val = 0xff & conInBuff [con_start++];
	}

	return (val);
}

int ant_console_peek (void)
{

	int val;

	if (con_start == con_end) {
		val = -1;
	}
	else {
		val = 0xff & conInBuff [con_start];
	}

	return (val);
}

int ant_console_qlen (void)
{

	return (con_end - con_start);
}

/*
 * end of ant_console.c
 */
