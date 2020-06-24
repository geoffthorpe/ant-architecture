/*
 * $Id: ant32_rand.c,v 1.3 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 01/10/2001
 *
 * ant32_rand.c --
 *
 * A very simple implementation of the random operations.
 *
 * The main purpose of this code is to define an interface that allows
 * this implementation to be replaced with a better implementation in
 * the future.
 */

#include	<stdio.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant32_external.h"

void ant32_srand (ant_reg_t a, ant_reg_t b, ant_reg_t c)
{

	srand ((unsigned int) a);

	return ;
}

/*
 * Because a lot of rand implementations only produce 15 bits of
 * randomness, we call it three times to fill up an entire 32-bit word.
 */

int ant32_rand (void)
{

	return (rand () ^ (rand () << 11) ^ (rand () << 22));
}

int ant32_rand_nbits (void)
{

	return (32);
}

/*
 * ant32_rand.c
 */
