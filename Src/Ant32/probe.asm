

	leh	$end_probe_loop
	cle
	lc	g3, 0x40000000
	lc	g4, 0x80000000
	lc	g0, 0

probe_loop:
	add	g5, g0, g4
	ld4	g1, g5, 0
	gts	g2, g0, g3
	jnzi	g2, $end_probe_loop
	addi	g0, g0, 0x1000
	j	$probe_loop

end_probe_loop:
	cle
	mov	g4, g0

	halt

