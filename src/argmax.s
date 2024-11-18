.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1
    
loop_start:
    addi a0, a0, 4        # Move the pointer to the next element in the array
    bge t2, a1, done      # If the index t2 reaches the array length, exit the loop
    lw t3, 0(a0)          # Load the current element of the array into t3

    bge t3, t0, update_max # If current element t3 is >= max value (t0), update max value

next_element:
    addi t2, t2, 1        # Increment the index
    j loop_start          # Continue to the next element

update_max:
    addi t0, t3, 0        # Update max value to current element (t3)
    addi t1, t2, 0        # Update the index of the max value
    j next_element        # Continue to the next element

done:
    addi a0, t1, 0        # Return the index of the first maximum element
    jr ra                 # Return from function

handle_error:
    li a0, 36
    j exit
