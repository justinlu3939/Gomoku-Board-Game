.data
####################################################
#       Variables for printing out the board       #
####################################################
matrix: .word '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
sideNums: .asciiz " 1", " 2", " 3", " 4", " 5", " 6", " 7", " 8", " 9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"

topLetters: .asciiz "   A B C D E F G H I J K L M N O P Q R S"
space: .asciiz " "
newLine: .byte '\n'
rowCount: .word 1

offset: .word 0 #offset of 476, therefore in row 7 col 6, formula for offset: (col-1)*4 + (row-1)*76

playerB: .asciiz "*"
playerE: .asciiz "X" #we don't need this variable but without it the code doesn't work
playerW: .asciiz "0"

win: .word 0 # 0=false, 1=true

period: .word '.'

####################################################
#               Variables for input                #
####################################################
letter: .asciiz ""
letterNum: .word 0
number: .word 0
lowerAValue: .word 'a'
subValue: .word 32
upperAValue: .word 'A'

randomVal: .word 0

validNum: .word 0
isValid: .word 1

inputPrompt: .asciiz "Move?\t"
invalidPrompt: .asciiz "Invalid move\n"

counter: .word 0

WinnerText: .asciiz "the winner is: "

.text
.globl main
main:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	la $s0, matrix
	jal printMatrix #print out the matrix
	
restart:
	userInputNotValid:
	jal getInput #USER INPUT
	jal checkValid
	lw $t5, isValid
	bne $t5, $zero, userInputValid #checks if user input is valid
	li $v0, 4
	la $a0, invalidPrompt #prints out an invalid prompt if value is invalid
	syscall
	j userInputNotValid
	
	userInputValid:
	lw $t7, playerB  #playerB will add a "*", playerW will add a "0"
	lw $t9, offset #load the offset into a register
	la $t8, matrix($t9) #load the element in the matrix with the correct offset
	sw $t7, 0($t8) #save the player element in the array slot
	
	compInputNotValid:
	jal generateNumber #COMPUTER INPUT
	jal checkValid
	lw $t5, isValid
	beqz $t5, compInputNotValid #checks if the computer offset is valid, if not, get new value
	
	lw $t3, playerW
	lw $t2, randomVal
	la $t4, matrix($t2) #load the element in the matrix with the correct offset
	sw $t3, 0($t4)

	jal printMatrix #print out the matrix
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jal checkWinner
	lw $t1, win
	beq $t1, $zero, restart #checks if the win condition is met, jump to restart
	
	j exit

	
			
printMatrix:
	la $s5, sideNums
	li $s1, 1	#row index, every 4 bytes
	li $s2, 1	#column index, every 76 bytes
	li $t6, 19	#load number of rows and columns
	
	li $v0, 4
	la $a0, topLetters #print out the letters on the top of the board
	syscall
	li $v0, 11
	lb $a0, newLine #print out a new line
	syscall
	li $v0, 4
	la $a0, 0($s5) #print out the first number on the side
	syscall
	li $v0, 4
	la $a0, space #print out a space (" ")
	syscall

printRow:
	addiu $t1, $s1, -1
	addiu $t2, $s2, -1
	li $t4, 76
	li $t5, 4
	mul $t1, $t1, $t4    #these lines are to calculate the offset in the array for the next element
	mul $t2, $t2, $t5
	add $s4, $s0, $t1
	add $s4, $s4, $t2
	li $v0, 11
	lw $a0, 0($s4) #prints out this element
	syscall
	
	li $v0, 4
	la $a0, space #prints out a space between each element
	syscall
	li $t6, 19
	div $s2, $t6
	mfhi $t6
	beqz $t6, endRow #if $t6 = 0, branch to endRow
	addiu $s2, $s2, 1 
	addi $t7, $t7, 1
	sw $t7, rowCount
	j printRow
	
endRow:
	li $s2, 1
	li $v0, 11
	lb $a0, newLine #print out a new line
	syscall
	li $t6, 19
	div $s1, $t6
	mfhi $t6
	beqz $t6, finishPrint #if there are no more elements, finish printing
	
	addiu $s5, $s5, 3
	li $v0, 4
	la $a0, 0($s5) #print out the next row number
	syscall
	li $v0, 4
	la $a0, space #print out a space
	syscall
	
	addiu $s1, $s1, 1
	j printRow

finishPrint:
	jr $ra



getInput:
	li $v0, 4
	la $a0, inputPrompt
	syscall

	li $v0, 12 #get the letter input
	syscall
	sb $v0, letter #store in letter

	li $v0, 5 #get the number input
	syscall
	sub $v0, $v0, 1
	mul $v0, $v0, 76 #change to the correct offset for rows
	sw $v0, number #store in number
	
	lw $t1, lowerAValue
	lw $t2, letter
	blt $t2, $t1, cont #check if it is a lower case, if is branch to cont
	
	lw $t3, subValue 
	sub $t2, $t2, $t3 #subtract the difference between upper case and lower case to get the same value
	sw $t2, letter
	
cont:
	lw $t1, letter
	lw $t2, upperAValue
	sub $t1, $t1, $t2 #subtract 'A' value to make a=0, b=1, c=2, etc.
	mul $t1, $t1, 4 #change offset for columns
	
	lw $t3, number
	add $t1, $t1, $t3 #add the offset of rows and columns to get total offset
	
	sw $t1, offset
	sw $t1, validNum
	jr $ra

		
	
generateNumber:
	li $v0, 42
	li $a1, 360 # this sets the upperboard range in $a1 (1440 is the max bits) (360 bytes)
	syscall # the number will be stored in $a0
	
	sll $a0, $a0, 2
	sw $a0, randomVal #stores the variable in randomVal
	sw $a0, validNum
	jr $ra
	
checkValid:
	addi $t4, $zero, 0
	lw $t1, validNum
	lw $t2, period
	lw $t3, matrix($t1)
	
	beq $t2, $t3, check1 #checks if there is an empty slot
	
	sw $t4, isValid
	jr $ra
	
check1:
	addi $t4, $zero, 1
	sw $t4, isValid
	jr $ra
	
checkWinner:
	move $s7, $ra

	li $a0, 76
	li $a1, 0
	li $a2, 0
	jal checkWinnerInner

	li $a0, 4
	li $a1, 1
	li $a2, 0
	jal checkWinnerInner

	li $a0, 72
	li $a1, 0
	li $a2, 1
	jal checkWinnerInner

	li $a0, 80
	li $a1, 1
	li $a2, 0
	jal checkWinnerInner
	
	lw $t0, win
	bne $t0, 0, printWinner

	move $ra, $s7
	jr $ra

printWinner:
	li $v0, 4
	la $a0, WinnerText
	syscall

	li $v0, 11
	move $a0, $t0 
	syscall

	j exit

checkWinnerInner:
	li $t0, -4 # x, start at -4, cause it will +1 every time 
cWOuter:
	addi $t0, $t0, 4
	bge $t0, 1444, checkWinnerInnerExit # if its out of bounds

	add $t1, $t0, $s0
	lw $t1, 0($t1) # a[x] or v

	beq $t1, '.', cWOuter # if arr[x] == EMPTY

	beq $a1, 0, cWSkipRightCheck # if rightCheck is false, skip it
	rem $t2, $t0, 76
	ble $t2, 56, cWSkipRightCheck # if x % 19 <= 14, skip it

	j cWOuter # continue
cWSkipRightCheck:
	beq $a2, 0 cWSkipLeftCheck # if leftCheck is false, skip it
	rem $t2, $t0, 76
	bge $t2, 16, cWSkipLeftCheck  # or x % 19 > 4

	j cWOuter # continue
cWSkipLeftCheck:
	li $t2, 1
cWLoop5:
	mul $t3, $t2, $a0
	add $t3, $t0, $t3 # offset * i + x
	
	bge $t3, 1444, cWOuter # index >= arr.length

	add $t4, $t3, $s0
	lw $t5, 0($t4)
	bne $t5, $t1, cWOuter # arr[index] != v
	
	addi $t2, $t2, 1
	blt $t2, 5, cWLoop5

	sw $t1, win

checkWinnerInnerExit:
	jr $ra
	

exit:
	li $v0, 10 #exit the program
	syscall
