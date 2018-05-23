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
MAXSIZE			= 100
PER_ROW			= 10
TAB				= 9


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
	mov		ebp,esp
	mov		edx,OFFSET prompt1
	call	WriteString		;prompt user
	call	ReadInt			;get user's number
	mov		ebx,[ebp+8]		;address of count in ebx
	mov		[ebx],eax			;store in global variable
	pop		ebp
	ret		4
getCount	ENDP

; ***************************************************************
; Procedure to put count squares into the array.
; receives: address of array and value of count on system stack
; returns: first count elements of array contain consecutive squares
; preconditions: count is initialized, 1 <= count <= 100
; registers changed: eax, ebx, ecx, edi
; ***************************************************************
fillArray	PROC
	; Set up stack and store registers
	push	ebp
	mov		ebp,esp
	pushad	

	; ecx will track how far in the array we are, and edi will point
	; to the current item
	mov		ecx,[ebp+8]
	mov		edi,[ebp+12]

	; Set up registers to generate pseudo random number
	mov		ebx, LO_RANGE
	mov		edx, HI_RANGE
	inc		edx
	sub		edx, ebx
	
	; Loop through the array, and fill with random numbers within 
	; HI_RANGE and LO_RANGE
again:
	; Use Irvine function to calculate random integer
	mov		eax,edx
	call	RandomRange
	; Store and increment array pointer
	mov		[edi],eax
	add		edi,4
	loop	again

	; Restore registers
	popad
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
	; Set up stack and store registers
	push	ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp + 12]
	mov		ecx, [ebp + 8]
ArrayLoop:
	mov		eax, [edi]
	call	WriteDec
	call	CrLf
	add		edi, 4
	loop	ArrayLoop

	; Restore registers
	popad
	pop		ebp
	ret		4
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
	; Set up stack frame and store registers
	push	ebp
	mov		ebp, esp
	pushad
	; ecx is array length, edi is array pointer and ebx
	; will be used to decide if a new line is required
	mov		edi, [ebp + 12]
	mov		ecx, [ebp + 8]
	mov		ebx, 0
ArrayLoop:
	; Print out an item, and increase print cout
	mov		eax, [edi]
	call	WriteDec
	inc		ebx
	; If printed out PER_ROW, print new line, otherwise print a tab
	cmp		ebx, PER_ROW
	je		NewRow
	mov		al, TAB
	call	WriteChar
	jmp IncrementArray

NewRow:
	; Print new line, and reset count per line to zero
	call	CrLf
	mov		ebx, 0
	jmp		IncrementArray

IncrementArray:
	; Increment array pointer
	add		edi, 4
	loop	ArrayLoop

	; Restore registers
	popad
	pop		ebp
	ret		4
printArray ENDP

sortArray PROC
; Set up stack frame and store registers
	push	ebp
	mov		ebp, esp
	pushad

	; ecx will be used to track how far through array you are
	; following pseudocode from teacher to do SelectionSort
	; edi will be the array pointer, keeping this consistent
	mov			ecx, 0
	mov			edi, [ebp + 12]


; At the begining of loop, you will use ecx from the previous round
; This is why you begin with ecx as 0, the next number will always be larger
; In this small case
Start:
	mov			eax, ecx
	mov			ebx, ecx

; for(j=k+1; j<request; j++) {
; 	if(array[j] > array[i])
;		i = j;
InnerLoop:
	; First check if you have sorted the entire list, if so, break out of this portion 
	inc			ebx
	cmp			ebx, [ebp + 8]
	je			outerLoop
	; Otherwise, compare the next two items
	mov			edx, [edi + ebx * 4]	; comparing a pair of elements whereas it is arr[j] to arr[i]
	cmp			edx, [edi + eax * 4]
	; If it is less, this is expected, go onto next item
	; However, if they are out of order, you need to swap the two
	jl			innerLoop				; if arr[i] is less jump back to the inner loop
	pushad								; push register values onto stack to save them
	mov			esi, [ebp + 12]
	mov			ecx, 4
	mul			ecx
	add			esi, eax
	push	esi
	mov			eax, ebx
	mul			ecx
	add			edi, eax
	push	edi
	call	swapNodes				; if arr[i] is greater swap it with arr[j]
	popad								; reinitialize the register values prior to pushad
	jmp			innerLoop

OuterLoop

	inc			ecx
	cmp			ecx, [ebp + 8]
	je			return					; returns if all elements have been sorted
	jmp			start

ReturnSort:
	; Restore registers
	popad
	pop		ebp
	ret		4
sortArray ENDP

swapNodes PROC
	; Set up stack frame and store registers
	push	ebp
	mov		ebp, esp
	pushad


	; Swap two values. Overly complicated because you can't swap [] to []
	; First must store each memory location, and then put value into temp
	; container. Swap values, and then return
	mov		esi, [ebp + 12]
	mov		edi, [ebp + 8]
	mov		edx, [edi]
	mov		ecx, [esi]
	mov		[edi], ecx
	mov		[esi], edx


	; Restore registers
	popad
	pop		ebp
	ret		4
swapNodes ENDP
	


END main
