TITLE I/O Macro Madness (CS271_400_RickerCr_Project6.asm)

; Author: Craig Ricker
; Last Modified: June 7, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 6               Due Date: June 10, 2018
; Description:


INCLUDE Irvine32.inc

;-------------------------------------------------------------------------------
;	displayString MACRO printAddress, 
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
getString MACRO storeAddress, promptAddress, stringSize
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

count		DWORD	10							; Input number
squareArray	DWORD	MAX_REQUEST		 DUP(?)




.code
main PROC
	getString		OFFSET buffer, OFFSET getPrompt, SIZEOF buffer
	mov		ecx, OFFSET buffer""
	displayString	ecx
 	exit			;exit to operating system
main ENDP


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
	push	0

mathSection:
	mov		edx, 0
	div		ebx
	add		edx, ASII_OFFSET
	push edx

	cmp		eax, 0
	jne		mathSection

RemoveNumber:
	pop		[edi]
	mov		eax, [edi]
	inc		edi
	cmp		eax, 0
	jne		RemoveNumber

	displayString	[ebo + 8]




	; Restore registers
	popad
	pop	ebp
	ret 8
intro ENDP


END main
