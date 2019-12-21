.data
arraynum:	.asciiz "Nhap so phan tu cua Array : \n"
array:		.asciiz "Nhap phan tu cua Array : \n"
request1:	.asciiz "\n1. Xuat ra cac phan tu : \n"
request1_out:	.asciiz "\nMang :\n"
request2:	.asciiz "2. Tinh tong so phan tu :\n"
request2_out:	.asciiz "\nTong cac phan tu trong mang :\n"
request3:	.asciiz "3. Liet ke cac phan tu la so nguyen to :\n"
request3_out:	.asciiz "\nCac phan tu la so nguyen to: \n"
request4:	.asciiz "4. Tim max :\n"
request4_out:	.asciiz "\nPhan tu max :\n"
request5:	.asciiz "5. Tim phan tu co gia tri x trong mang :\n"
request5_in:	.asciiz "\nNhap phan tu x muon tim kiem :\n"
request5_out:	.asciiz "\nIndex cua x : \n"
request6:	.asciiz "6. Thoat chuong trinh : \n"
request:	.asciiz "Yeu cau : \n"
space:		.asciiz " "
.text

main:

#Input array
#Nhap so phan tu cua Array
input_num_array:	
	addi $v0,$0,4
	la $a0,arraynum
	syscall
	
	addi $v0,$0,5
	syscall
	add $t0, $0 ,$v0
	blez $t0,input_num_array
	
	move $s0,$sp
	
#Nhap tung phan tu cua Array
input_array:
	addi $s1,$s1,1
	
	addi $v0,$0,4
	la $a0,array
	syscall
	
	addi $v0,$0,5
	syscall
	add $t1, $0 ,$v0
	sw $t1,($sp)
	addi $sp,$sp,-4
	
	bne $s1,$t0,input_array

#print request
#In ra Menu
print_request:
	addi $v0,$0,4
	la $a0,request1
	syscall
	
	addi $v0,$0,4
	la $a0,request2
	syscall

	addi $v0,$0,4
	la $a0,request3
	syscall

	addi $v0,$0,4
	la $a0,request4
	syscall

	addi $v0,$0,4
	la $a0,request5
	syscall

	addi $v0,$0,4
	la $a0,request6
	syscall
	
	addi $v0,$0,4
	la $a0,request
	syscall
	
#read request
#Doc yeu cau cua nguoi dung, va thuc hien yeu cau do
	addi $v0,$0,5
	syscall
	add $s2, $0 ,$v0
	
	move $sp,$s0
	addi $s1,$0,0
	beq $s2,1,func_request1
	beq $s2,2,func_request2
	beq $s2,3,func_request3
	beq $s2,4,func_request4
	beq $s2,5,func_request5
	beq $s2,6,func_request6

#Yeu cau 1:
func_request1:
	addi $v0,$0,4
	la $a0,request1_out
	syscall
#Thuc hien vong lap in ra toan bo phan tu
loop7:
	addi $s1,$s1,1
	
	lw $t1,($sp)
	
	addi $v0,$0,1
	move $a0,$t1
	syscall
	
	addi $v0,$0,4
	la $a0,space
	syscall
	
	addi $sp,$sp,-4
	
	bne $s1,$t0,loop7
	j print_request
	
#Yeu cau 2:		
func_request2:
	addi $v0,$0,4
	la $a0,request2_out
	syscall
#Thuc hien viec duyet qua toan bo phan tu trong mang va tinh tong
loop6:
	addi $s1,$s1,1
	
	lw $t2,($sp)
	add $t3,$t3,$t2
	
	addi $sp,$sp,-4
	
	bne $s1,$t0,loop6
	
	addi $v0,$0,1
	move $a0,$t3
	syscall
	
	j print_request
	
#Yeu cau 3:
func_request3:
	addi $v0,$0,4
	la $a0,request3_out
	syscall
#Duyet toan bo phan tu trong mang
loop2:
	addi $s1,$s1,1
	
	lw $t2,($sp)
	sub $t7,$t2,1
	addi $t3,$0,1
#Kiem tra mot phan tu co phai so nguyen to hay khong
is_prime:
	beq $t2,2,output_prime
	blt $t2,2,continue
	addi $t3,$t3,1	
	rem $t6,$t2,$t3
	beqz $t6,continue
	bne $t3,$t7,is_prime
	j output_prime
#Thuc hien viec duyet qua phan tu tiep theo neu phan tu khong thoa dieu kien
continue:
	addi $sp,$sp,-4
	
	bne $s1,$t0,loop2
	j print_request	
#Xuat ra cac gia tri la so nguyen to
output_prime:
	addi $v0,$0,1
	move $a0,$t2
	syscall
	
	addi $v0,$0,4
	la $a0,space
	syscall
	
	j continue

#Yeu cau 4:
func_request4:
	addi $v0,$0,4
	la $a0,request4_out
	syscall
	lw $t5,($sp)
	
loop:
	
	lw $t4,($sp)
	
	blt  $t5,$t4,assignment
loop1:	
	addi $s1,$s1,1
	addi $sp,$sp,-4
	
	bne $s1,$t0,loop	
	addi $v0,$0,1
	move $a0,$t5
	syscall
	
	j print_request
	
assignment:
	add $t5,$0,$t4
	j loop1
	
#Yeu cau 5:
func_request5:
	addi $v0,$0,4
	la $a0,request5_in
	syscall
	
	addi $v0,$0,5
	syscall
	add $s3, $0 ,$v0
	addi $s1,$s1,-1
	
loop5:
	addi $s1,$s1,1
	lw $t5,($sp)
		
	addi $sp,$sp,-4
	
	bne $t5,$s3,loop5
	
	addi $v0,$0,4
	la $a0,request5_out
	syscall
	
	addi $v0,$0,1
	move $a0,$s1
	syscall
		
	j print_request
	
#Yeu cau 6:
func_request6:
	li $v0,10
	syscall 

	
