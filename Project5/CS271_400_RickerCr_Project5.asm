TITLE Pseudo-random Integer Array Filler (CS271_400_RickerCr_Project5.asm)

; Author: Craig Ricker
; Last Modified: May 25, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 5               Due Date: May 27, 2018
; Description:
; This program will repeatedly prompt the user to enter a number
; In the range of [1, 400], check number
; If within range, print out n compositve numbers (non prime)

INCLUDE Irvine32.inc

MIN_REQUEST		= 10							; Smallest array size
MAX_REQUEST		= 200							; Largest input array size
LO_RANGE		= 100							; Smallest generated int
HI_RANGE		= 999							; Largest generated int


.data

intro		BYTE	"Welcome to 'Pseudo-random Integer Array Filler'",0
intro1		BYTE	"Programmed by Craig Ricker",0
userQues	BYTE	"What is your name: ",0
userGreet	BYTE	"Well hello ",0
ec1			BYTE	"Extra Credit #1: output columns are aligned!",0
expl1		BYTE	"You will be prompted to enter an integer for the array size, then it will randomly be filled",0
expl2		BYTE	"Be reasonable...lets say any integer [1, 400]",0
oor			BYTE	"Out of range.",0
enterNumb	BYTE	"Enter an integer between [1,400]:",0
noInput		BYTE	"No negative numbers entered.", 0
calcCount	BYTE	"Number of valid numbers		: ",0
calcSum		BYTE	"Sum of valid numbers		: ",0
calcAvg		BYTE	"Average of valid numbers	: ",0
goodBye		BYTE	"Good bye, I hope you had fun ",0
byeText		BYTE	"Good bye, thank you for playing!",0
buffer		BYTE	21 DUP(0)					; input buffer

inputNumb	DWORD	?							; Input number
counter		DWORD	0							; Count # printed entries
spaceChar	BYTE	9,0							; Spaces to print

userArray	DWORD	MAX_REQUEST		DUP(9)
.code



main PROC
	mov		inputNumb, 12
	push	OFFSET userArray
	push	inputNumb
	call	arrayFill
main ENDP



;-------------------------------------------------------------------------------
arrayFill PROC
; Description:	Fill array with random numbers
; Input:		Input 1: Array memory location
;				Input 2: Array size.
; Output:		No output is created
; Registers:	Use and restore: ebp, edi, ecx & edx
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp +12]
	mov		ecx, [ebp + 8]


	pop		ebp
	ret		8
arrayFill ENDP


;-------------------------------------------------------------------------------
printArray PROC
; Description:	Given an initial offset, and count, print out all items in 
;				input array
; Input:		Input 1: Array memory location
;				Input 2: Array size.
; Output:		No output is created
; Registers:	Use and restore: ebp, edi, ecx & edx
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	; Store registers
	push	edi
	push	ecx
	push	eax

	mov		edi, [ebp + 12]
	mov		ecx, [ebp + 8]
ArrayLoop:
	mov		eax, [edi]
	call	WriteDec
	call	CrLf
	add		edi, 4
	loop	ArrayLoop

	; Restore registers
	pop		eax
	pop		ecx
	pop		edi
	pop		ebp
	ret		4
printArray ENDP

END main
