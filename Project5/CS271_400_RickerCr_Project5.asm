TITLE Pseudo-random Integer Array Filler (CS271_400_RickerCr_Project5.asm)

; Author: Craig Ricker
; Last Modified: May 25, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 5               Due Date: May 27, 2018
; Description:
; This program will prompt the user to enter an integer, validate it
; It will then fill the array with random integers between 
; LO_RANGE and HI_RANGE. It will then display the median, and sorted
; array. Even though this is the order things happen, actually sort 
; array before median to make calculation easy

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
intro2P		BYTE	"Programmed by Craig Ricker. "
expl1P		BYTE	"You will be prompted to enter an integer for the array size. "
expl2P		BYTE	"The array will then be filled, displayed, the median displayed, and the sorted array displayed.",0
rangeP		BYTE	"Enter an integer between [10,200]:",0
unsortedP	BYTE	"The array unsorted is:", 0
sortedP		BYTE	"The array sorted is:", 0
medP		BYTE	"The median number is: ",0


count		DWORD	10							; Input number
squareArray	DWORD	MAX_REQUEST		 DUP(?)
.code


main PROC
	; Seed random number generator
	call	Randomize

	; Introduce the program
	push	OFFSET introP
	call	intro

	; Prompt the user to enter an integer, and then store value into count
	push	OFFSET rangeP
	call	getUserData	
	pop		count
	
	
	; Fill the array of length count with random integers between
	; LO_RANGE and HI_RANGE
	push	OFFSET squareArray
	push	count
	call	fillArray

	; Print out the array to the user
	push	OFFSET unsortedP
	push	OFFSET squareArray
	push	count
	call	printArray

	; Sort array using bubblesort
	push	OFFSET squareArray
	push	count
	call	sortArray

	; Calculate and print median
	push	OFFSET medP
	push	OFFSET squareARray
	push	count
	call	displayMedian

	; Print the array out, now sorted
	push	OFFSET sortedP
	push	OFFSET squareArray
	push	count
	call	printArray
	
 	exit			;exit to operating system
main ENDP


;-------------------------------------------------------------------------------
intro PROC
; Description:	Prints out an introduction to the user
;				
;
; Input:		prompt		text to introduce program
; Output:		None
; Registers:	None modified
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			prompt to print
;--------
;-------------------------------------------------------------------------------
	; Set up stack and store registers
	push	ebp
	mov		ebp,esp
	pushad	

	; Print out instructions to user
	mov		edx, [ebp + 8]
	call	WriteString
	call	CrLf
	; Restore registers
	popad
	pop	ebp
	ret 4
intro ENDP


;-------------------------------------------------------------------------------
getUserData PROC
; Description:	Prints a prompt that requests users to pick an int in between
;				an upper and a lower bound. Reprompt until satisfied
;
; Input:		prompt		text to explain input requirements
; Output:		number selected by user
; Registers:	None modified
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			prompt to print
;--------
;-------------------------------------------------------------------------------
	; Set up stack and store registers
	push	ebp
	mov		ebp,esp
	pushad	

	; Repeatedly prompt user until int within range is entered
EntryLoop:
	mov		edx, [ebp + 8]						; Print prompt from stack
	call	WriteString
	call	ReadInt								; Read in number
	call	CrLf

	; Make a call to validateInput to check if within range
	; Boolean check
	push	eax				
	call	validateInput	
	pop		edx				
	cmp		edx, 1			
	je		Return			
	jmp		EntryLoop		

	; Restore registers
	; Store return value currently in eax into same memory location
	; Don't pop off, allow to happen in upper level to return number
Return:
	mov		[ebp + 8], eax
	popad
	pop	ebp
	ret
getUserData	ENDP

;-------------------------------------------------------------------------------
validateInput PROC
; Description:	Prints a prompt that requests users to pick an int in between
;				an upper and a lower bound. Reprompt until satisfied
;
; Input:		prompt		text to explain input requrements
;				lowerlimit	smallest acceptable int
;				upperlimit	largest acceptable int
; Output:		number selected by user
; Registers:	None
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			Number to check if within limits
;--------
;-------------------------------------------------------------------------------
	; Set up stack and store registers
	push	ebp
	mov		ebp,esp
	pushad	
	
	mov		eax, [ebp + 8]

	; If within range, it is valid
	cmp		eax, MAX_REQUEST
	jg		Invalid								; Too big
	cmp		eax, MIN_REQUEST
	jl		Invalid								; Too small

	; Valid, aka true
Valid:
	mov		edx, 1								; They are the same
	jmp		Return

	; Invalid, aka false
Invalid:
	mov		edx, 0								; False, different

	; Restore registers
	; Store return value currently in EDX into same memory location
Return:
	mov		[ebp + 8], edx
	popad
	pop		ebp
	ret
validateInput ENDP


;-------------------------------------------------------------------------------
;--------
fillArray PROC
; Description:	Loops through array and fills with random int within range
;				specified by LO_RANGE and HI_RANGE
;				Adapted from teacher provided code
;
; Input:		count - array size
;				array memory location
; Output:		Filled array
; Registers:	None
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			Number of elements in array
;				[ebp + 12]			Beginning of array
;--------
;-------------------------------------------------------------------------------
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
	; Add low range to ensure within range
	add		eax, LO_RANGE
	; Store and increment array pointer
	mov		[edi],eax
	add		edi,4
	loop	again

	; Restore registers
	popad
	pop	ebp
	ret	8
fillArray	ENDP



;-------------------------------------------------------------------------------
printArray PROC
; Description:	Given an initial offset, and count, print out all items in 
;				input array
; Input:		Input 1: Array memory location
;				Input 2: Array size.
; Output:		No output is created
; Registers:	No registers modified
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

	; Print out information about the array being printed
	mov		edx, [ebp + 16]
	call	WriteString
	call	CrLf

	; Actual code that will loop through array
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

	; Print out new lines for appearances
	call	CrLf
	call	CrLf

	; Restore registers & return
	popad
	pop		ebp
	ret		12
printArray ENDP


;-------------------------------------------------------------------------------
;--------
sortArray PROC
; Description:	Loops through array and sorts array. Uses code adapted from
;				Irvine text book, section 9.5
;
; Input:		count - array size
;				array memory location
; Output:		Sorted array
; Registers:	None
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			Number of elements in array
;				[ebp + 12]			Beginning of array
;--------
;-------------------------------------------------------------------------------
	; Set up stack frame and store registers
	push	ebp
	mov		ebp, esp
	pushad

	; ecx will be used to track how far through array you are
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
	mov		eax, [esi] 
	cmp		[esi + 4], eax 
	jl		L3
	xchg	eax, [esi + 4]
	mov		[esi], eax

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


;-------------------------------------------------------------------------------
;--------
displayMedian PROC
; Description:	Using sorted array, calculates and displays median vlaue
;
; Input:		count - array size
;				array memory location
;				prompt to print
;
; Output:		Median of input array
; Registers:	None
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			Number of elements in array
;				[ebp + 12]			Beginning of array
;				[ebp + 16]			Prompt to print
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	pushad

	; Print out median prompt
	mov		edx, [ebp + 16]
	call	WriteString

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

	; Print value to user
RetDisplayMedian:
	call	WriteDec
	mov		al, '.'
	call	WriteChar
	call	CrLf
	call	CrLf
	; Restore registers and returns
	popad
	pop		ebp
	ret		12
displayMedian ENDP

END main
