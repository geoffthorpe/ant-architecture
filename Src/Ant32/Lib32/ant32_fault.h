#ifndef	_ANT32_FAULT_H_
#define	_ANT32_FAULT_H_

/*
 * $Id: ant32_fault.h,v 1.5 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 07/18/99
 *
 * ant32_fault.h --
 *
 */
 
/* SSS
#include "ant_fault.h"
*/
#include "ant_external.h"

extern	void		ant_fault (ant_status_t code,
				int pc, ant_t *ant, int dump);
extern	void		ant_status (ant_status_t code);
extern	ant_status_t	ant_get_status (void);
extern	char		*ant_get_status_str (void);

/*
 * end of ant32_fault.h
 */
#endif	/* _ANT32_FAULT_H_ */
