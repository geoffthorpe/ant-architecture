/*
 * $Id: ant8_fault.c,v 1.3 2001/01/02 15:30:03 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_fault.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

static	ant_status_t	CurrentAntStatus	= STATUS_OK;

static char *ant_status_desc (ant_status_t status);

void	ant_status (ant_status_t code)
{
	CurrentAntStatus	= code;
}

void	ant_fault (ant_status_t code, int pc, ant_t *ant, int dump)
{
	char *description;

	ant_status (code);

	if (dump) {
		ant_dump_text ("ant.core", ant);
	}

		/*
		 * If the status is running, then there's nothing
		 * more to do here.  The rest of this function is
		 * for dealing with faults.
		 */

	if ((code & STATUS_RUN) == STATUS_RUN) {
		return ;
	}

	description = ant_status_desc (code);

	printf ("FAULT: (pc = 0x%.2x): %s.\n", pc, description);

	return ;
}

static char *ant_status_desc (ant_status_t status)
{
	char *str = "???";

	switch (status) {
		case STATUS_OK	:
			str = "OK";
			break;
		case STATUS_HALT:
			str = "HALTED";
			break;
		case STATUS_INPUT:
			str = "Waiting for input";
			break;

		case FAULT_ADDR	:
			str = "Illegal address";
			break;
		case FAULT_ILL	:
			str = "Illegal instruction";
			break;
		default		:
			str = "Unknown status";
			break;

	}

	return (str);
}

ant_status_t ant_get_status (void)
{

	return (CurrentAntStatus);
}

char *ant_get_status_str (void)
{

	return (ant_status_desc (CurrentAntStatus));
}


/*
 * end of ant_fault.c
 */
