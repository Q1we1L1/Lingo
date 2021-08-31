#================================================
# Lingo game program - By Qiwei Li
#================================================

	.data			#data segment
welcome:	.asciiz "Welcome to Lingo!\n\n"

word_head:	.ascii "The word to guess is : "
word_tail:	.asciiz "? _ _ _ _\n"

guess_msg:	.ascii "\nEnter guess number "
guess_tail:	.asciiz "0 : "

new_line:	.asciiz "\n"

win_msg:	.asciiz	"You win!\n"
lost_msg:	.asciiz "You lost!\n"
again_msg:	.asciiz "Would you like to play again? "

right_place:	.asciiz "? is in the right place\n"
wrong_place:	.asciiz "? is in the word but not the right place\n"

selected_str:	.space	6		# random selected string
input_str:	.space	6		# user inputed string, max length is 5.

all_strings:	.ascii "april"
		.ascii "bloom"
		.ascii "couch"
		.ascii "debug"
		.ascii "funny"
		.ascii "goose"
		.ascii "habit"
		.ascii "phone"
		.ascii "limit"
		.ascii "month"

	.text				# Code segment
	.globl	main			# declare main to be global

main:		
	la	$a0, welcome
	li	$v0, 4
	syscall

new_game:
	li 	$v0, 30
	syscall				# get system time

	and 	$a0, $a0, 0xF
	blt 	$a0, 10, random_number_done
	li 	$a0, 9			# if big than 10, set to 9

random_number_done:
	add 	$v0, $a0, 0		# get a random number in $v0, 0 - 9

	mul	$v0, $v0, 5 
	la 	$a0, all_strings
	add	$a0, $a0, $v0 		# get the address of random selected string

	lb 	$t0, ($a0)
	sub 	$t0, $t0, 0x20		# change lower char to upper char
	la 	$a1, word_tail
	sb 	$t0, ($a1)		# set the head char for show

	la 	$a1, selected_str	# copy string to selected str
	li 	$t0, 0
copy_next:
	lb 	$t1, ($a0)
	sub 	$t1, $t1, 0x20		# change lower char to upper char
	sb 	$t1, ($a1)
	add 	$t0, $t0, 1
	add 	$a0, $a0, 1
	add 	$a1, $a1, 1
	blt 	$t0, 5, copy_next

	la	$a0, word_head		# show word prompt
	li 	$v0, 4
	syscall

	li 	$a0, 0
round_next:
	jal	user_guess
	beq 	$v0, 1, round_done	# when user guess right, jump to done

	add 	$a0, $a0, 1
	blt	$a0, 5, round_next	# when round number < 5, continue

	la	$a0, lost_msg
	li 	$v0, 4
	syscall

round_done:
	la 	$a0, again_msg		# does the user want another game?
	li 	$v0, 4
	syscall

	la	$a0, input_str		# get user input
	li	$a1, 6
	li	$v0, 8
	syscall

	lb 	$t0, ($a0)
	beq 	$t0, 'Y', new_game
	beq 	$t0, 'y', new_game


exit:	li	$v0, 10		# exit
	syscall

# --------------------------------------------------------------------------------
# Get user's input, and check whether it is right
# input: $a0, round of game, 0 - 5
# output: $v0 - 1, guess right; 0, guess wrong
# --------------------------------------------------------------------------------
user_guess:
	sub	$sp, $sp, 4
	sw 	$ra, ($sp)

	sub 	$sp, $sp, 4
	sw 	$a0, ($sp)		# save $a0

	la	$a1, guess_tail		# set round number, and show
	add 	$a0, $a0, '1'
	sb 	$a0, ($a1)

	la 	$a0, guess_msg
	li	$v0, 4
	syscall

	la	$a0, input_str		# get user input
	li	$a1, 6
	li	$v0, 8
	syscall

	li 	$t0, 0			# upper user input string
upper_next:
	add 	$t1, $a0, $t0
	lb	$t2, ($t1)
	sub 	$t2, $t2, 0x20
	sb 	$t2, ($t1)
	add 	$t0, $t0, 1
	blt	$t0, 5, upper_next

	la 	$a0, new_line
	li 	$v0, 4
	syscall

	la 	$a0, selected_str
	la 	$a1, input_str
	jal 	match
	beq 	$v0, 1, guess_right	# if all chars match, show win message to user

	la 	$a0, selected_str	# else, show message for each char
	la	$a1, input_str
	li 	$a2, 0
c_next:
	jal	check
	add 	$a2, $a2, 1
	blt	$a2, 5, c_next
	
	li 	$v0, 0
	b 	guess_done

guess_right:
	la 	$a0, win_msg
	li	$v0, 4
	syscall

	li	$v0, 1
guess_done:
	lw 	$a0, ($sp)		# restore $a0
	add 	$sp, $sp, 4

	lw 	$ra, ($sp)
	add 	$sp, $sp, 4

	jr	$ra

# --------------------------------------------------------------------------------
# Check whether 2 strings are match.
#
# input :
# $a0 - selected_str
# $a1 - input_str 
#
# output:
# $v0 - 1, match; 0, not match 
# --------------------------------------------------------------------------------
match:
	sub	$sp, $sp, 4
	sw 	$ra, ($sp)

	sub	$sp, $sp, 4
	sw 	$a0, ($sp)

	sub	$sp, $sp, 4
	sw 	$a1, ($sp)

match_next:
	lb	$t0, ($a0) 	
	lb 	$t1, ($a1)
	beq	$t0, 0, match_yes
	bne	$t0, $t1, match_no
	add 	$a0, $a0, 1
	add	$a1, $a1, 1
	b 	match_next

match_no:
	li 	$v0, 0
	b 	match_done
match_yes:
	li 	$v0, 1
match_done:
	lw 	$a1, ($sp)
	add 	$sp, $sp, 4

	lw 	$a0, ($sp)
	add 	$sp, $sp, 4

	lw 	$ra, ($sp)
	add 	$sp, $sp, 4
	jr	$ra


# --------------------------------------------------------------------------------
# Check whether a char in right place of the string, or in wrong place, or not.
#
# input :
# $a0 - selected_str
# $a1 - input_str 
# $a2 - check index
#
# output:
# not used now, $v0 - 0, right place; 1, exists but wrong place; 2, not exists
# --------------------------------------------------------------------------------
check:
	sub	$sp, $sp, 4
	sw 	$ra, ($sp)

	sub	$sp, $sp, 4
	sw 	$a0, ($sp)

	sub	$sp, $sp, 4
	sw 	$a1, ($sp)

	sub	$sp, $sp, 4
	sw 	$a2, ($sp)		# save used registers

	add 	$t0, $a0, $a2
	lb	$t1, ($t0)
	add 	$t2, $a1, $a2
	lb 	$t3, ($t2)		# $t3 holds user inputed char in specified index
	beq	$t1, $t3, check_right

	add 	$t0, $a0, 0
	add 	$t1, $t0, 5
check_next:
	bgt	$t0, $t1, check_else

	lb 	$t2, ($t0)
	beq	$t2, $t3, check_wrong	

	add 	$t0, $t0, 1
	b 	check_next

check_right:
	la 	$a0, right_place
	sb 	$t3, ($a0)
	li	$v0, 4
	syscall
	b 	check_done
check_wrong:
	la 	$a0, wrong_place
	sb 	$t3, ($a0)
	li	$v0, 4
	syscall
	b 	check_done
check_else:
	li 	$v0, 2
check_done:
	lw 	$a2, ($sp)		# restore registers
	add 	$sp, $sp, 4

	lw 	$a1, ($sp)
	add 	$sp, $sp, 4
	
	lw 	$a0, ($sp)
	add 	$sp, $sp, 4
	
	lw 	$ra, ($sp)
	add 	$sp, $sp, 4
	jr	$ra

