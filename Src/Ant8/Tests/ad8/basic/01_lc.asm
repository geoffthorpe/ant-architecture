#@ tests lc
	lc      r2, 15 
	lc      r3, 1
	hlt 
#>> p           # make sure all registers are 0 initially
#>> n           # single-step
#>> p           # now r2 should be 15; everything else 0
#>> n           # single-step
#>> p           # now r2 = 15, r3 = 1, everything else 0  
#>> q

