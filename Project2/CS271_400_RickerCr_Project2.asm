TITLE Fibonacci Fun     (CS271_400_RickerCr_Project2.asm)

; Author: Craig Ricker
; Last Modified: April 22, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 2               Due Date: April 22, 2018
; Description:
; This program will prompt the user to enter their name &  greet them
; The User wiill then input a number, which will be forced to be
; in the range of [1, 46]. The Fibonacci sequence will be calculated
; up to N, where N is the user input
; Display exit message that includes user name, and exit
;
;
; The code will also be broken up into five "sections"
; but these do not *yet* have to be procedures






INCLUDE Irvine32.inc



; Constant Definitions
LOWER_LIMIT		= 1					; Input can't be smaller than
UPPER_LIMIT		= 46				; Input can't be larger than
COL_N			= 5					; Number of items to have on a column

.data



; Prompts to be printed out
intro		BYTE	"Fibonacci Fun",0
intro1		BYTE	"Programmed by Craig Ricker",0
userQues	BYTE	"What is your name: ",0
extracredit	BYTE	"Extra Credit #1: I aligned the number outputs",0
userGreet	BYTE	"Well hello ",0
expl		BYTE	"This program will calculate a series of Fibonacci numbers.",0
userRest	BYTE	"The integer must be in the range of [1, 46].",0
userPrompt	BYTE	"Please enter the number of Fibonacci terms to be displayed: ",0
space_sep	BYTE	9,9,0
goodBye		BYTE	"Good bye, ",0

; To handle input data
buffer		BYTE 21 DUP(0)		; input buffer
byteCount	DWORD ?				; holds counter
userInt		DWORD ?				; Number of numbers to print

; To calculate fib sequence
actNum		DWORD ?
tempNum		DWORD ?





.code

main PROC
; Say hello to the user
introduction:
; Print info regarding program and creator
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLf
; Prompt User to enter information, and greet them
	mov		edx, OFFSET userQues
	call	WriteString
; Ask user their name
	mov		edx,OFFSET buffer ; point to the buffer
	mov		ecx,SIZEOF buffer ; specify max characters
	call	ReadString ; input the string
	mov		byteCount,eax ; number of characters
; Greet the user
	mov		edx, OFFSET userGreet
	call	writeString
	mov		edx, offset buffer
	call	WriteString
	call	CrLf

; Print out extra credit statement
	mov		edx, OFFSET extraCredit
	call	WriteString
	call	CrLf

; Tell the user how to use the program
userInstructions:
; Prompt user to input an integer within acceptable range
	mov		edx, OFFSET expl
	call	WriteString
	call	CrLf
getUserData:
	mov		edx, OFFSET userRest
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userPrompt
	call	WriteString
	call	ReadDec
	mov		userInt, eax

; Ensure that the number is a within the acceptable bounds
	mov		eax, userInt
; If smaller than lower limit
	cmp		eax, LOWER_LIMIT
	jl		userInstructions
; Is larger than upper limit, reset
	cmp		eax, UPPER_LIMIT
	jg		 userInstructions


; Need to set the numbers to ensure they are added properly
; Seed fib numbers
	mov		ecx, userInt		; #n to print
	mov		eax, 0				; start out at zero
	mov		ebx, 1				; "Next" number is 1
	mov		edx, COL_N			; Number of elements per line



; This section will calculate and print the current fib number
displayFibs:
	mov		actNum, eax
	add		eax, ebx
	call	WriteDec
; Decrease edx, to ensure you print new line
	dec		edx
	jnz		formatRow

; Print new line when appropriate, go to "inner" loop
newLine:
	call	CrLf
	mov		edx, COL_N
	jmp		resetFibLoop

; Handle if a new line needs to be printed or not
formatRow:
	cmp		ecx, 1
	je		newLine
	mov		tempNum, edx		; Store current edx number for later
	mov		edx, OFFSET space_sep
	call	WriteString
	mov		edx, tempNum

; Loop control for outer loop
; If ecx (the number of fib numbers) = 0 exit
; This works because ecx controls loop in MASM
; At end of loop command, decrease ecx by 1
resetFibLoop:
	mov		ebx, actNum
	loop	displayFibs


; Say good by to the user, and exit porgram
farewell:
	mov		edx, OFFSET goodBye
	call	WriteString
	mov		edx, OFFSET buffer
	call	WriteString
	call	CrLf





	exit	; exit to operating system
main ENDP


END main
