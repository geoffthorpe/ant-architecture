/*
 * $Id: ant32_except.c,v 1.9 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 12/20/00
 *
 * ant32_except.c -- emulation of the exception handler.
 */

#include	<stdlib.h>
#include	<stdio.h>

 	/* Yeccch */
#include	"ant_external.h"
#include	"ant32_external.h"

void ant32_exc_update (ant_t *ant)
{

	/*
	 * If we're in the midst of handling an exception, then
	 * nothing is updated!
	 */

	if (ant->exc_disable != 0) {
		return ;
	}

	ant->reg [EXC_REG_0] = ant->pc;
	ant->reg [EXC_REG_1] = ant->int_disable;

		/*
		 * e2 and e3 are set to default values here,
		 * and then updated by TLB operations and other
		 * things that might encounter faults.
		 */

	ant->reg [EXC_REG_2] = 0;	/* Set by the TLB */
	ant->reg [EXC_REG_3] = (ant->mode == ANT_SUPER_MODE) ? 1 : 0;

	return ;
}

int ant32_exc_throw (ant_t *ant)
{
	char *str;

	ant->pc = ant->eh;
	ant->int_disable = 1;	/* &&& double-check */
	
	/* We need to be in super mode to deal with exceptions */
	ant->mode = ANT_SUPER_MODE;	
								
	if (ant->exc_disable == 0) {
		ant->exc_disable = 1;
		return (ANT_EXC_OK);
	}
	else {
		printf ("CPU ERROR: "
			"An exception occured while exceptions were disabled.\n");
		str = ant32_dump_eregs (ant, 1);
		printf ("%s\n", str);
		free (str);
		return (ANT_EXC_EXC);
	}
}

int ant32_exc_catch (ant_t *ant, ant_mem_op_t mem_action, ant_exc_t exception)
{
	int val = 0;

	val = (ant->mode == ANT_SUPER_MODE) ? 1 : 0;
	val |= ((mem_action & 0x7) << 1);
	val |= (exception << 4);

	ant->reg [EXC_REG_3] = val;

	return (0);
}

int ant32_mem_op2exc (ant_mem_op_t op)
{

	switch (op) {
		case ANT_MEM_READ :
			return (1 << 3);
			break;
		case ANT_MEM_WRITE :
			return (1 << 2);
			break;
		case ANT_MEM_EXEC :
			return (1 << 1);
			break;
		default :
			ANT_ASSERT (0);
			return (0);
			break;
	}
}

/*
 * end of ant32_except.c
 */
