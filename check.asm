.data 
# Board Position Data
Valid_Cards: .asciiz "11", "12", "13", "14",   # Row 1 positions
                     "21", "22", "23", "24",    # Row 2 positions
                     "31", "32", "33", "34",    # Row 3 positions
                     "41", "42", "43", "44"     # Row 4 positions
ListLength:  .word 16                          # Total valid positions

.text
# Main Position Validation Function
.globl card_validate_position
card_validate_position:
    # Stack frame setup
    addi $sp, $sp, -20     # Space for 5 registers
    sw   $ra, 16($sp)      # Return address
    sw   $s1, 12($sp)      # Input string
    sw   $s2, 8($sp)       # Valid_Cards base
    sw   $s3, 4($sp)       # List length
    sw   $s4, 0($sp)       # Loop counter
    
    # Initialize validation parameters
    move $s1, $a0          # Store input position
    la   $s2, Valid_Cards  # Load valid positions array
    lw   $s3, ListLength   # Load total positions count
    li   $s4, 0            # Initialize counter
    
validation_loop:
    # Check for end of validation
    beq  $s4, $s3, invalid_position
    
    # Setup comparison parameters
    move $a0, $s1          # Input position
    move $a1, $s2          # Current valid position
    
    # Compare positions
    jal  compare_positions
    
    # Process comparison result
    beq  $v0, 1, valid_position    # Match found
    addi $s2, $s2, 3              # Next position (3 bytes per entry)
    addi $s4, $s4, 1              # Increment counter
    j    validation_loop
    
invalid_position:
    li   $v0, 0            # Invalid position result
    j    cleanup
    
valid_position:
    li   $v0, 1            # Valid position result
    
cleanup:
    # Restore registers
    lw   $s4, 0($sp)
    lw   $s3, 4($sp)
    lw   $s2, 8($sp)
    lw   $s1, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20      # Restore stack
    jr   $ra               # Return

# Position Comparison Function
compare_positions:
    # Stack setup
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    # Compare first digits
    lb   $t0, 0($a0)       # Input first digit
    lb   $t1, 0($a1)       # Valid first digit
    bne  $t0, $t1, not_matching
    
    # Compare second digits
    lb   $t0, 1($a0)       # Input second digit
    lb   $t1, 1($a1)       # Valid second digit
    bne  $t0, $t1, not_matching
    
    # Positions match
    li   $v0, 1
    j    finish_comparison
    
not_matching:
    li   $v0, 0            # Positions differ
    
finish_comparison:
    # Restore and return
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra