/*
 * $Id: aide8_gui.c,v 1.5 2001/01/02 15:30:00 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 01/08/2000
 *
 * aide8_gui.c --
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>

#include	"ant8_external.h"
#include	"aide8_gui.h"

#define	MAX_BUF_LEN	1024
#define	LABEL_BUF_LEN	(16 * MAX_BUF_LEN)

char *antgGetRegByIndex (ant_t *ant, int ind)
{
	char buf [MAX_BUF_LEN];
	char rbuf [MAX_BUF_LEN];

	ANT_ASSERT (ant != NULL);

	ant_val2str_buf (ant->reg [ind], buf);

	sprintf (rbuf, "r%-2d = %s", ind, buf);

	return (strdup (rbuf));
}

char *antgGetBreakPoints (ant_dbg_bp_t *bp)
{
	char buf [ANT_INST_ADDR_RANGE * 10];
	int i;

	ANT_ASSERT (bp != NULL);

	buf [0] = '\0';

	for (i = 0; i < MAX_INST; i++) {
		if (bp->breakpoints [i] != 0) {
			sprintf (buf + strlen (buf), "%d ", i);
		}
	}

	return (strdup (buf));
}

char *antgGetLabels (void)
{
	char buf [LABEL_BUF_LEN];

	buf [0] = '\0';

	sprintf (buf, "\t%-4.4s  %-4.4s  %-4.4s  %-10.10s  %s  %s\n\n",
			"Dec", "Hex", "Oct", "Binary", "ASCII", "Label");

	dump8_symtab_human (labelTable, buf + strlen (buf));

	return (strdup (buf));
}

char *antgGetInstCount (ant_t *ant)
{
	char buf [20];

	sprintf (buf, "%d", ant->inst_cnt);

	return (strdup (buf));
}

void ant_val2str_buf (ant_data_t val, char *buf)
{
	char cbuf [MAX_BUF_LEN];
	char bbuf [100];
	int i;

	for (i = 0; i < 8; i++) {
		bbuf [i] = (val & (1 << (7 - i)) ? '1' : '0');
	}
	bbuf [8] = '\0';

	ant_val2ascii_buf (val, cbuf);

	sprintf (buf, "0x%2.2x  %s  %3.3s", LOWER_BYTE (val), bbuf, cbuf);

	return;
}

void ant_val2ascii_buf (ant_data_t val, char *buf)
{
	char *str;

	/*
	 * isprint isn't really right on some systems, and will cause
	 * the system to crash if the character is very unprintable! 
	 * So, we wrap this test up inside some other tests.
	 */

        if (((unsigned char)val > 0) && ((unsigned char)val <= 127) && 
           isprint (val)) {

		if (val == ' ') {
			strcpy (buf, "' '");
		}
		else {
			buf [0] = val;
			buf [1] = '\0';
		}
	}
	else {
		switch (val) {
			case '\a'	: str = "\\a";	break;
			case '\b'	: str = "\\b";	break;
			case '\f'	: str = "\\f";	break;
			case '\n'	: str = "\\n";	break;
			case '\r'	: str = "\\r";	break;
			case '\t'	: str = "\\t";	break;
			case '\v'	: str = "\\v";	break;
			case '\0'	: str = "\\0";	break;
			default	  	: str = "-+-";	break;
		}

		strcpy (buf, str);
	}

	return ;
}

char *ant_val2str_alloc (ant_data_t val)
{
	char buf [MAX_BUF_LEN];

	ant_val2str_buf (val, buf);
	return (strdup (buf));
}

char *ant_val2ascii_alloc (ant_data_t val)
{
	char buf [MAX_BUF_LEN];

	ant_val2ascii_buf (val, buf);
	return (strdup (buf));
}

/*
 * end of aide8_gui.c
 */
