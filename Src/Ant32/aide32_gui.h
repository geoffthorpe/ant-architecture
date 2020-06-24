#ifndef	_ANT_GUI_H_
#define	_ANT_GUI_H_

/*
 * $Id: aide32_gui.h,v 1.2 2002/01/02 02:27:32 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 01/08/2000
 *
 * ant_gui.h --
 */

char *antgGetRegByIndex (ant_t *ant, int ind);
char *antgGetBreakPoints (ant_dbg_bp_t *bp);
char *antgGetLabels (void);
char *antgGetInstCount (ant_t *ant);

void ant_val2str_buf (ant_data_t val, char *buf);
void ant_val2ascii_buf (ant_data_t val, char *cbuf);
char *ant_val2str_alloc (ant_data_t val);
char *ant_val2ascii_alloc (ant_data_t val);

/*
 * end of ant_gui.h
 */

#endif	/* _ANT_GUI_H_ */
