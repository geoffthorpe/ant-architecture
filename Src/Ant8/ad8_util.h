#ifndef	_ANT8_AD_UTIL_H_
#define	_ANT8_AD_UTIL_H_

/*
 * $Id: ad8_util.h,v 1.4 2001/03/25 16:11:28 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 06/09/2000
 *
 * ant8_ad_util.h --
 */

	/*
	 * ant8_ad_util.c:
	 */

int		ant_debug (ant_t *ant, char *filename);
void 		ant8_dbg_catch_intr (int code);

char		*print_labels (ant_asm_stmnt_t *stmnt);

	/*
	 * ant8_ad_help.c:
	 */

int		ad_help (ant_dbg_op_t cmd);
int		ad_parse_help (char *str, ant_dbg_op_t *cmd,
			ant_asm_str_id_t *commands);

/*
 * end of ant8_ad_util.h
 */
#endif	/* _ANT8_AD_UTIL_H_ */
