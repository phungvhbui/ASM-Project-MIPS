.data
array: .word 10, 80, 30, 90, 40, 50, 70 # Array(temp) _ TODO: readfile
endline: .ascii "\n"
.text # Start code section
.globl main

main:
	la $t0, array
# Initialize arguments	
	add $a0, $t0, 0		# array address
	add $a1, $zero, 0	# low = 0
	add $a2, $a2, 6		# high = array_size 
	
	jal print		# Before
	
	jal QuickSort		# Call QuickSort function
	
	jal print		# After
	
	j exit			# End program

# Swap: swap(int *array, int x, int y)
swap:
	add $sp, $sp, -20	# Initialize stack to save arguments
	sw $a0, 0($sp)		
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	
	sll $t0, $a1, 2		# t0 = x * 4
	add $t0, $a0, $t0	# t0 = array + 4*x
	lw $s0, 0($t0)		# s0 = &array[x]

	sll $t1, $a2, 2		# t1 = y * 4
	add $t1, $a0, $t1	# t1 = array + 4*y
	lw $s1, 0($t1)  		# s1 = &array[y]

	sw $s0, 0($t1)		# Swap
	sw $s1, 0($t0)
	
	lw $a0, 0($sp)		# Load arguments saved in stack back to register 
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	addi $sp, $sp, 20	# Free stack
	jr $ra			# Jump back to caller

# Partition: partition(int *array, int low, int high)
partition:
	add $sp, $sp, -16	# Initialize stack to save arguments
	sw $a0, 0($sp)		# Store a0
	sw $a1, 4($sp)		# Store a1
	sw $a2, 8($sp)		# Store a2
	sw $ra, 12($sp)		# Store return address
	
	move $s0, $a1		# s0 = low = left
	move $s1, $a2		# s1 = high
	
	move $t5, $s1		# t5 = high: save pivot index
	
	sll $t0, $s1, 2		# t0 = 4 * high
	add $t0, $a0, $t0	# t0 = array + 4*high
	lw $s3, 0($t0)		# s3 = arr[high] (pivot)

	subi $s1, $s1, 1		# s1 = high - 1 = right

	BigLoop:
		# while(left <= right && arr[left] < pivot) left++;
		LeftLoop:
			sll $t1, $s0, 2		# t1 = left * 4
			add $t1, $a0, $t1	# t1 = array + 4*left
			lw $t2, 0($t1)		# t2 = &array[left]
			
			# Check left <= right
			bgt $s0, $s1, LeftLoopDone 
			#Check arr[left] < pivot
			bge $t2, $s3, LeftLoopDone			
			
			#left++
			addi	$s0, $s0, 1
			
			j LeftLoop
		
		LeftLoopDone:
		
		# while(right >= left && arr[right] > pivot) right--; 
		RightLoop:
			sll $t3, $s1, 2		# t3 = right * 4
			add $t3, $a0, $t3	# t3 = array + 4*right
			lw $t4, 0($t3)		# t4 = &array[right]
			
			# Check right >= left
			bgt $s0, $s1, RightLoopDone 
			#Check arr[right] > pivot
			ble $t4, $s3, RightLoopDone		
			
			#right--
			subi	$s1, $s1, 1
			
			j RightLoop
		
		RightLoopDone:
		
		#if (left >= right) break;	
		bge $s0, $s1, BreakLoop
		
		move $a1, $s0	
		move $a2, $s1
		jal swap			# swap(a[left], a[right])
		addi $s0, $s0, 1		# left++
		subi $s1, $s1, 1		# right--
		j  BigLoop
	
	BreakLoop:
		move $a1, $s0
		move $a2, $t5
		jal swap			# swap(a[left], pivot)
		add $v0, $s0, 0		# Return left
	
		lw $a0, 0($sp)		# Load argurment saved in stack back to register
		lw $a1, 4($sp)
		lw $a2, 8($sp)	
		lw $ra, 12($sp)
		addi $sp, $sp, 16	# Free stack
		jr $ra			# Jump back to caller


# Quick Sort: QuickSort(int *array, int low, int high)
QuickSort:
	add $sp, $sp, -16	# Initialize stack to save arguments
	sw $a0, 0($sp)		# Store a0
	sw $a1, 4($sp)		# Store a1
	sw $a2, 8($sp)		# Store a2
	sw $ra, 12($sp)		# Store return address
	
	bge $a1, $a2, EndQuickSort	# if (left <= right) End QuickSort

	jal partition		# Jump to partition function
	move $s4, $v0		# Return new pivot (p)
	
	lw $a1, 4($sp)		# a1 = low	
	subi $a2, $s4, 1		# a2 = p - 1 
	jal QuickSort		# Call QuickSort

	addi $a1, $s4, 1		# a1 = p + 1
	lw $a2, 8($sp)		# a2 = high
	jal QuickSort		# Call QuickSort
	
	EndQuickSort:
		lw $a0, 0($sp)	# Load argurment saved in stack back to register 
		lw $a1, 4($sp)	
		lw $a2, 8($sp)		
		lw $ra, 12($sp)	
		addi $sp, $sp, 16	# Free stack
		jr $ra		# Jump back to caller
	
print:
	add $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $t0, 12($sp)
	
	add $t1, $zero, 0
	move $t0, $a0
loop:
	bge $t1, 7, exitprint

# load word from addrs and goes to the next addrs
   	lw $t2, 0($t0)
    	addi $t0, $t0, 4

# syscall to print value
	li $v0, 1
    	move $a0, $t2
    	syscall
# optional - syscall number for printing character (space)
    	li $a0, 32
   	li $v0, 11  
    	syscall


#increment counter
	addi $t1, $t1, 1
    	j loop

exitprint:
	addi $v0, $0, 4
	la $a0, endline
	syscall
	
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $t0, 12($sp)
	add $sp, $sp, 16
	jr $ra
	
exit:
	add $v0, $zero, 10
