# Data section: Stores game messages and input buffers
.data
game_welcome: 		.asciiz 	"Welcome to Math-Match Game: Multiply Easy\n"
game_instructions: 	.asciiz 	"Try to match two cards by flipping the cards and complete the board to win the game. Good luck and Enjoy!\n"
game_win_message: 	.asciiz 	"Congratulations! You've completed the board. Thank you for playing the game!\n"
bufffer_input1: 	.space 16    	# Buffer for storing first card selection
bufffer_input2: 	.space 16    	# Buffer for storing second card selection

# Text section: Contains the main game logic
.text
.globl game_initialize
.globl game_handle_victory

game_initialize:
    	# Display initial welcome message to the player
    	li $v0, 4
    	la $a0, game_welcome
    	syscall
    	
    	# Insert line break for better formatting
    	li $v0, 4
    	la $a0, newLine
    	syscall
    	
    	# Show game instructions to the player
    	li $v0, 4
    	la $a0, game_instructions
    	syscall
    	
    	# Insert line break for better formatting
    	li $v0, 4
    	la $a0, newLine
    	syscall
    	
    	# Initialize and display the empty game board
    	jal initialize_board 
    	
    	# Insert line break for better formatting
    	li $v0, 4
    	la $a0, newLine
    	syscall
    	
    	# Initialize both current guesses to -1 (indicating no selection)
    	li $t0, -1
    	sw $t0, current_guess1
    	sw $t0, current_guess2
	
	# Start the main game loop
	jal gameLoop

game_handle_victory:
	# Insert double line break for victory message formatting
	li $v0, 4
    	la $a0, newLine
    	syscall
	
	li $v0, 4
    	la $a0, newLine
    	syscall
    	
    	# Display victory message to the player
	li $v0, 4
	la $a0, game_win_message
	syscall 
	lw $ra, 16($sp)           # Restore $ra
    	lw $t0, 12($sp)           # Restore $t0
    	lw $t1, 8($sp)            # Restore $t1
    	lw $t2, 4($sp)            # Restore $t2
    	lw $t3, 0($sp)            # Restore $t3
    	addi $sp, $sp, 20         # Deallocate stack space
	j game_terminate

game_terminate:
	# Exit the program with system call 10
	li $v0, 10
	syscall
