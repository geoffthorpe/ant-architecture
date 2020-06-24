
	lc	t0, 0
	lc	sp, 10

	lc	s0, 10

	lc	t0, 0
	lc	g1, 1
	lc	g2, -1

	geu	g4, g0, g1
	geu	g5, g0, g2

	geu	g6, g1, g0
	geu	g7, g1, g2

	geu	g8, g2, g0
	geu	g9, g2, g1

	lc	s0, 10

	halt

	.data

	# .byte	'\0', '\1', '\2', '\3'

	.ascii	"A\022\023\024\025\026\020"
	.ascii	"\001\011\111 to see what happens"

