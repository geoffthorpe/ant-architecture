#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests tlbse, expects success.
# OK

	lc 	r3, 4	#TLB index
	lch 	r4, 20	#the TLB entry itself
	lch 	r5, 30
	tlbse	r3, r4

	stop
