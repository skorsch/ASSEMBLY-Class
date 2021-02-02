.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	# jal save_our_souls

	#morse_flash test for part B
	# addi $a0, $zero, 0x42   # dot dot dash dot
	# jal morse_flash
	
	## morse_flash test for part B
	# addi $a0, $zero, 0x37   # dash dash dash
	# jal morse_flash
		
	## morse_flash test for part B
	# addi $a0, $zero, 0x32  	# dot dash dot
	# jal morse_flash
			
	## morse_flash test for part B
	# addi $a0, $zero, 0x11   # dash
	# jal morse_flash	
	
	# flash_message test for part C
	# la $a0, test_buffer
	# jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	# addi $a0, $zero, 'P'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	# addi $a0, $zero, 'A'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	# addi $a0, $zero, ' '
	# jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	 la $a0, message01
	 la $a1, buffer01
	 jal encode_message
	 la $a0, buffer01
	 jal flash_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall

	
	
###########
# PROCEDURE
save_our_souls:
	addi $sp, $sp, -4	#stores ra in stack 
	sw $ra, 0($sp)
	addi $t0, $0, 3

dot_loop:			#3 dots
	jal seven_segment_on	
	jal delay_short
	jal seven_segment_off
	jal delay_long
	addi $t0, $t0, -1
	bne $t0, $0, dot_loop
	addi $t0, $0, 3
	
dash_loop:			#3 dashes
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	addi $t0, $t0, -1
	bne $t0, $0, dash_loop
	addi $t0, $0, 3
		
dot_loop_2:			#3 dots
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	addi $t0, $t0, -1
	bne $t0, $0, dot_loop_2
	
	lw $ra, 0($sp)		#loads the stored ra from the stack
	addi $sp, $sp, 4
	jr $31


# PROCEDURE
morse_flash:
	addi $sp, $sp, -8	#exapnd stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)		#stores ra and a0 in stack
	
	andi $a0, $a0, 0xff	#cut off extra bits so that it's only 8 bits long, used to fix the 0xfffffffff bug
	
	addi $t1, $0, 255	#temp value to compare input to the special value
	beq $a0, $t1, between_words	#if it equals the special value go to this method
	
	srl $s0, $a0, 4		#temp reg to store length value
	add $s1, $a0, $0 	#temp reg for a0 so we can alter and check bits
	addi $t0, $0, 4		#temp reg for skipping the first bits depending on length
	
	sub $t0, $t0, $s0	#gives us how many bits to skip
skip:
	beq $t0, $0, morse_flash_loop	#if full length, don't skip any bits
	sll $s1, $s1, 1		#skip the bit
	addi $t0, $t0, -1	#decrement the loop
	beq $0, $0, skip
	
morse_flash_loop:
	beq $s0, $0, flash_end	#if the length is zero end right away
	addi $s0, $s0, -1	#decrement the loop
	andi $s2, $s1, 8	#check 4th bit
	beq $s2, $0, dot	#if it's unset print a dot
	
	addi $sp, $sp, -12	#need to store these otherwise they get overwritten by the following jal's
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)			
	#flash dash (bit is set so print a dash)
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	
	lw $s0, 0($sp)		#restore values
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12	#shrink stack
	sll $s1, $s1, 1		#rotate it to the next bit
	beq $0, $0, morse_flash_loop	#loop
	
dot:
	addi $sp, $sp, -12	#need to store these otherwise they get overwritten by the following jal's
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	#flash dot
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	lw $s0, 0($sp)		#restore values
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	sll $s1, $s1, 1	
	bne $s0, $0, morse_flash_loop	#if length is still not zero, loop
	
flash_end:
	jal delay_long	#SPACE BETWEEN LETTERS?? it was a bit hard to understand what the assignment wanted - but i talked to david about it
	
	lw $ra, 0($sp)		#loads the stored ra and a0 from the stack
	lw $a0, 4($sp)
	addi $sp, $sp, 8	#shrink stack
	jr $ra

between_words:			#special value method for 0xff it is specified in the outline that this must be 3 delay longs
	jal delay_long		#however in my program due to the delays at the end of letter, dots, dashes etc. this delay ends up being 5 delay longs
	jal delay_long		#i was unsure about this but david said as long as they are different lengths, the overall length doesn't matter
	jal delay_long
	beq $0, $0, flash_end	#once done go to end
	

###########
# PROCEDURE
flash_message:
	addi $sp, $sp, -8	#stores ra in stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)		#stores ra and a0 in stack
	add $s0, $0, $a0	#copy a0 so we can use a0 in our call to morse_flash
	
flash_message_loop:
	lb $a0, 0($s0)		#load byte to be flashed into a0
	beq $a0, $0, flash_message_end	#if the byte is zero then end the message
	#otherwise call morse_flash with that byte
	addi $sp, $sp, -4	#store s0 on the stack so morse_flash doesn't change it
	sw $s0, 0($sp)
	jal morse_flash
	lw $s0, 0($sp)		#restore s0
	addi $sp, $sp, -4
	addi $s0, $s0, 1	#increment memory address
	beq $0, $0, flash_message_loop 	#loop
	
flash_message_end:
	lw $ra, 0($sp)		#loads the stored ra and a0 from the stack
	lw $a0, 4($sp)
	addi $sp, $sp, 8	#shrink stack
	jr $ra
	
	
###########
# PROCEDURE
letter_to_code:
	addi $sp, $sp, -8	#stores ra in stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)		#stores ra and a0 in stack
	
	la $t0, codes		#memory address of the start of the code table
	addi $t2, $0, 90	#stop condition, stops loop after letter Z
	add $t3, $0, $0		#this temp will be used to encode the high nybble value by counting how many times it loops
	add $v0, $0, $0 	#zero out v0 so multiple calls wont add onto eachother
	
letter_to_code_loop:
	lb $t1, 0($t0) 		#loads letter at current address
	beq $a0, 32, encode_space
	bne $a0, $t1, search_more	#if they arent equal increment mem space to next letter
	#they are equal
match_loop:
	addi $t0, $t0, 1	#goes to next byte
	lb $t4, 0($t0)
	beq $t4, $0, letter_to_code_end	#if the byte is zero go to end and return v0
	beq $t4, 46, encode_dot #if t4 is a dot got to encode dot else it's a dash
	#encode dash
	sll $v0, $v0, 1		#put shift first so it doesn't have an extra shift at the end
	addi $v0, $v0, 1	#adds to rightmost bit
	addi $t3, $t3, 16
	beq $0, $0, match_loop
	
encode_dot:
	sll $v0, $v0, 1		#shifting inserts the zero
	addi $t3, $t3, 16
	beq $0, $0, match_loop
	
search_more:
	beq $t1, $t2, letter_to_code_end 	#loop stop condition (letter not found)
	addi $t0, $t0, 8	#go to next letter
	beq $0, $0, letter_to_code_loop
	
encode_space:
	addi $v0, $0, 0xff	#encodes the special value if there is a space

letter_to_code_end:
	add $v0, $v0, $t3	#encodes high nyb	
	lw $ra, 0($sp)		#loads the stored ra and a0 from the stack
	lw $a0, 4($sp)
	addi $sp, $sp, 8	#shrink stack
	jr $ra
	


###########
# PROCEDURE
encode_message:
	addi $sp, $sp, -8	#stores ra in stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)		#stores values in the stack
	
	add $s0, $a0, $0	#copy value of a0 so it can be used in other method calls	
	
encode_message_loop:
	lb $a0, 0($s0)		#grab the byte value of current letter and put into a0
	beq $a0, $0, encode_message_end	#if the byte is zero end the encoding
	addi $sp, $sp, -8	
	sw $a1, 0($sp)		#store current buffer point
	sw $s0, 4($sp)		#store current letter
	
	jal letter_to_code
	#v0 is now the one byte eq of the letter
	lw $a1, 0($sp)		#restores the stored values 
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	
	sb $v0, 0($a1)		#stores encoded byte into the buffer
	addi $a1, $a1, 1	#increment to next storage spot byte
	addi $s0, $s0, 1	#increment to next letter to be encoded
	
	beq $0, $0, encode_message_loop
	
encode_message_end:
	lw $ra, 0($sp)		#restores the stored values 
	lw $a0, 4($sp)	
	addi $sp, $sp, 8	#shrink stack
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "AAAA"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x00    # This is SOS
