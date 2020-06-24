#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests lc for r0
# OK

	lc	r2, $start
	rfe	r2, r0, r0
start:
	lc r0, 1

	stop

