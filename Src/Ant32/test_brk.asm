# test_brk.asm
#

	.text
main:
	push	$foo
	call	$antSysSbrkInit
	pop	ze

	push	8
	call	$antSysSbrk
	pop	ze
t0:
	push	8
	call	$antSysSbrk
	pop	ze
t1:
	push	8
	call	$antSysSbrk
	pop	ze
t2:
	push	-8
	call	$antSysSbrk
	pop	ze
t3:
	halt

	.data
foo:
