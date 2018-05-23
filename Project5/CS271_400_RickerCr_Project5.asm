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
PER_ROW			= 10
TAB				= 9


.data

ec1			BYTE	"Extra Credit #1: output columns are aligned! ",0
introP		BYTE	"Welcome to 'Pseudo-random Integer Array Filler' "
intro2P		BYTE	"Programmed by Craig Ricker. ",
expl1P		BYTE	"You will be prompted to enter an integer for the array size. "
expl2P		BYTE	"The array will then be filled, displayed, the median displayed, and the sorted array displayed.",0
rangeP		BYTE	"Enter an integer between [10,200]:",0
unsortedP	BYTE	"The array unsorted is:", 0
sortedP		BYTE	"The array sorted is:", 0
medP		BYTE	"The median number is: ",0


count		DWORD	10							; Input number
spaceChar	BYTE	9,0							; Spaces to print
prompt1		BYTE		"How many squares ",0
userArray	DWORD	MAX_REQUEST		DUP(9)
squareArray	DWORD	MAX_REQUEST		 DUP(?)
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
	; Sort array, and then print
	mov		edx, OFFSET sorted
	call	WriteString
	call	CrLf
	push	OFFSET squareArray
	push	count
	call	sortArray
	push	OFFSET squareArray
	push	count
	call	printArray
	
	; Calculate and print median
	push	OFFSET medPrompt
	push	OFFSET squareARray
	push	count
	call	displayMedian
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

	; Print out new line
	call	CrLf
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
	mov		ecx, [ebp + 8]
	dec		ecx
	mov		edi, [ebp + 12]

; Store ecx for outer loop, and begin at beginning of array
L1:
	push	ecx
	mov		esi,edi

; Will get current value place into eax, then compare to 
; next value in array, and place accordingly
L2: 
	mov		eax,[esi] ; get array value
	cmp		[esi+4],eax ; compare a pair of values
	jl		L3 ; if [ESI] <= [ESI+4], no exchange
	xchg	eax,[esi+4] ; exchange the pair
	mov		[esi],eax


; Move both pointers forward by 2, loop back to the begining
; pop ecx is because loop requires ecx only
L3:
	add		esi,4
	loop	L2 
	pop		ecx
	loop	L1 


; Restore registers and returns
L4:
	popad
	pop		ebp
	ret		8
sortArray ENDP

displayMedian PROC
	push	ebp
	mov		ebp, esp
	pushad

	; Print out median prompt
	mov		edx, [ebp + 16]
	call WriteString

	; Load pointer array into memory
	mov		edi, [ebp + 12]

	; Calculate if array size is even or odd, calculate accordingly
	; Divide by two, of no remainder, even
	mov		eax, [ebp +8]
	cdq
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		EvenArray

; For odd array, easier case, just take middle element
; Just move into eax, then jump
OddArray:
	mov		eax, [edi + eax * 4]
	jmp		RetDisplayMedian

; For even array, take two center numbers and average them
; eax already contains the middle number caclulated above
EvenArray:
	; Store the two numbers into ecx and ebx, then average
	mov		ecx, [edi + eax * 4]
	dec		eax
	mov		ebx, [edi + eax * 4]
	mov		eax, ebx
	add		eax, ecx
	mov		ebx, 2
	div		ebx
	jmp		RetDisplayMedian


RetDisplayMedian:
	call	WriteDec
	mov		al, '.'
	call	WriteChar
	call	CrLf
	; Restore registers and returns
	popad
	pop		ebp
	ret		12
displayMedian ENDP

END main
