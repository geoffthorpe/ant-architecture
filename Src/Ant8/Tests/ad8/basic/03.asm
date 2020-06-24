# $Id: 03.asm,v 1.1 2001/03/22 21:31:40 ellard Exp $
#@ Tests the 'i' command.

start:
	lc	r2, 1
	add	r3, r4, r5
	sub	r4, r5, r6
	mul	r5, r6, r7
	and	r6, r7, r8
	nor	r7, r8, r9
	shf	r8, r9, r10
	ld1	r9, r10, 11
	st1	r10, r11, 12
	inc	r11, 13

	# Up to this point, we can actually execute the program.
	# The rest of this is just for show.
stop:
	jmp	14
	out	r15, ASCII
	in	r14, ASCII
	bgt	r0, r1, r2
	beq	r1, r2, r3

hlt:
	hlt	

_data_:
	.byte	0x0, 0x1, 0x2, 0x3
	.byte	0x4, 0x5, 0x6, 0x7
end_data:

#>> b $stop
#>> i 0
#>> i 2
#>> i 0, 2
#>> i $stop
#>> i $hlt
#>> i $stop, $hlt
#>> i
#>> g
#>> i $stop
#>> i $hlt
#>> i $stop, $hlt
#>> i
#>> q

