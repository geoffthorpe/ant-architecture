#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests tlble, expects success.
# OK

# first load a TLB entry

	lc 	r3, 4	#TLB index
	lch 	r4, 20	#the TLB entry itself
	lch 	r5, 30
	tlbse	r3, r4

# and then get it back

	tlble r6, r3

	stop
