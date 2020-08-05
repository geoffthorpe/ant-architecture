/*
 * $Id: ant_file.c,v 1.4 2002/01/02 02:30:23 ellard Exp $
 *
 * Copyright 2000-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 02/09/2000
 *
 * ant_file.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<unistd.h>	/* for unlink */
#include	<string.h>

#include        "ant_external.h"
#include        "ant_internal.h"

#define	MAX_LINES	2048	/* A HUGE ANT file! */

#define	MAX_LINE_LENGTH	1024

char **file2lines (char *filename, int *line_cnt)
{
	FILE *fin	= NULL;
	char **lines	= NULL;
	int max_lines	= MAX_LINES;
	int cur_lines	= 0;
	char buf [MAX_LINE_LENGTH];
	
	fin = fopen (filename, "r");
	if (fin == NULL) {
		return (NULL);
	}

	lines = (char **) malloc (sizeof (char *) * max_lines);
	if (lines == NULL) {
		fclose (fin);
		return (NULL);
	}

	while (fgets (buf, MAX_LINE_LENGTH, fin) != NULL) {

		/*
		 * We need an "extra" line in the array to hold the
		 * NULL that marks the end.
		 */

		if (cur_lines == max_lines - 1) {
			max_lines *= 2;
			lines = realloc (lines, sizeof (char *) * max_lines);
			if (lines == NULL) {
				fclose (fin);
				return (NULL);
			}
		}
		lines [cur_lines++] = strdup (buf);
	}
	
	lines [cur_lines] = NULL;

	fclose (fin);

	if (line_cnt != NULL) {
		*line_cnt = cur_lines;
	}

	return (lines);
}

/*
 * Takes a buffer, copies it, and chops it into a bunch of lines.
 * The original buffer is unchanged.
 */

char **buf2lines (const char *orig_buf, int *line_cnt)
{
	char *buf = strdup (orig_buf);
	int count;
	int i;
	char **lines;
	char *curr, *next;
	char *buf_end;

	if (buf == NULL) {
		return (NULL);
	}

	count = 0;
	for (i = 0; buf [i] != '\0'; i++) {
		if (buf [i] == '\n') {
			count++;
		}
	}

		/*
		 * If the last line doesn't end in a newline, then we
		 * have undercounted.
		 */

	if ((i > 0) && (buf [i - 1] != '\n')) {
		count++;
	}

	lines = malloc (sizeof (char *) * (count + 1));
	if (lines == NULL) {
		free (buf);
		return (NULL);
	}

	buf_end = buf + strlen (buf);

	curr = buf;
	i = 0;
	while (curr < buf_end) {

		/* &&& THIS IS UGLY AND PROBABLY BUGGY */
		if (strlen (curr) == 0) {
			break;
		}

		next = strchr (curr, '\n');

		if (next != NULL) {
			*next = '\0';
		}

		lines [i] = strdup (curr);
		if (lines [i] == NULL) {
			free (buf);
			/* &&& THERE IS MORE TO CLEAN UP! */
			return (NULL);
		}

		i++;
		if (next == NULL) {
			break;
		}
		else {
			curr = next + 1;
		}
	}

	if (i > count) {
		printf ("memory problem %s %d ??? \n", __FILE__, __LINE__);
	}
	
	lines [i] = NULL;
	lines [count] = NULL;

	if (line_cnt != NULL) {
		*line_cnt = count;
	}

	return (lines);
}

#ifdef	TESTIT
int main ()
{
	char **lines;
	int count;
	int i;
	char *BUF = "This is a test\nto see if this works\n\n"
			"Or whether I have tons more work to do";

	lines = buf2lines (BUF, &count);

	printf ("count = %d\n", count);

	for (i = 0; i < count; i++) {
		printf ("(%s)\n", lines [i]);
	}

	if (lines [count] != NULL) {
		printf ("OOPS!\n");
	}
}
#endif	/* TESTIT */

/*
 * end of ant_file.c
 */
