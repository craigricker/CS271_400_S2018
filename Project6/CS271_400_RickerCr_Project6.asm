TITLE I/O Macro Madness (CS271_400_RickerCr_Project6.asm)

; Author: Craig Ricker
; Last Modified: June 7, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 6               Due Date: June 10, 2018
; Description:


INCLUDE Irvine32.inc

;-------------------------------------------------------------------------------
displayString MACRO printAddress,
;-------------------------------------------------------------------------------
; Prints dsipaly at address printAddress
	; Store edx, move to offset, print then restore
	push	edx
	mov		edx, printAddress
	call	WriteString
	pop		edx
ENDM

;-------------------------------------------------------------------------------
;	Prints prompt located at promptAddress, and then stores into
;	storeAddress which is string length of stringSize
getString MACRO storeAddress, stringSize, promptAddress
;-------------------------------------------------------------------------------
	; Store registers, print prompt read into variable, restore
	push	ecx
	push	edx
	displayString promptAddress
	mov		edx, storeAddress
	; Remember to offset by 1 to store terminating bit
	mov		ecx, stringSize
	call	ReadString
	pop		edx
	pop		ecx
ENDM

BASE		= 10
ASII_OFFSET	= 48


.data
ec1			BYTE	"Extra Credit #1: output columns are aligned! ",0
introP		BYTE	"Welcome to 'I/O Macro Madness' "
intro2P		BYTE	"Programmed by Craig Ricker. "
expl1P		BYTE	"You will be prompted to enter an integer for the array size. "
expl2P		BYTE	"The array will then be filled, displayed, the median displayed, and the sorted array displayed.",0
rangeP		BYTE	"Enter an integer between [10,200]:",0
unsortedP	BYTE	"The array unsorted is:", 0
sortedP		BYTE	"The array sorted is:", 0
medP		BYTE	"The median number is: ",0
getPrompt	BYTE	"Enter your float here:",0

buffer			BYTE	255 DUP(0)
printBuffer	BYTe	"F",0
inputSucc	DWORD	?
input		DWORD	?							; Input number





.code
main PROC
;	getString		OFFSET buffer, OFFSET getPrompt, SIZEOF buffer
;	mov		ecx, OFFSET buffer
;	displayString	ecx
;	call	CrLf
;	push	123
;	push	OFFSET printBuffer
;	call	WriteVal
;	call	CrLf
	push	0
	push	0
	push	OFFSET buffer
	push	SIZEOF buffer
	call	ReadVal
	pop		input
	pop		inputSucc
	call	CrLf
	call	CrLf
	mov		eax, input
	call	WriteInt
 	exit			;exit to operating system
main ENDP

;-------------------------------------------------------------------------------
readVal PROC
; Description:	Converts string to integer, does input check as well
;				
;
; Input:		buffer size		[ebp + 8]	size of the array
;				buffer offset	[ebp + 12]	Location of array
;				return location	[ebp + 16]	where to return to
;				"Good" number	[ebp + 20]	bool if successful number
;											also if first digit
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


	; Check if this is the first time being called
	mov		eax, 0
	cmp		eax, [ebp + 20]
	jne		InitReg

GetInput:
	getString [ebp + 12], [ebp + 8], OFFSET getPrompt

InitReg:
	; Move values from stack for easier reading
	mov		edx, [ebp + 12]
	mov		ecx, [ebp + 8]


	; Initialize registers for looping
	mov		esi, [ebp + 12]
	mov		eax, 0
	mov		ecx, [ebp + 16]
	mov		ebx, BASE

	; Load string byte by byte (literally!), check if null term string
	; If it isn't, check if valid input
	; If null string, break out of loop
	lodsb
	cmp		ax, 0
	je		RestoreReturn
	
	; Check if within range
	cmp		ax, 48
	jb		InvalidInput
	cmp		ax, 57
	ja		InvalidInput

	; Need to convert from integer number, to ASCII representation
	; To do this, simply subtract 48
	sub		ax, 48
	; Swap eax and ecx registers, this is required because of how
	; loadsb and mul both behave
	xchg	eax, ecx
	mul		ebx
	; Check if overflow, shouldn't be required but still good to check
	jc		InvalidInput

	; If valid input, add to running total, read next digit
	; Swap registers back, continue reading
	ValidInput:
	add		eax, ecx
	; Was switching, try just pushing eax.
	;xchg	eax, ecx
	
	; Push values and call again
	push	1
	push	eax
	push	esi
	push	[ebp + 8]
	call	readVal
	; Pop return value into ecx, to be swapped later
	; More efficient to pop into eax but this is more
	; readable/consistent with code design
	pop		ecx
	; Pop success or failure into edx
	; Boolean, 0 or 1
	pop		edx

	; Check if still "good" number aka if ecx = 1
	cmp		edx, 1
	je		Successful
	

	; If invalid, set flag as false and return
	; Don't continue to do math with numbers
	InvalidInput:
	mov		eax, 0
	mov		[ebp + 20], eax
	jmp		RestoreReturn

	



Successful:
	mov		[ebp + 16], ecx
	mov		ecx, 1
	mov		[ebp + 20], ecx


RestoreReturn:
	; Restore registers
	popad
	pop	ebp
	ret 8
readVal ENDP




;-------------------------------------------------------------------------------
writeVal PROC
; Description:	Converts floating point number to string. Assumes that all
;				input is a true floating point.
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

	; Initalize values based on input
	mov		eax, [ebp + 12]
	mov		edi, [ebp + 8]
	mov		ebx, BASE


	; Div by 10, remainder is least sig digit
	; Increase by ASCII_OFFSET to make into string
	mov		edx, 0
	div		ebx
	add		edx, ASII_OFFSET

	; Check if you are at the end of the number
	; If not, go one level deeper
	; Otherwise, begin printing out digits
	cmp		eax, 0
	je		PrintReturn



	push	eax
	push	[ebp + 8]
	call	writeVal



PrintReturn:
	; Change this to use macro, and not call to write char
	mov		al, dl
	call	WriteChar
	; Restore registers
	popad
	pop	ebp
	ret 8
writeVal ENDP


END main
