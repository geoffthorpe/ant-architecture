# add32.asm
# Jennifer Schmidt

	jmp $main
	jmp $dump

main:
	#load the data addresses
	lc 	r2, $first_number
  	lc 	r3, $second_number
  	lc 	r4, $result
	lc	r5, 15

  	#load the least sig byte
	ld1	r6, r2, 3
	ld1	r7, r3, 3

	#load const to mask first 4 bits
	and	r8, r6, r5
	and	r9, r7, r5

	#add the two masked 4-bit numbers
	add 	r10, r8, r9
	
	#put the first 4-bit result in
	and	r11, r10, r5

	#bit shift to make carry bit lsb
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

	#bit shift to get most sig bytes
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5

	#add the two masked 4-bit numbers and the carry
	add r10, r10, r6
	add r10, r10, r7

	#take the 4 lsb's
	and	r8, r10, r5

	#bit shift to convert to msb's
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0

	#add result to result reg 12
	add r12, r11, r8

	#get the carry bit
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

#---------------------------------------------------

  	#load the next least sig byte
	ld1	r6, r2, 2
	ld1	r7, r3, 2

	#load const to mask first 4 bits
	and	r8, r6, r5
	and	r9, r7, r5

	#add the two masked 4-bit numbers
	add 	r10, r8, r9
	
	#put the first 4-bit result in
	and	r11, r10, r5

	#bit shift to make carry bit lsb
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

	#bit shift to get most sig bytes
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5

	#add the two masked 4-bit numbers and the carry
	add r10, r10, r6
	add r10, r10, r7

	#take the 4 lsb's
	and	r8, r10, r5

	#bit shift to convert to msb's
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0

	#update result register
	add r11, r11, r8

	#shift left 8 bits to give proper value
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0

	#add to overall result register
	add r12, r12, r11

	#get the carry bit
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

#---------------------------------------------------

  	#load the next least sig byte
	ld1	r6, r2, 1
	ld1	r7, r3, 1

	#load const to mask first 4 bits
	and	r8, r6, r5
	and	r9, r7, r5

	#add the two masked 4-bit numbers
	add 	r10, r8, r9
	
	#put the first 4-bit result in
	and	r11, r10, r5

	#bit shift to make carry bit lsb
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

	#bit shift to get most sig bytes
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5

	#add the two masked 4-bit numbers and the carry
	add r10, r10, r6
	add r10, r10, r7

	#take the 4 lsb's
	and	r8, r10, r5

	#bit shift to convert to msb's
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0

	#update result register
	add r11, r11, r8

	#shift left 16 bits to give proper value
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0

	#add to overall result register
	add r12, r12, r11

	#get the carry bit
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

#---------------------------------------------------

  	#load the most sig byte
	ld1	r6, r2, 0
	ld1	r7, r3, 0

	#load const to mask first 4 bits
	and	r8, r6, r5
	and	r9, r7, r5

	#add the two masked 4-bit numbers
	add 	r10, r8, r9
	
	#put the first 4-bit result in
	and	r11, r10, r5

	#bit shift to make carry bit lsb
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5

	#bit shift to get most sig bytes
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r6, r6, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5
	shf	r7, r7, r5

	#add the two masked 4-bit numbers and the carry
	add r10, r10, r6
	add r10, r10, r7

	#take the 4 lsb's
	and	r8, r10, r5

	#bit shift to convert to msb's
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0
	shf	r8, r8, r0

	#update result register
	add r11, r11, r8

	#shift left 24 bits to give proper value
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0
	shf 	r11, r11, r0

	#add to overall result register
	add r12, r12, r11

	#get the carry bit
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5
	shf 	r10, r10, r5


#-------------------------------------------------

	#write the byte result to memory
	st1	r4, r12, 3

	hlt
	#sys r0, SysHalt


dump:
	ld1 r13, r4, 0
	ld1 r13, r4, 1
	ld1 r13, r4, 2
	ld1 r13, r4, 3
	hlt
#	sys r0, SysHalt

_data_:

first_number:
  .byte  1, 2, 3, 4
second_number:
  .byte  1, 2, 3, 4
result:
