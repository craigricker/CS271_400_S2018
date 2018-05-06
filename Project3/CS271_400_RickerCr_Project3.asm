TITLE Negative Counter     (CS271_400_RickerCr_Project3.asm)

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

; Constant Definitions
LOWER_LIMIT		= -100							; Input can't be smaller than
UPPER_LIMIT		= -1							; Input can't be larger than
	
.data
intro		BYTE	"Welcome to 'Negative Number Average'",0
intro1		BYTE	"Programmed by Craig Ricker",0
userQues	BYTE	"What is your name: ",0
extra1		BYTE	"Extra Credit #1: I added line counting",0
extra2		BYTE	"Extra Credt #2: use float devision",0
userGreet	BYTE	"Well hello ",0
expl1		BYTE	"Please enter numbers [-100, -1].",0
expl2		BYTE	"Enter a non-negative number when you are finished to see results.",0
enterNumb	BYTE	"Enter number ",0
enterNumb2	BYTE	": ",0
noInput		BYTE	"No negative numbers entered.", 0
calcCount	BYTE	"Number of valid numbers		: ",0
calcSum		BYTE	"Sum of valid numbers		: ",0
calcAvg		BYTE	"Average of valid numbers	: ",0
goodBye		BYTE	"Good bye, I hope you had fun ",0

; To handle input data
buffer		BYTE 21 DUP(0)						; input buffer
inputNumb	SDWORD ?							; Current user input
rollSum		SDWORD 0							; Rolling sum of input
inCount		SDWORD 0							; Number of inputs
average		SDWORD ?							; Calculated average

.code
main PROC

;-------------------------------------------------------------------------------
;----Greet user----
Greeting:
	mov		edx, OFFSET intro					; Print program info
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extra1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userQues				; Ask the user their name
	call	WriteString

	mov		edx,OFFSET buffer					; point to the buffer
	mov		ecx,SIZEOF buffer					; specify max characters
	call	ReadString							; input the string
;	mov		byteCount,eax						; number of characters

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
;----End greeting
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;----Data entry loop----
EntryLoop:
	mov		edx, OFFSET enterNumb				; Prompt user to enter number
	call	WriteString
	mov		eax, inCount						; Print out the number entering
	inc		eax
	call	WriteDec
	mov		edx, OFFSET enterNumb2
	call	WriteString
	call	ReadInt								; Read in number
	mov		inputNumb, eax						; Store number


	cmp		inputNumb, UPPER_LIMIT
	jg		CheckCount							; + number, exit loop
	cmp		inputNumb, LOWER_LIMIT
	jl		EntryLoop							; Ignore number


	add		rollSum, eax						; Add input to rollSum
	inc		inCount								; Another successful number
	jmp		EntryLoop							; Get another input

;----End entry loop
;-------------------------------------------------------------------------------





;-------------------------------------------------------------------------------
;----Check count----
CheckCount:
	cmp		inCount, 0							; Check if no entries
	jne		CalculateResults
;----End Check Count----
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
;----No Input----
	mov		edx, OFFSET noInput					; Special message if no input
	call	WriteString
	call	CrLf
	jmp		Ending								; Jump to end, don't calculate
;----End No Input	----
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
;----Calculate Results----
CalculateResults:
	;cmp		inCount, 0
	;je		NoInput								; No valid input
	mov		eax, rollSum						; Prepare to calc sum
	mov		ebx, inCount
	cdq											; Extend eax
	idiv	ebx
	mov		average, eax
;----End Calculate Results
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;----Display Results----
DisplayResults:
	mov		edx, OFFSET calcCount				; Text of valid numbers input
	call	WriteString
	mov		eax, inCount
	call	WriteDec							; Total count of valid input
	call	CrLf
	mov		edx, OFFSET calcSum					; Text for sum
	call	WriteString
	mov		eax, rollSum
	call	WriteInt							; Sum of all numbers
	call	CrLf
	mov		edx, OFFSET calcAvg					; Text for average
	call	WriteString
; TEMPORARILY WRITE 99 TO AVERAGE
	mov		eax, average
	call	WriteInt							; Average of numbers
	call	CrLf
;----End Display Results----
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;----Ending----
Ending:
	mov		edx, OFFSET goodBye					; Tell user goodbye
	call	WriteString
	mov		edx, OFFSET buffer					; Use their name
	call	WriteString
	call	CrLf
;----End Ending----
;-------------------------------------------------------------------------------

	
	exit	; exit to operating system
main ENDP


END main
