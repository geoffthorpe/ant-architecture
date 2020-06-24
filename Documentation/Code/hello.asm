# Barney Titmouse -- 11/2/96
# hello.asm-- A "Hello World" program.
# Registers used:
#	r2	- holds the address of the string

	lc	r2, $str_data	# load the address of the string into r3
	sys	r2, 4		# Print the characters in memory

	sys	r0, 0		# Halt

# Data for the program:
_data_:

str_data: 
	.byte	'H', 'e', 'l', 'l', 'o', ' '
	.byte	'W', 'o', 'r', 'l', 'd', '\n', 0

# end hello.asm
