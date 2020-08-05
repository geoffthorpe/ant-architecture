/*
 * $Id: ant32_fault.c,v 1.15 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant32_fault.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>

#include	"ant32_external.h"

static	ant_exc_t	CurrentAntStatus	= STATUS_OK;


void	ant_status (ant_exc_t code)
{
	CurrentAntStatus	= code;
}

static unsigned long absorb_unused;

void	ant_fault (ant_exc_t code, int pc, ant_t *ant, int dump)
{
	char *description;

	absorb_unused += (unsigned long)ant;
	absorb_unused += dump;

	ant_status (code);

		/*
		 * If the status is running, then there's nothing more
		 * to do here.  The rest of this function is for
		 * dealing with faults that make the processor veer
		 * off in a new direction.
		 */

	if ((code & STATUS_RUN) == STATUS_RUN) {
		return ;
	}

	description = ant_status_desc (code);

	/*
	 * For diagnostic purposes only!
	 */

	printf ("FAULT: (pc = 0x%.8x): %s.\n", pc, description);

	/* &&& Fill in all the exception registers.
	 */

	return ;
}

char *ant_status_desc (ant_exc_t status)
{
	char *str = "???";

	switch (status) {
		case ANT_EXC_OK		: str = "OK"; break;
		case ANT_EXC_IRQ	: str = "IRQ"; break;
		case ANT_EXC_BUS_ERR	: str = "Bus Error"; break;
		case ANT_EXC_ILL_INS	: str = "Illegal Inst"; break;
		case ANT_EXC_PRIV_INS	: str = "Privileged Inst"; break;
		case ANT_EXC_TRAP	: str = "Trap"; break;
		case ANT_EXC_DIV0	: str = "Division by Zero"; break;
		case ANT_EXC_ALIGN	: str = "Alignment Err"; break;
		case ANT_EXC_PRIV_SEG	: str = "Privileged Seg"; break;
		case ANT_EXC_REG_VIOL	: str = "Register Violation"; break;
		case ANT_EXC_TLB_MISS	: str = "TLB Miss"; break;
		case ANT_EXC_TLB_PROT	: str = "TLB Protected"; break;
		case ANT_EXC_TLB_MULTI	: str = "TLB Multiple Match"; break;
		case ANT_EXC_TLB_INV	: str = "TLB Invalid Index"; break;
		case ANT_EXC_HALT	: str = "CPU Halted"; break;
		case ANT_EXC_IDLE	: str = "CPU Idled"; break;
		case ANT_EXC_EXC	: str = "Nested Exception"; break;
		default			: str = "Unknown status"; break;

	}

	return (str);
}

ant_exc_t ant_get_status (void)
{

	return (CurrentAntStatus);
}

char *ant_get_status_str (void)
{

	return (ant_status_desc (CurrentAntStatus));
}


/*
 * end of ant32_fault.c
 */
