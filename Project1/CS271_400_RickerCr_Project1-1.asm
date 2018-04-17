TITLE Basic Mathematics in Assembly     (project1.asm)

; Author: Craig Ricker
; Last Modified: April 13, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 1                Due Date: April 15, 2018
; Description:
; This program will prompt the user to enter two integers
; Basic mathematical operations will then be performed
; The numbers will be stored and not just displayed to the user

INCLUDE Irvine32.inc


.data
; Text to display to user
intro0		BYTE	"My name is Craig Ricker, this is 'Basic Mathematics in Assembly'. ", 0
intro1		BYTE	"This will prompt you to enter two integers. ", 0
intro2		BYTE	"Type in your number, and hit enter. Ensure the left hand number is larger than the right. To break the loop, hit Control-C", 0
intPrompt1	BYTE	"Enter an integer for the left hand operand: ",0
intPrompt2	BYTE	"Enter an integer for the right hand operand: ",0
goodBye		BYTE	"Good bye!",0
calcIntro	BYTE	"Using your two numbers, the below was calculated",0
remText		BYTE	"Remainder: ", 0
sumText		BYTE	"Sum: ", 0
diffText	BYTE	"Difference: ",0
prodText	BYTE	"Product: ", 0
quotText	BYTE	"Quotient: ",0
ec1			BYTE	"Extra credit #1: the program repeats until user kills it", 0
ec2			BYTE	"Extra credit #2: program verifies LHS > RHS",0


; Container for calculated values
userInt1	DWORD	?		; Integer to be entered by user
userInt2	DWORD	?		; Integer to be entered by user
calcSum		DWORD	?		; Sum of adding two numbers
calcDiff	DWORD	?		; Diff of the two numbers
calcProd	DWORD	?		; Product of the two numbers
calcQuot	DWORD	?		; Quotient of two numbers
calcRem		DWORD	?		; Remainder of two numbers



.code
main PROC




; Let grader know I have completed extra credit
	mov		edx, OFFSET ec1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec2
	call	WriteString
	call	CrLf


; In this section it will write my name and program title
	mov		edx, OFFSET intro0
	call	WriteString
	mov		edx, OFFSET intro1
	call	WriteString

; Break up text slightly. Don't need to repeatedly intro my name
dataEntry:
	mov		edx, OFFSET intro2
	call	WriteString
	call	CrLf

; Display instructions to the user
; Prompt user to enter two numbers, store these
; First integer
	mov		edx, OFFSET intPrompt1
	call	WriteString
	call	ReadInt
	mov		userInt1, eax
; Second integer
	mov		edx, OFFSET intPrompt2
	call	WriteString
	call	ReadInt
	mov		userInt2, eax


; Validate that the first number is larger than the second
; If LHS is < RHS jump back and enter new numbers
	mov		edx, userInt1
	mov		eax, userInt2
	cmp		edx, eax 
	jb		dataEntry






; Calculate sum, diff, product, quotient, and remainder
; Move numbers to EAX and EBX, perform operations
; Sum
	mov		eax, userInt1
	mov		ebx, userInt2
	add		eax, ebx
	mov		calcSum, eax
; Difference
	mov		eax, userInt1
	mov		ebx, userInt2
	sub		eax, ebx
	mov		calcDiff, eax
; Product
	mov		eax, userInt1
	mov		ebx, userInt2
	mul		ebx
	mov		calcProd, eax
; Quotient and remainder
	mov		eax, userInt1
	mov		ebx, userInt2
	div		ebx
	mov		calcQuot, eax
	mov		calcRem, edx




; Display the calculated values
; Explain what is to be printed
	mov		edx, OFFSET calcIntro
	call	WriteString
	call	CrLf
; Sum
	mov		edx, OFFSET sumText
	call	WriteString
	mov		eax, calcSum
	call	WriteDec
	call	CrLf
; Difference
	mov		edx, OFFSET diffText
	call	WriteString
	mov		eax, calcDiff
	call	WriteDec
	call	CrLf
; Display product
	mov		edx, OFFSET prodText
	call	WriteString
	mov		eax, calcProd
	call	WriteDec
	call	CrLf
; Display quotient
	mov		edx, OFFSET quotText
	call	WriteString
	mov		eax, calcQuot
	call	WriteDec
	call	CrLf
; Display remainder
	mov		edx, OFFSET remText
	call	WriteString
	mov		eax, calcRem
	call	WriteDec
	call	CrLf


; Go back to the begining, allow user to enter new numbers
dec cx
jne dataEntry


; Say goodbye and exit program
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP


END main
