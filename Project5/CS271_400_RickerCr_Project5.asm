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
MAXSIZE	= 100


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

count		DWORD	10							; Input number
counter		DWORD	0							; Count # printed entries
spaceChar	BYTE	9,0							; Spaces to print
prompt1		BYTE		"How many squares ",0
userArray	DWORD	MAX_REQUEST		DUP(9)
squareArray	DWORD	MAXSIZE DUP(?)
.code


main PROC
	push	OFFSET count
	call	getCount			;Get the user's number
	push	OFFSET squareArray
	push	count
	call	fillArray			;Put that many squares into the array
	push	OFFSET squareArray
	push	count
	;call	showRevList		;Print the array in reverse order
	call	printArray
	exit			;exit to operating system
main ENDP

; ***************************************************************
; Procedure to get the user's input. Note: input not validated.
; receives: address of count on system stack
; returns: user input in global count
; preconditions: none
; registers changed: eax, ebx, edx
; ***************************************************************
getCount	PROC
	push	ebp
	mov	ebp,esp
	mov	edx,OFFSET prompt1
	call	WriteString		;prompt user
	call	ReadInt			;get user's number
	mov	ebx,[ebp+8]		;address of count in ebx
	mov	[ebx],eax			;store in global variable
	pop	ebp
	ret	4
getCount	ENDP

; ***************************************************************
; Procedure to put count squares into the array.
; receives: address of array and value of count on system stack
; returns: first count elements of array contain consecutive squares
; preconditions: count is initialized, 1 <= count <= 100
; registers changed: eax, ebx, ecx, edi
; ***************************************************************
fillArray	PROC
	push	ebp
	mov		ebp,esp
	mov		ecx,[ebp+8]		;count in ecx
	mov		edi,[ebp+12]		;address of array in edi
	
	mov	ebx,0
again:
	mov	eax,ebx			;calculate squares and store in consecutive array elements
	mul	ebx
	mov	[edi],eax
	add	edi,4
	inc	ebx
	loop	again
	
	pop	ebp
	ret	8
fillArray	ENDP

; ***************************************************************
; Procedure to display array in reverse order.
; receives: address of array and value of count on system stack
; returns: first count elements of array contain consecutive squares
; preconditions: count is initialized, 1 <= count <= 100
;                and the first count elements of array initialized
; registers changed: eax, ebx, edx, esi
; ***************************************************************
showRevList	PROC
	push	ebp
	mov	ebp,esp
	mov	edx,[ebp+8]		;count in edx
	mov	esi,[ebp+12]		;address of array in esi
	dec	edx				;scale edx for [count-1 down to 0]

more:
	mov	eax,edx			;display n
	call	WriteDec
	mov	al,'.'
	call	WriteChar
	mov	al,32
	call	WriteChar
	call	WriteChar
	mov	eax,[esi+edx*4]	;start with last element
	call	WriteDec			;display n-squared
	call	CrLf
	dec	edx
	cmp	edx,0
	jge	more
	
	pop	ebp
	ret	8
showRevList	ENDP

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
