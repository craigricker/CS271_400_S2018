TITLE  Crazy Composite Calculation (CS271_400_RickerCr_Project4.asm)

; Author: Craig Ricker
; Last Modified: May 2, 2018
; OSU email address: rickercr@oregonstate.edu
; Course number/section: CS271_400_S2018
; Project Number: 3               Due Date: May 6, 2018
; Description:
; This program will repeatedly prompt the user to enter a number
; In the range of [1, 400], check number
; If within range, print out all compositve numbers (non prime)

INCLUDE Irvine32.inc

LOWER_LIMIT		= 1							; Input can't be smaller than
UPPER_LIMIT		= 400							; Input can't be larger than

.data

intro		BYTE	"Welcome to 'Crazy Composite Calculation'",0
intro1		BYTE	"Programmed by Craig Ricker",0
userQues	BYTE	"What is your name: ",0
userGreet	BYTE	"Well hello ",0
expl1		BYTE	"Enter the number of compositve numbers you would like to see",0
expl2		BYTE	"Be reasonable...lets say any integer [1, 400]",0
oor			BYTE	"Out of range.",0
enterNumb	BYTE	"Enter an integer between [1,400]:",0
noInput		BYTE	"No negative numbers entered.", 0
calcCount	BYTE	"Number of valid numbers		: ",0
calcSum		BYTE	"Sum of valid numbers		: ",0
calcAvg		BYTE	"Average of valid numbers	: ",0
goodBye		BYTE	"Good bye, I hope you had fun ",0
buffer		BYTE 21 DUP(0)						; input buffer

inputNumb	DWORD 0								; Input number
counter		DWORD 0								; Count # printed entries
.code



main PROC
	call	introduction						; Print instructions
	push	OFFSET inputNumb					; Location to store input number
	push	OFFSET enterNumb					; Explanation of input req
	call	getUserData

	push	inputNumb							; Push for call to showComposites
	call	showComposites


	exit	; exit to operating system
main ENDP

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
; Output:		number selected by user
; Registers:	eax, and edx are modified
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			prompt to print
;				[ebp + 12]			return value
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	EntryLoop:
	mov		edx, [ebp + 8]						; Print prompt from stack
	call	WriteString
	call	ReadInt								; Read in number
	mov		edx, [ebp + 12]
	mov		[edx], eax						; Store number

	push	eax									; Prepare for number check
	call	validateInput						; Check if legal entry
	cmp		edx, 1								; 1 = Acceptable
	je		Return								; If not same, new number
	mov		edx, OFFSET oor						; Print out error message
	call	WriteString
	call	CrLf
	jmp		EntryLoop							; Invalid Number

Return:
	pop		ebp
	ret		8									; Return 16, pushed 4 values
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
; Registers:	Modifies edx, eax
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			Number to check if within limits
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	
	mov		eax, [ebp + 8]

	cmp		eax, UPPER_LIMIT
	jg		Invalid								; Too big
	cmp		eax, LOWER_LIMIT
	jl		Invalid								; Too small

Valid:
	mov		edx, 1								; They are the same
	jmp		Return

Invalid:
	mov		edx, 0								; False, different


Return:
	pop		ebp
	ret		4									; Pop off number to check

validateInput ENDP


;-------------------------------------------------------------------------------
showComposites PROC
; Description:	Print out all composite numbers between 1 and input
;
; Input:		upperLimit			Number to show until
; Output:		Text printed only
; Registers:	Modifies ecx, edx, eax
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			upperLimit
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]						; Set ecx up for loop
	mov		eax, 1
FindComposite:
	push	eax
	push	ecx									; Store ecx
	push	eax									; Setup IsComposite
	call	isComposite
	pop		ecx									; Restore ecx
	pop		eax
	cmp		edx, 1								; See if prime
	je		PrintComposite
	inc		eax
	jmp		FindComposite

PrintNewLine:
	call	CrLf

PrintComposite:
	call	WriteDec
	call	CrLf
	inc		eax
	loop	FindComposite


RetShowComposites:
	pop		ebp
	ret		4									; Pop off upperLimit
showComposites ENDP



;-------------------------------------------------------------------------------
isComposite PROC
; Description:	Decides if input is a composite number or not
;
; Input:		compCheck			Number to check
; Output:		0 or 1 if number is composite
; Registers:	Modifies ecx, edx, eax
; StackFrame	ret addres			Address to return to
;				[ebp + 8]			compCheck
;--------
;-------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp


	mov		ebx, [ebp + 8]						
	cmp		ebx, 3
	jle		IsPrime								; If < 3, prime
	mov		ecx, 2								; Start out at 2

TestPrime:

	mov		eax, ebx
	xor		edx, edx							; Clear edx
	div		ecx									; Divide to see if remainder
	cmp		edx, 0
	je		NotPrime							; Cleanly devisible
	inc		ecx
	cmp		ecx, [ebp + 8]						; Break out if at end
	je		IsPrime
	jmp		TestPrime							; At end, increase size

NotPrime:
	mov		edx, 1
	jmp		Return

IsPrime:
	mov		edx, 0

Return:
	pop		ebp
	ret		4									; Pop off upperLimit
isComposite ENDP

END main
