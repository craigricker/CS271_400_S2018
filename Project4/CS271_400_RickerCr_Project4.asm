TITLE  Crazy Composite Calculation (CS271_400_RickerCr_Project4.asm)

; Author: Craig Ricker
; Last Modified: May 2, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 3               Due Date: May 6, 2018
; Description:
; This program will repeatedly prompt the user to enter a number
; If it is a negative number [-100, -1], accept number
; If smaller than -100, throw out number and repeat prompt
; If positive number entered, exit loop, and display average

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

intro		BYTE	"Welcome to 'Crazy Composite Calculation'",0
intro1		BYTE	"Programmed by Craig Ricker",0
userQues	BYTE	"What is your name: ",0
userGreet	BYTE	"Well hello ",0
expl1		BYTE	"Enter the number of compositve numbers you would like to see",0
expl2		BYTE	"Be reasonable...lets say any integer [1, 400]",0
enterNumb	BYTE	"Enter an integer between [1,400]:",0
noInput		BYTE	"No negative numbers entered.", 0
calcCount	BYTE	"Number of valid numbers		: ",0
calcSum		BYTE	"Sum of valid numbers		: ",0
calcAvg		BYTE	"Average of valid numbers	: ",0
goodBye		BYTE	"Good bye, I hope you had fun ",0
buffer		BYTE 21 DUP(0)						; input buffer

inputNumb	DWORD ?								; Input number
.code

;-------------------------------------------------------------------------------
introduction PROC
; Description:	Simple function that tells the user the name of program, who
;				designed it, asks for their name and greets them.
; Input:		No input is required
; Output:		No output is created
; Registers:	No register modification takes place - saved and restore in PROC
;--------
;-------------------------------------------------------------------------------
	mov		edx, OFFSET intro					; Print program info
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userQues				; Ask the user their name
	call	WriteString

	mov		edx,OFFSET buffer					; point to the buffer
	mov		ecx,SIZEOF buffer					; specify max characters
	call	ReadString							; input the string


	mov		edx, OFFSET userGreet				; Greet user by name
	call	writeString
	mov		edx, offset buffer
	call	WriteString
	call	CrLf

	mov		edx, OFFSET expl1					; Explain program
	call	WriteString
	call	CrLf
	mov		edx, OFFSET expl2
	call	WriteString
	call	CrLf

	ret
introduction ENDP


;-------------------------------------------------------------------------------
getUserData PROC
; Description:	Prints a prompt that requests users to pick an int in between
;				an upper and a lower bound. Reprompt until satisfied
;
; Input:		prompt		text to explain input requrements
;				lowerlimit	smallest acceptable int
;				upperlimit	largest acceptable int
; Output:		number selected by user
; Registers:	eax and edx are modified
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			prompt to print
;				[ebp + 12]			lower limit
;				[ebp + 16]			upper limit
;				[ebp + 20]			return value
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	EntryLoop:
	mov		edx, [ebp + 8]						; Print prompt from stack
	call	WriteString
	call	ReadInt								; Read in number
	mov		[ebp +20], eax						; Store number

	cmp		[ebp +20], [ebp + 16]
	jg		EntryLoop							; Too big
	cmp		eax, [ebp + 12]
	jl		EntryLoop							; Too small


	pop		ebp
	ret		16									; Return 16, pushed 4 values
getUserData ENDP

;-------------------------------------------------------------------------------
validateInput PROC
; Description:	Prints a prompt that requests users to pick an int in between
;				an upper and a lower bound. Reprompt until satisfied
;
; Input:		prompt		text to explain input requrements
;				lowerlimit	smallest acceptable int
;				upperlimit	largest acceptable int
; Output:		number selected by user
; Registers:	eax and edx are modified
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			prompt to print
;				[ebp + 12]			lower limit
;				[ebp + 16]			upper limit
;				[ebp + 20]			return value
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp


validateInput ENDP



main PROC
	call	introduction
	push	OFFSET inputNumb					; Location to store input number
	push	400									; Upper limit
	push	1									; Lower limit
	push	OFFSET enterNumb					; Explanation of input req
	call	getUserData
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
