TITLE Recursive Macro Math (CS271_400_RickerCr_Project6.asm)

; Author: Craig Ricker
; Last Modified: June 7, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 6               Due Date: June 10, 2018
; Description:


INCLUDE Irvine32.inc

;-------------------------------------------------------------------------------
displayString MACRO printAddress
;	Macro that uses Irvine WriteString to store register, print printAddress
;	restore registers and be done.
;-------------------------------------------------------------------------------
; Prints dsipaly at address printAddress
	; Store edx, move to offset, print then restore
	push	edx
	mov		edx, printAddress
	call	WriteString
	pop		edx
ENDM

;-------------------------------------------------------------------------------
getString MACRO storeAddress, stringSize, promptAddress
;	Prints prompt located at promptAddress, and then stores into
;	storeAddress which is string length of stringSize
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


; Constants
BASE		= 10
PER_ROW		= 10
ASII_OFFSET	= 48


.data
ec			BYTE	"Extra Credit #1: input numbered, running sum displayed ",13,10
			BYTE	"Extra Credit #3: ReadVal and WriteVal are recursive",13,10,0
introP		BYTE	"Welcome to 'Recursive Macro Math' ",13,10
intro2P		BYTE	"Programmed by Craig Ricker. ",13,10
expl1P		BYTE	"You will be prompted to enter ten positive integers.",13,10
expl2P		BYTE	"These ten values will be stored in an array, you will then be shown the array,"
expl3P		BYTE	" the sum of the array, and the average value",13,10,0
getPrompt	BYTE	9,9,". Enter next integer here:",0
errPrompt	BYTE	"You need to enter a 'good' integer that will fit in a 32 bit register",13,10,0
inputP		BYTE	" :","integers. Subtotal: ",0
arrayP		BYTE	"You entered the following numbers:",13,10,0
sumP		BYTE	"The sum of these numbers is :",9,9, 0
avgP		BYTE	"The average of these numbers is:",9,0
goodbyeP	BYTE	"Thanks for playing, and goodbye!",13,10,0


buffer			BYTE	255 DUP(0)
inputSucc	DWORD	?
input		DWORD	?
calcSum		DWORD	12345
calcAvg		DWORD	?
inputCount	DWORD	1
inputArray	DWORD	10 DUP(9)





.code
main PROC
	; Print instructions to user
	displayString OFFSET introP
	displayString OFFSET ec


	; Initialize registers for looping
	mov		eax, 0			; Rolling sum
	mov		ecx, 1			; Count of good input
	mov		edi, OFFSET inputArray

	; Loop through ten times to get "good" input from user
	; Calculate rolling sum as well, print this out and number
	; of "good" input to user when prompting.
GetInput:
	; Print out information on sum, what number you are inputing
	push	0
	push	ecx
	push	OFFSET BUFFER
	call	WriteVal
	displayString OFFSET inputP
	push	0
	push	eax
	push	OFFSET BUFFER
	call	WriteVal


	; Set up stack for ReadVal, call and store return values
	push	0
	push	0
	push	OFFSET buffer
	push	SIZEOF buffer
	call	ReadVal
	pop		input
	pop		inputSucc

	; If inputSucc is true,  add value, otherwise jump to get new input
	cmp		inputSucc, 1
	je		GoodInput

	; ReadVal returned false, get new input
BadInput:
	displayString OFFSET errPrompt
	jmp		GetInput


	; Good input, store data and increase ecx count
GoodInput:
	; Store before increasing
	mov		inputCount, ecx
	inc		ecx
	add		eax, input
	mov		calcSum, eax

	; Use edx to store input
	mov		edx, input
	mov		[edi], edx
	add		edi, 4

	cmp		ecx, BASE + 1
	jne		GetInput


	; Once loop is done, print out information on data entered
	; Print array, sum, and average
	displayString OFFSET arrayP
	push	OFFSET inputArray
	push	LENGTHOF inputArray
	call	printArray
	displayString OFFSET sumP
	push	0
	push	calcSum
	push	OFFSET buffer
	call	WriteVal
	call	CrLf
	displayString OFFSET avgP
	; Calculate and display average
	; clear edx, just in case
	mov		edx, 0
	div		inputCount
	push	0
	push	eax
	push	OFFSET buffer
	call	WriteVal
	call	CrLf
	displayString OFFSET goodbyeP
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
	ret		8
printArray ENDP





;-------------------------------------------------------------------------------
writeVal PROC
; Description:	Converts floating point number to string. Assumes that all
;				input is a true floating point. Prints out at end
;
;
; Note:			Due to project requirements, this program has a strange
;				implementation. writeVal must use dispalyString. If not,
;				a simple call to WriteChar, or just convert to string
;				and then make a single call to displayString would be made.
;				Having that requirement and being recursive was especially tricky
;				
;
; Input:		prompt		text to introduce program
; Output:		None
; Registers:	None modified
; StackFrame	ret addres			Address to return to
;				[ebp + 16]			Level of recursion
;				[ebp + 12]			Current Number
;				[ebp + 8]			Address of string to utilize
;--------
;-------------------------------------------------------------------------------
	; Set up stack and store registers
	push	ebp
	mov		ebp,esp
	pushad

	; Initalize values based on input
	mov		ecx, [ebp + 16]
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
	inc		ecx
	cmp		eax, 0
	je		PrintReturn

	
	push	ecx
	push	eax
	push	[ebp + 8]
	call	writeVal
	pop		edi
	pop		eax
	pop		ecx



PrintReturn:
	; Current value is stored into edx
	mov		eax, edx
	cld
	stosb
	; Store start of offset
	mov		eax, [ebp + 8]
	mov		[ebp + 8], edi
	; Check if at "end" which is first call of function
	; Defined as offset + ecx
	add		ecx, eax
	dec		ecx
	cmp		eax, ecx
	jne		RestoreReturn


	mov		ebx, eax
	mov		eax, 0
	stosb
	displayString ebx

RestoreReturn:
	; Restore registers
	popad
	pop	ebp
	ret
writeVal ENDP


END main
