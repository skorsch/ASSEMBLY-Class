	.data
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
KEYBOARD_COUNTS:
	.space  128
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
	
	
	.eqv 	LETTER_a 97
	.eqv	LETTER_b 98
	.eqv	LETTER_c 99
	.eqv 	LETTER_D 100
	.eqv 	LETTER_space 32
	
	
	.text  
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	#the following 4 lines are taken from lab since they are related to setting up the keyboard simulator
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)
	
	la $s6, KEYBOARD_COUNTS	#load in address for count storage

check_for_event:
	la $s2, KEYBOARD_EVENT_PENDING
	lw $s3, 0($s2)
	beq $s3, $zero, check_for_event #check for event loops until keyboard event pend is not zero
	
	#start of keyboard event
	la $s4, KEYBOARD_EVENT
	lw $s5, 0($s4)		#loads in value of keyboard event
	beq $s5, 97, key_a	#a was pressed
	beq $s5, 98, key_b	#b was pressed
	beq $s5, 99, key_c	#c was pressed
	beq $s5, 100, key_d	#d was pressed
	beq $s5, 32, key_space	#space was pressed
	#something else was pressed and does not effect the program so exit 
	beq $zero, $zero, exit

key_a:
	lw $t1, 0($s6)	#loads in first byte of count storage
	addi $t1, $t1, 1	#increments count for this letter
	sw $t1, 0($s6)	#stores it back into the count space
	beq $zero, $zero, exit

key_b:
	lw $t1, 4($s6)	#loads in second byte of count storage
	addi $t1, $t1, 1	#increments count for this letter
	sw $t1, 4($s6)	#stores it back into the count space
	beq $zero, $zero, exit

key_c:
	lw $t1, 8($s6)	#loads in third byte of count storage
	addi $t1, $t1, 1	#increments count for this letter
	sw $t1, 8($s6)	#stores it back into the count space
	beq $zero, $zero, exit

key_d:
	lw $t1, 12($s6)	#loads in fourth byte of count storage
	addi $t1, $t1, 1	#increments count for this letter
	sw $t1, 12($s6)	#stores it back into the count space
	beq $zero, $zero, exit

key_space:	
	addi $t1, $zero, 4
	add $t2, $zero, $s6 #temp reg for count address so it doesn't get altered
	#SAME AS ANSWER FOR PART A OF THIS ASSIGNMENT
loop:
	beq $t1, $zero, end_loop	#start check for zero
	beq $t1, 1, print_no_space	#makes sure not to print an extra space if only one int
	lw $a0, 0($t2)		#load int at current address into a0
	addi $v0, $zero, 1	#load instruc for printing int into v0
	syscall 		#prints out int
	
	la $a0, SPACE		#print a space 
	addi $v0, $zero, 4
	syscall
	
	addi $t2, $t2, 4 	#goes to next int, increment address by 4
	addi $t1, $t1, -1	#decrement int count
	bne $t1, 1, loop	#loop if not equal to zero

#prints last int without a space at end, wasn't explicitly stated in assignment but the typed example doesn't have one at the end of a line
print_no_space:
	lw $a0, 0($t2)		#load int at current address into a0
	addi $v0, $zero, 1	#load instruc for printing int into v0
	syscall 		#prints out int
	
end_loop:
	la $a0, NEWLINE		#print newline
	addi $v0, $zero, 4
	syscall
			
exit:
	sw $zero, KEYBOARD_EVENT_PENDING	#continue prev loop by setting pending to zero
	beq $zero, $zero, check_for_event
	

	.kdata

	.ktext 0x80000180
__kernel_entry: #TAKEN FROM LAB (not sure how you would write these any different)
	mfc0 $k0, $13		# $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	# seperate exccode bits
	srl  $k1, $k1, 2	# shift ExcCode bits for easier comparison
	beq $zero, $k1, __is_interrupt	#if they equal zero it's an interrupt
	
__is_exception: #TAKEN FROM LAB
	#kinda catchall exception
	beq $zero, $zero, __exit_exception
	
__is_interrupt:	#TAKEN FROM LAB 
	andi $k1, $k0, 0x0100	# examine bit 8 knows which device it came from
	bne $k1, $zero, __is_keyboard_interrupt	 # if bit 8 set, then we have a keyboard interrupt.
	
	beq $zero, $zero, __exit_exception	# otherwise, we return exit kernel
	
__is_keyboard_interrupt:
	la $k0, 0xffff0004	#loads address of keypress into $k0
	lw $k1, 0($k0)		#loads value at that address
	sw $k1, KEYBOARD_EVENT	#stores the keypress value into keyboard event mem space
	addi $k0, $zero, 1
	sw $k0, KEYBOARD_EVENT_PENDING	#stores 1 into this mem space to indicate a keypress happened for non kernel code

__exit_exception:
	eret
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

	
