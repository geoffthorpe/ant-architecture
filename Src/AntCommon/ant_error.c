/*
 * $Id: ant_error.c,v 1.5 2002/01/02 02:30:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 02/11/2000 
 *
 * ant_error.c --
 *
 */

#include   <stdio.h>

#include        "ant_external.h"
#include        "ant_internal.h"

char	AntErrorStr [MAX_ERROR_LEN];

void	ant_err_clr (void)
{
	AntErrorStr [0] = '\0';
}

char *ant_err_get (void)
{
	return (AntErrorStr);
}

/*
 * end of ant_error.c
 */
