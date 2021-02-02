	.data
	
TEST_A_16x16:
	.byte  	9 3 8 5 7 0 8 3 9 3 4 7 3 5 7 1
       		4 3 2 1 7 8 5 3 7 5 3 6 6 3 1 6
       		7 4 3 1 9 5 4 6 6 3 6 1 6 6 0 7
       		3 8 1 5 0 5 5 0 4 9 2 0 6 2 4 1
       		2 6 5 9 7 2 7 8 4 2 8 0 1 1 0 9
       		5 8 7 1 9 9 7 2 2 3 8 7 2 1 2 4
       		5 6 1 0 8 8 5 7 0 3 4 5 1 4 2 4
       		7 3 6 1 8 5 3 1 4 2 0 0 6 9 7 9
       		0 5 3 4 7 3 8 9 8 5 5 0 2 4 5 5
       		6 6 0 3 8 1 3 2 1 2 5 1 5 0 7 3
       		5 8 8 3 2 7 8 8 5 4 4 4 3 6 3 7
       		4 0 3 0 9 5 7 7 0 4 8 3 0 7 9 0
       		0 6 7 4 9 2 7 0 0 4 9 1 1 9 7 5
       		8 1 2 7 6 1 4 0 3 5 3 8 1 3 3 2
       		2 9 3 7 2 0 3 8 8 3 1 9 8 0 5 8
       		2 9 7 2 1 1 0 7 9 9 9 9 1 4 6 2
	
	.text
main:

# Students may modify this "main" section temporarily for their testing.
# However, when evaluating your submission, all code from lines 1
# to 49 will be replaced by other testing code (i.e., we will only
# keep code from lines 50 onward). If your solution breaks because
# you have ignored this note, then a mark of zero for Part 2
# of the assignment is possible.

	#la $a0, TEST_A_16x16
	#addi $a1, $zero, 4	
	#addi $a2, $zero, 0	
	#jal sum_neighbours		# Test 2a; $v0 should be 30
	
	#la $a0, TEST_A_16x16
	#addi $a1, $zero, 9
	#addi $a2, $zero, 8
	#jal sum_neighbours		# Test 2b; $v0 should be 43
	
	la $a0, TEST_A_16x16
	addi $a1, $zero, 15
	addi $a2, $zero, 15
	jal sum_neighbours		# Test 2c; $v0 should be 19
			
	addi $v0, $zero, 10
	syscall


# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	.data
	
# Available for any extra `.eqv` or data needed for your solution.

	.text
	
	
# sum_neighbours:
#
# $a0 is 16x16 byte array
# $a1 is row (0 is topmost)
# $a2 is column (0 is leftmost)
#
# $v0 holds the value of the bytes around the row and column
sum_neighbours:
#since it wasn't specified in part two of the assignment, i asked zastre what the behaviour of this method should be if the addresses given are invalid and he said it doesn't matter
#i added checks but then got rid of them for the sake of simplicity
	addi $s0, $zero, 8	#number of values to be added together
	addi $a1, $a1, -1
	addi $a2, $a2, -1	#start in top left corner
	addi $s1, $zero, 3	#another counter
	add $s2, $zero, $zero	#temp reg to hold final v0 value
col_loop:
	addi $sp, $sp -28	#store values before call
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	
	jal get_16x16		#get value at this spot
	
	lw $ra, 0($sp)		#restore
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	addi $sp, $sp, 28
	
	add $s2, $s2, $v0	#add returned value to total
	addi $s0, $s0, -1	#decrement counters
	addi, $s1, $s1, -1
	addi $a2, $a2, 1	#go to next column
	beq $s0, $zero, add_end
	bne $s1, $zero, col_loop	#loops col for 3 elem
	
	addi $s1, $zero, 2	#grab 2 elem in the middle
	addi $a1, $a1, 1	#set to middle row
	addi $a2, $a2, -3	#reset column
mid_loop:
	addi $sp, $sp -28	#store values before call
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	
	jal get_16x16		#get value at this spot
	
	lw $ra, 0($sp)		#restore
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	addi $sp, $sp, 28
	
	add $s2, $s2, $v0	#add returned value to total
	addi $s0, $s0, -1	#decrement counters
	addi, $s1, $s1, -1
	addi $a2, $a2, 2	#go to far column
	beq $s0, $zero, add_end	#not really needed but just in case
	bne $s1, $zero, mid_loop	#loops col for 2 elem
	
	addi $s1, $zero, 3	#grab 3 elem in bottom
	addi $a1, $a1, 1	#set to last row
	addi $a2, $a2, -4	#reset column
	beq $zero, $zero, col_loop	

add_end:
	add $v0, $zero, $s2
	jr $ra
	
# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
set_16x16:
	add $t0, $zero, $a1	#a check for a valid row address
	srl $t0, $t0, 4
	bne $t0, $zero, invalid_address #value is above 15
	add $t1, $zero, $zero	#will hold 1D array value at end	
multiply: 
	beq $zero, $a1, stop
	addi $t1, $t1, 16	#increases by 1 row of mem values
	addi $a1, $a1, -1
	bne $zero, $a1, multiply	
stop:	
	add $t1, $t1, $a2	#t1 now holds the 1D array value to put the value into (added column value)
	add $t0, $zero, $a2	#a check for a valid row address
	srl $t0, $t0, 4
	bne $t0, $zero, invalid_address #value is above 15

	add $a0, $a0, $t1	#proper address
	andi $a3, $a3, 0xff	#grab rightmost 8 bits
	sb $a3, ($a0)
	
invalid_address:	#does nothing if values were invalid
	jr $ra
	
	
# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
get_16x16:

	add $t0, $zero, $a1	#a check for a valid row address
	srl $t0, $t0, 4
	bne $t0, $zero, get_invalid_address #value is above 15
	add $t1, $zero, $zero	#will hold 1D array value at end	
get_multiply: 
	beq $zero, $a1, get_stop
	addi $t1, $t1, 16	#increases by 1 row of mem values
	addi $a1, $a1, -1
	bne $zero, $a1, get_multiply	
get_stop:	
	add $t1, $t1, $a2	#t1 now holds the 1D array value to put the value into (added column value)
	add $t0, $zero, $a2	#a check for a valid row address
	srl $t0, $t0, 4
	bne $t0, $zero, get_invalid_address #value is above 15

	add $a0, $a0, $t1	#proper address
	lb $v0, ($a0)		#loads byte at that address into v0
	
end:
	jr $ra
	
get_invalid_address:	#returns zero if values are invalid
	add $v0, $zero, $zero
	beq $zero, $zero, end
	

# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
copy_16x16:
	addi $t0, $zero, 256	#just need to copy all memory values in linear succession
copy_loop:
	beq $t0, $zero, loop_end
	addi $t0, $t0, -1
	lb $t1, ($a1)
	sb $t1, ($a0)
	addi $a0, $a0, 1	#go to next bytes
	addi $a1, $a1, 1
	bne $t0, $zero, copy_loop
	
loop_end:
	jr $ra


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
