
main:
	lc g0, $byte
	lc g1, 0x10
	st1 g1, g0, 0
	addi g1, g1, 1
	st1 g1, g0, 1
	addi g1, g1, 1
	st1 g1, g0, 2
	addi g1, g1, 1
	st1 g1, g0, 3

	halt

	.data
word:
	.word	0, 0, 0, 0

byte:
	.byte	0, 1, 2, 3
