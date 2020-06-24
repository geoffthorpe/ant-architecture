#ifndef	_AD32_UTIL_H_
#define	_AD32_UTIL_H_

/*
 * $Id: ad32_util.h,v 1.4 2002/01/02 02:27:32 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 06/09/2000
 *
 * ad32_util.h --
 */

	/*
	 * ad32_util.c:
	 */

int		ant_debug (ant_t *ant, char *filename);
void 		ant8_dbg_catch_intr (int code);

	/*
	 * ant8_ad_help.c:
	 */

int		ad_help (ant_dbg_op_t cmd);

/*
 * end of ad32_util.h
 */
#endif	/* _AD32_UTIL_H_ */
