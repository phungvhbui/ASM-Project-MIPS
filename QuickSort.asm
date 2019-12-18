.data	# Declare variables
fin: 		.asciiz "E:/Github/KTMTHN-MIPS/input.txt"
fout: 		.asciiz "E:/Github/KTMTHN-MIPS/output.txt"
buffer:		.space 1024

.text	# Start code section
.globl main

main:
	jal ReadFile
	
# Initialize arguments	
	add $a0, $t0, 0		# array address
	add $a1, $zero, 0	# low = 0
	add $a2, $s1, 0		# array_size 
	
	subi $a2, $a2, 1		# high = array_size - 1
	
	jal QuickSort		# Call QuickSort function
	
	addi $a2, $a2, 1		# array_size
	
	jal WriteFile
	
	j exitProgram			# End program
	
#****************************************** ReadFile Implementation ******************************************# 
ReadFile:
	add $s7, $ra, 0
# Open file
	li $v0, 13		# System call: 13 = open file
	la $a0, fin		# a0 = name of file to read
	add $a1, $0, $0		# a1: open mode: 0 = read
	add $a2, $0, $0		# a2: ignore mode = 0
	syscall			# Open File, $v0<-fd (file descriptor)
	add $s0, $v0, $0		# Store fd in $s0
	
	
	li $t1, 0		# Initialize "count" variable
	li $t2, 1		# Initialize "base" variable
	li $t3, 0		# Initialize "sum" variable
	
	add $t9, $0, 1
	jal ReadNumberOfElements
	move $s1, $v0		# s1 = v0 = number of elements
	
	addi $t9, $t9, 1
	jal ReadElements
	la $t0, ($sp)		# t0 = v0 = array
	
# Close file
	li 	$v0, 16 		# System call: 16 = open file 
 	move 	$a0, $s0		# Copy file descriptor to argument
 	syscall 			# Close file
	
	add $ra, $s7, 0
	jr $ra

ReadNumber:
	li $v0, 14 		# System call: 14 = read from file
 	move $a0, $s0 		# Copy file descriptor to argument
 	la $a1, buffer		# Address of buffer from which to read
 	li $a2, 1		# Buffer length			
 	syscall 			# Read from file
 	
 	lb $t0, buffer
 	
 	beq $v0, $0, ReturnNumber
 	beq $t0, 10, ReadNumber		# '\n'
 	beq $t0, 13, ReturnNumber	# '\r'
 	beq $t0, 32, ReturnNumber	# ' '
 	
 	addi $t0, $t0, -48		
	addi $sp, $sp, -1	
	sb $t0, ($sp)
	
	addi $t1, $t1, 1
	
	j ReadNumber

ReadNumberOfElements:
	j ReadNumber
	
	ReadNumberOfElementsDone:
		jr $ra
		
ReadElements:
	add $t8, $s1, 0
	
	ForLoop:
		beq $t8, $0, ReadElementsDone
		j ReadNumber
		
		ContinueLoop:
			sw $v0, ($sp)
			subi $t8, $t8, 1
			j ForLoop
			
	ReadElementsDone:
		jr $ra
		
ReturnNumber:
	lb $t0, ($sp)
	addi $sp, $sp, 1

	mult	$t0, $t2			# Multiple digit by base
	mflo	$t0

	add	$t3, $t3, $t0		# Sum up all digits to create the number
	
	addi	$t1, $t1, -1		# Decrease the "count" variable

	mul	$t2, $t2, 10		# Increase the position of digit
	mflo	$t2

	bne $t1, $0, ReturnNumber

	addi	$sp, $sp, -4		# Set $sp to proper position
	move	$v0, $t3
	
	# Restore all temporary registers
	li	$t1, 0			# Reset "count" to 0
	li	$t2, 1			# Reset "base" to 1
	li	$t3, 0			# Reset "sum" to 0
	
	beq $t9, 1, ReadNumberOfElementsDone
	beq $t9, 2, ContinueLoop

#****************************************** WriteFile Implementation ******************************************#
WriteFile:
	add $sp, $sp, -12
	sw $a0, 0($sp)
	sw $a2, 4($sp)
	sw $ra, 8($sp)
	
# Open file
	li $v0, 13		# System call: 13 = open file
	la $a0, fout		# a0 = name of file to write
	addi $a1, $0, 1		# a1: open mode: 1 = write
	add $a2, $0, $0		# a2: ignore mode = 0
	syscall			# Open File, $v0<-fd (file descriptor)
	add $s2, $v0, $0		# Store fd in $s2

# Print 
	add $t1, $0, 0		# t1 = i = 0
	LoopPrint:
		lw $a2, 4($sp)
		lw $a0, 0($sp)
		
		beq $t1, $a2, EndPrint	# if (i == array_size) break; 
		
		sll $t2, $t1, 2		# t2 = i * 4
		add $t2, $a0, $t2	# t2 = array + 4*i
		lw $s3, 0($t2)		# s3 = &array[i]
		
		la $t3, buffer
		add $t4, $0, $0		# t4: number of digits
		
		jal IntToString
		
		add $t1, $t1, 1
		
		# Print number to file
		li $v0, 15   			# System call for write to file
		move $a0, $s2    		# File descriptor 
		move $a1, $t3   			# Address of buffer from which to write
		li $a2, 0
		add $a2, $a2, $t4       		# Buffer length
		syscall 				# Write to file
		
		j LoopPrint	
		
IntToString:
	sub $t3, $t3, 1
	
	add $t5, $0, 10
	div $s3, $t5
	mflo $s3				# $t2 holds new value after being divided (Quotient)
	mfhi $t5				# $t5 holds Remainder
	
	add $t5, $t5, '0'		# Change digit into ASCII code
	sb $t5, ($t3)
	
	addi $t4, $t4, 1

	bne $s3, $0, IntToString
	
	beq $t1, 0, IntToStringDone
	
	# Add backspace
	sub $t3, $t3, 1
	add $t5, $0, 32
	sb $t5, ($t3)
	addi $t4, $t4, 1
	
	IntToStringDone:
		jr $ra	

EndPrint:
# Close file
	li 	$v0, 16 		# System call: 16 = open file 
 	move 	$a0, $s0		# Copy file descriptor to argument
 	syscall 			# Close file
 	
	lw $a0, 0($sp)
	lw $a2, 4($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 12
	jr $ra

#****************************************** QuickSort Implementation ******************************************# 
# Swap: swap(int *array, int x, int y)
swap:
	add $sp, $sp, -20	# Initialize stack to save arguments
	sw $a0, 0($sp)		# Store arguments to stack
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
	sw $a0, 0($sp)		# Store arguments to stack
	sw $a1, 4($sp)		
	sw $a2, 8($sp)		
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
	sw $a0, 0($sp)		# Store arguments to stack
	sw $a1, 4($sp)		
	sw $a2, 8($sp)		
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
		lw $a0, 0($sp)		# Load argurment saved in stack back to register 
		lw $a1, 4($sp)	
		lw $a2, 8($sp)		
		lw $ra, 12($sp)	
		addi $sp, $sp, 16	# Free stack
		jr $ra			# Jump back to caller	

#****************************************** End Program Function ******************************************# 
exitProgram:
	li 	$v0, 10
 	syscall
