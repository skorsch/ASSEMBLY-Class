# UVic CSC 230, Summer 2020
# Assignment #1, part A

# Student name: Sabrina Korsch
# Student number: V00847425


# Compute M % N, where M must be in $8, N must be in $9,
# and M % N must be in $15.


.text
start:
	lw $8, testcase5_M
	lw $9, testcase5_N

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	beq $9, $0, invalid_num		#check that n is not zero
	
	add $20, $0, $9			#temp reg to hold n and check that n is not negative
	rol $20, $20, 1			#rotate this value left by one so we can check leftmost bit
	andi $21, $20, 1		#put leftmost bit of n into temp reg $21
	bne $21, $0, invalid_num	#if the leftmost bit does not equal zero go to invalid_num
	
	addi $20, $0, 127		#temp reg to hold 127 to check that n is not greater than it
	sub $20, $20, $9		#subtract n from 127
	rol $20, $20, 1			#rotate $20 to the left so we can check leftmost bit
	andi $21, $20, 1		#put leftmost bit into reg $21
	bne $21, $0, invalid_num	#if leftmost bit does not equal zero, go to invalid_num
				
	beq $8, $0, invalid_num		#check that m is not zero
				
	add $20, $0, $8			#temp reg to hold m and check that it's not negative
	rol $20, $20, 1			#rotate this value left by one so we can check leftmost bit
	andi $21, $20, 1		#put leftmost bit of n into temp reg $21
	bne $21, $0, invalid_num	#if the leftmost bit does not equal zero go to invalid_num


loop:				#loop to subtract n from m

	sub $8, $8, $9			#m = m - n
	add $10, $0, $8			#reg to temp hold the current m value so we can check its sign
	rol $10, $10, 1			#check sign of m by rotate left...
	andi $11, $10, 1		#...then take first digit ($11 hold temp value of first bit)...
	beq $11, $0, loop		#and compare it, if it's 0 keep looping (it's non - negative)
				
				
	add $15, $8, $9			#add n back to m and put into reg $15 as final answer
	beq $0, $0, exit		#exit so invalid_num assignment is skipped
				
invalid_num:
	addi $15, $0, -1

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall
		

.data

# testcase1: 370 % 120 = 10
#
testcase1_M:
	.word	370
testcase1_N:
	.word 	120
	
# testcase2: 24156 % 77 = 55
#
testcase2_M:
	.word	24156
testcase2_N:
	.word 	77

# testcase3: 21 % 0 = -1
#
testcase3_M:
	.word	21 
testcase3_N:
	.word 	0 
	
# testcase4: 33 % 120 = 33
#
testcase4_M:
	.word	33
testcase4_N:
	.word 	120
	
testcase5_M:
	.word	123456
testcase5_N:
	.word 	1179
