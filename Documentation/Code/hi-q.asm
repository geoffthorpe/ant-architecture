# stsamuel - 10/17/97
# hi-q in ant

# overall algorithm:
# init_board
# while  (1) {
#	draw_board
#	possible_moves
#	get_input
#	if (is_legal_move)
#		make_move
# }

# constants - stylistically, shd load them from memory
# and they are actually in .byte in case we had more instructions 
# available
#	lc r10, $bound2
#	ld1 r10, r10, 0
#	lc r11, $bound1
#	ld1 r11, r11, 0
#	lc r12, $max_len
#	ld1 r12, r12, 0
#	lc r13, $space
#	ld1 r13, r13, 0
#	lc r14, $peg
#	ld1 r14, r14, 0
#	lc r15, $hole
#	ld1 r15, r15, 0
# but had to do direct lc's because we had instruction overflow
	lc r10, 4	# bound2 - 1, needed bec we only have bgt
	lc r11, 1	# bound1
	lc r12, 7	# board max_len
	lc r13, ' '	# space
	lc r14, '*' # peg
	lc r15, 'o' # hole

# init board in memory, 7x7 array

# basic algorithm: 
# 	for (i=0;i<max_len;i++)
#		for (j=0;j<max_len;j++)
#			if (i>bound1 && (i<bound2))
#				load_peg
#			else if (j>bound1 && (j<bound2))
#				load_peg
#			else load_space
#	load_hole

	lc r2, 0		# init row ctr (i)
	lc r3, 0		# init col ctr (j)
	lc r4, $load_peg 	# load peg into current cell
	lc r5, $load_space	# load space into current cell
	lc r6, $load_hole	# finish of init_board, load hole into ctr
	lc r8, $bound2_col_test	# check if col >= bound2
	lc r9, $inc_row		# increment row number (& reset j to 0)
init_loop:
	beq r6, r12, r2	# if row == len, end, load hole
	lc r7, $bound2_row_test
	bgt r7, r2, r11	# if row > boundary, test for row < bound2
init_col_test:
	bgt r8, r3, r11 # if col > bound, test for < bound2
load_space:
	# r7 = scratch reg for calculating memory index
	mul r7, r2, r12 # array index == i*len + j
	add r7, r7, r3
	st1 r13, r7, 0	# put space into mem addr of r7
	jmp $inc_col    # increment j
bound2_col_test:
	bgt r5, r3, r10 # if col > bound2 - 1, then we want a space
	jmp $load_peg   # otherwise, load a peg
bound2_row_test:
	lc r7, $init_col_test
	bgt r7, r2, r10 # if row > bound2 - 1, then test the col
	jmp $load_peg
load_peg:
	# r7 = scratch reg for calculating memory index
	mul r7, r2, r12 # array index == i*len + j
	add r7, r7, r3
	st1 r14, r7, 0	# put peg
	jmp $inc_col    # inc ctr
inc_col:
	inc r3, 1	# j++	
	lc r9, $inc_row
	beq r9, r3, r12 # if j==len, inc_row and reset j
	jmp $init_loop
inc_row:
	inc r2, 1		# i++
	lc r3, 0		# j=0
	jmp $init_loop
load_hole:
	# r3 holds 2 for division to get middle point of board
	# r4 = middle point
	# r5 = index into array for center point
	lc r3, 2
	div r4, r12, r3	# get middle point
	mul r5, r4, r12	# array index == i*len + j
	add r5, r5, r4	
	st1 r15, r5, 0	# put hole in center
# main loop
loop:
# draw board
# algorithm:
# 	quick loop to draw top line of numbers
#	init counters and labels
#	for (i=0;i<max_len;i++) {
#		printf ("%d ", i);
#		for (j=0;j<max_len;j++)
#			printf ("%c ", board[i][j]);
#		printf ("%d ", i);
#		printf ("\n");
#	}
#	another loop to draw bottom line of numbers

	lc r2, 0		# i
	lc r3, $top_draw_loop
	sys r13, 3		# print two spaces to start line
	sys r13, 3
	lc r5, '0'		# load ascii constant for 0
top_draw_loop:
	add r4, r2, r5  # get ASCII num for i
	sys r4, 3	# draw col num
	sys r13, 3	# then a space
	inc r2, 1	# i++
	bgt r3, r12, r2 # repeat loop while (len>i)
	lc r7, '\n'
	sys r7, 3
# init ctrs
	# start first line with "0 "
	lc r2, '0'
	sys r2, 3
	sys r13, 3
	lc r2, 0		# i, row ctr
	lc r3, 0		# j, col ctr
	lc r4, $bottom_draw_loop_init
	lc r8, $inc_d_row 
draw_loop:
	mul r5, r2, r12 # get array index
	add r5, r5, r3
	ld1 r5, r5, 0	# load char from array
	sys r5, 3 	# print char
	sys r13, 3  	# print space
	inc r3, 1	# j++
	beq r8, r3, r12 # if col==len, inc row and reset col
	jmp $draw_loop
inc_d_row:
	# print index num for this row 
	lc r5, '0'
	add r5, r5, r2  # get ASCII num for current row
	sys r5, 3	# print the number
	sys r7, 3	# print newline at end of col
	# then print index number for next row and a space
	inc r2, 1	# i++
	beq r4, r2, r12 # if row==len, move onto getting coords
	lc r5, '0'
	add r5, r5, r2	# get ASCII num for new row
	sys r5, 3	# print number
	sys r13, 3	# print space
	lc r3, 0	# j=0
	jmp $draw_loop
# quick loop to draw bottom line of nums
bottom_draw_loop_init:
	lc r2, 0	# i
	lc r3, $bottom_draw_loop
	sys r13, 3	# print two spaces to start line
	sys r13, 3
	lc r5, '0'
bottom_draw_loop:
	add r4, r2, r5  # get ASCII num for i
	sys r4, 3	# draw col num
	sys r13, 3	# then a space
	inc r2, 1	# i++
	bgt r3, r12, r2 # repeat loop while (len>i)
	lc r7, '\n'
	sys r7, 3
# check for stalemate or win
# use a simple algorithm: loop over array w/o bothering to exclude
# out of bounds. check for is_legal_move on each of the
# four potential landing spots (let is_legal_move sort out if the landing
# spot is not on the array). only concession to efficiency - if first
# check tells us that the current cell is not a peg, skip directly
# to next spot in array.

# note that we don't stash r4 and r5 by taking advantage of the
# fact that is_legal_move never modifies them

# note that for each of the four tests we re-use the check_move
# portion which actually does the work and then calls is_legal_move.
# how does check_move know where to return when it's done if it is
# jumped to from four different places? use a register which contains
# the appropriate PC to jump back to when it is done, which we can
# vary from each of the four entry points to check_move before jumping
# to check_move. the register used is r8.

# note we do the same thing when jumping to is_legal_move, except
# that we use r3 to hold the return address

possible_moves:
	lc r4, 0	# i=0
	lc r5, 0	# j=0
	lc r10, 0	# num pegs on board
# we don't need r10 after initialization of bd, so use it as counter
# for number of pegs - if one peg, we get a win rather than stalemate
pm_loop:
# test1
	lc r6, 2	# row offset for test1
	lc r7, 0	# col offset for test1
	lc r8, $cm_test2  # return addr for check_move is next test, test2
check_move:
	lc r9, $cm_ra	# get mem addr for cm_ra
	st1 r8, r9, 0	# store return address bec otherwise is_legal_move
			# will clobber it
	add r6, r6, r4	# generate to_row by adding from_row to offset
	add r7, r7, r5	# generate to_col by adding from_col to offset
	lc r3, 2
# WARNING - semi-hack:
# store return address in r3, we get this by executing a guaranteed
# to fail branch in order to get the PC into r1
	beq r6, r0, r3	# always fails, hack to get PC into r1
# why PC+2? because this add is == PC, but we want to come back to
# the instruction after the jmp, which will move on with the code, 
# therefore PC+2
	add r3, r1, r3	# set return addr
# r2 = return value (0 or 1) indicating legality of move
# NOTE - 0 INDICATES SUCCESS, NOT FAILURE, OF MOVE
# THIS IS BECAUSE DIFFERENT POSITIVE VALUES WILL INDICATE
# DIFFERENT TYPES OF FAILURE
	jmp $is_legal_move
	lc r8, $pm_inc
	lc r3, 2	# return code for non-peg in "from"
	beq r8, r3, r2	# if "from" not peg, then skip rest of comps and inc
	lc r8, $get_coords
	beq r8, r0, r2	# if successful, no stalemate, keep playing
# recover return addr of check_move from memory
	lc r8, $cm_ra
	ld1 r8, r8, 0
	beq r8, r0, r0	# jmp to return addr
cm_test2:
	inc r10, 1	# if we got here, there is a peg in this index
	lc r6, -2	# row offset
	lc r7, 0	# col offset
	lc r8, $cm_test3
	jmp $check_move
cm_test3:
	lc r6, 0	# row offset
	lc r7, 2	# col offset
	lc r8, $cm_test4
	jmp $check_move
cm_test4:
	lc r6, 0	# row offset
	lc r7, -2	# col offset
	lc r8, $pm_inc
	jmp $check_move
pm_inc:
	inc r5, 1	# j++
	lc r9, $pm_inc_row
	beq r9, r12, r5	# if j==max, then inc row
	jmp $pm_loop
pm_inc_row:
	inc r4, 1   # i++
	lc r3, $stalemate
	beq r3, r4, r12	# if we got to end without a move, then stalemate
	lc r5, 0	# j=0
	jmp $pm_loop
get_coords:
	lc r4, '\n'	# print newline
	sys r4, 3
	lc r4, $fr	# print from_row prompt
	sys r4, 4
	sys r4, 5	# get from_row
	lc r5, $fc	# print from_col prompt
	sys r5, 4
	sys r5, 5	# get from_col
	lc r6, -1
	lc r7, $check_col
	beq r7, r4, r6  # if row == -1, also check for col == -1
c_get_coords:
	lc r6, $tr	# print to_row prompt
	sys r6, 4
	sys r6, 5	# get to_row
	lc r7, $tc	# print to_col prompt
	sys r7, 4
	sys r7, 5	# get to_col
	lc r8, '\n'
	sys r8, 3	# print newline

# now, call is_legal_move and if move is legal, make_move

# WARNING - semi-hack:
# store return address in r3, we get this by executing a guaranteed
# to fail branch in order to get the PC into r1
	lc r2, 2	
	beq r2, r2, r0	# will always fail
	add r3, r1, r2	# stash PC+2 (return address) in r3
# why PC+2? because this add is == PC, but we want to come back to
# the instruction after the jmp, which will move on with the code, 
# therefore PC+2
	jmp $is_legal_move
# r8 = return value holding index of "center" cell of move
# r2 = return value indicating success of move (0 for success)
	lc r3, 0
	lc r9, $make_move
	beq r9, r2, r3	# if move legal, then make move
	jmp $not_legal	# else illegal move
check_col:
	lc r7, $exit
	beq r7, r5, r6	# if col also == -1, exit
	jmp $c_get_coords

# are the four coords inside the array bounds?
# if 0 > coord or coord > len-1, then coord out of bounds
# args: r3 = return addr
#		r4 = from row
#		r5 = from col
#		r6 = to row
#		r7 = to col
# note r2 is return value, so must hold correct val before returning
# return codes:
# 	0 = legal
#	1 = illegal coords (either out of bounds, or "to" wrong dist from "from"
# 	2 = "from" not a peg
#	3 = "to" not a hole
#	4 = "center" not a peg
is_legal_move:
# check that peg is in "from" cell, must make this check first!
# (because of way peg counting is done in possible_moves)
# if it's a hole, then illegal
	# r9 = array index of from cell
	mul r9, r4, r12	# get from index == i*len + j
	add r9, r9, r5
	ld1 r9, r9, 0	# get the char
	lc r2, 2	# load failure code for "from" != peg
	beq r3, r9, r15 # if "from" cell == hole, then illegal
	beq r3, r9, r13 # if char == space, move is illegal, return
# now check for everything else
	lc r2, 1	# if any of these eval to false, must return 1
	lc r9, 1
	sub r9, r12, r9 # get max_len - 1
	bgt r3, r0, r4	# check from_row > -1
	bgt r3, r4, r9	# check from_row < max_len
	bgt r3, r0, r5	# check from_col > -1
	bgt r3, r5, r9	# check from_row < max_len
	bgt r3, r0, r6	# check to_row > -1
	bgt r3, r6, r9	# check to_row < max_len
	bgt r3, r0, r7	# check to_col > -1
	bgt r3, r4, r9	# check to_col < max_len
# if "to" cell == space , then move is illegal
	mul r9, r6, r12	# get from index == i*len + j
	add r9, r9, r7
	ld1 r9, r9, 0	# get the char
	lc r2, 3	# failure return code
	beq r3, r9, r13 # if char == space, move is illegal
# check that either abs(to_row - from_row) = 2 && abs(to_col - from_col) == 0
# or vice versa - this checks that "to" cell is two spots away in one of 
# the four cardinal directions
# note, we're re-using constant r11 which is no longer needed
	sub r11, r4, r6	# r8 = from_row - to_row
	lc r9, $col_zero
	lc r8, 2
	lc r2, 1
	beq r9, r11, r8	# if row diff == 2, then check col diff == 0
	lc r8, -2
	beq r9, r11, r8	# if row diff == -2, then check col diff == 0
	lc r9, $col_two
	beq r9, r11, r0  # if row diff == 0, then check col diff == 2 or -2
	beq r3, r0, r0	# move is illegal, return
# check that col diff == 0 (row diff known to be +/- 2)
col_zero:
	lc r9, $legal_chars
	sub r2, r5, r7	# r2 = from_col - to_col
	beq r9, r0, r2	# if col diff == 0, then legal
	lc r2, 1
	beq r3, r0, r0	# move is illegal, return
# check that col diff == 2 or -2 (row diff known to be zero)
col_two:
	lc r9, $legal_chars
	sub r2, r5, r7	# r2 = from_col - to_col
	lc r8, 2
	beq r9, r8, r2	# if col diff == 2, then legal
	lc r8, -2
	beq r9, r8, r2	# if col diff == -2, then legal
	lc r2, 1
	beq r3, r0, r0	# move is illegal, return

# now, check other correct chars: peg in 'middle' cell and hole in "to" cell

# note that in the following checks i take advantage of the fact
# that both cells are known to be in bounds, and therefore can
# only contain a peg or a hole

legal_chars:
# check that hole is in "to" cell
	# r9 = array index of "to" cell
	mul r9, r6, r12	# get from index == i*len + j
	add r9, r9, r7
	ld1 r9, r9, 0	# get the char
	lc r2, 3
	beq r3, r9, r14	# if "to" cell == peg, then illegal
# get coords of center cell and check that it's a peg
	sub r2, r4, r6  # r2 = from_row - to_row
	lc r9, -2
	div r2, r2, r9	# r2 = diff / -2, is proper row offset from "from" cell
	sub r8, r5, r7	# r8 = from_col - to_col
	div r8, r8, r9	# same thing for col offset
	add r2, r2, r4  # row coord for center cell
	add r9, r8, r5  # col coord for center cell
	# r8 = array index of from cell
	mul r8, r2, r12	# get from index == i*len + j
	add r8, r8, r9
	ld1 r9, r8, 0	# get the char
	lc r2, 4	# load failure code for center cell
	beq r3, r9, r15	# if "center" cell == hole, then illegal
	lc r2, 0	# load success code
	beq r3, r0, r0	# move is legal, return
not_legal:
	lc r9, $illegal
	sys r9, 4	# print illegal move msg
	jmp $loop

# make the move
# r8 still holds index of center, so make it a hole
make_move:
	st1 r15, r8, 0	# put hole in "center" cell
	# r2 = array index of from cell
	mul r2, r4, r12	# get from index == i*len + j
	add r2, r2, r5
	st1 r15, r2, 0	# put hole in from cell
	# r2 = array index of "to" cell
	mul r2, r6, r12	# get from index == i*len + j
	add r2, r2, r7
	st1 r14, r2, 0	# put peg in "to" cell
	jmp $loop
stalemate:
	lc r2, $stalemsg
	lc r3, 1
	lc r4, $win
	beq r4, r3, r10	# if num pegs == 1, then give a win msg
	sys r2, 4
	jmp $exit
win:
	lc r2, $winmsg
	sys r2, 4
exit:
	lc r2, $bye
	sys r2, 4
	sys r0, 0

_data_:
# to leave enough space for the board 
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
fr: .byte 'f','r','o','m',' ','r','o','w'
    .byte ':',' ',0
fc: .byte 'f','r','o','m',' ','c','o','l'
    .byte ':',' ',0
tr: .byte 't','o',' ','r','o','w',':',' '
    .byte 0
tc: .byte 't','o',' ','c','o','l',':',' '
    .byte 0
bye: .byte 'b','y','e','\n',0
illegal: .byte 'i','l','l','e','g','a','l','!'
	 .byte '\n', 0
space:	 .byte ' '
hole:	 .byte 'o'
peg:	 .byte '*'
max_len: .byte 7	# array length
bound1:	 .byte 1 	# bound1 for out of bounds checking
bound2:  .byte 4  	# bound2 - 1, bec we have to use bgt
stalemsg: .byte 's','t','a','l','e','m','a','t'
	  .byte 'e', '!', '\n', 0
winmsg:   .byte 'w','i','n','!','\n',0
cm_ra:	  .byte ' '	# to hold return address for check_moves
