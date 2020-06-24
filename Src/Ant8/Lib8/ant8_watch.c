/*
 * $Id: ant8_watch.c,v 1.2 2001/04/12 15:37:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 03/24/01
 *
 * ant8_watch.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

#include	"ant_external.h"

	/*
	 * The max number of watchpoints is chosen arbitrarily; I
	 * doubt anyone will need more than a few, but in reality (in
	 * the most pitiful case) they could be interested in 256 of
	 * them.
	 */

#define	MAX_N_WP	32

typedef	struct	{
	int	n_wp;
	int	addrs [MAX_N_WP];
	int	vals  [MAX_N_WP];
} ant8_wp_t;

static ant8_wp_t	watchpoints;

int ant8_wp_init (void)
{

	watchpoints.n_wp = 0;

	return (0);
}

int ant8_wp_set (ant_t *ant, int addr)
{
	int n_wp, wp_addr, i;

	ANT_ASSERT ((addr >= 0) && (addr < ANT_DATA_ADDR_RANGE));

	n_wp = watchpoints.n_wp;

	if (watchpoints.n_wp >= MAX_N_WP) {
		return (-1);
	}

	/*
	 * Check whether we're already watching this address.
	 * If so, no further work is necessary.
	 */

	for (i = 0; i < watchpoints.n_wp; i++) {
		wp_addr = watchpoints.addrs [i];

		if (wp_addr == addr) {
			return (0);
		}
	}

	watchpoints.addrs [n_wp] = addr;
	watchpoints.vals [n_wp] = ant->data [addr];
	watchpoints.n_wp++;

	return (0);
}

int ant8_wp_clear (int addr)
{
	int n_wp, wp_addr, i;

	ANT_ASSERT ((addr >= 0) && (addr < ANT_DATA_ADDR_RANGE));

	n_wp = watchpoints.n_wp;

	for (i = 0; i < n_wp; i++) {
		wp_addr = watchpoints.addrs [i];

		if (wp_addr == addr) {
			watchpoints.addrs [i] = watchpoints.addrs [n_wp - 1];
			watchpoints.vals [i] = watchpoints.vals [n_wp - 1];
			watchpoints.n_wp--;
			return (0);
		}
	}

	return (-1);
}

int ant8_wp_clear_all (void)
{

	watchpoints.n_wp = 0;

	return (0);
}

/*
 * Note the assumption that only one address can be updated per cycle. 
 * ant8_wp_check will stop as soon as it finds anything different, and
 * there is only provision for reporting one change here.
 */

int ant8_wp_cycle (ant_t *ant, int *oval, int *nval)
{
	int wp_addr, i;

	for (i = 0; i < watchpoints.n_wp; i++) {
		wp_addr = watchpoints.addrs [i];
		if (ant->data [wp_addr] != watchpoints.vals [i]) {
			if (oval != NULL) {
				*oval = watchpoints.vals [i];
			}

			if (nval != NULL) {
				*nval = ant->data [wp_addr];
			}

			watchpoints.vals [i] = ant->data [wp_addr];
			return (wp_addr);
		}
	}

	return (-1);
}

/*
 * Update all the watchpoints.  Usually only done after a catacylsm of
 * some kind (such as reloading) where we want to potentially update
 * lots of watchpoints, but don't really care which or how many have
 * changed values.
 */

int ant8_wp_update (ant_t *ant)
{
	int wp_addr, i;

	for (i = 0; i < watchpoints.n_wp; i++) {
		wp_addr = watchpoints.addrs [i];
		watchpoints.vals [i] = ant->data [wp_addr];
	}

	return (0);
}

/*
 * end of ant8_watch.c
 */
