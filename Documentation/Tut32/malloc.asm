# $Id$

antSysMalloc:
	entry	0
	ld4	g1, fp, 8
	lc	g2, $antSysBrk
	ld4	g3, g2, 0

	mov	g0, g2
	modi	g4, g1, 4
	jezi	g4, $antSysMalloc_aligned

	shrui	g1, g1, 2
	shli	g1, g2, 2
	addi	g1, g1, 4

antSysMalloc_aligned:
	add	g3, g3, g1
	st4	g3, g2, 0

	return	g0

