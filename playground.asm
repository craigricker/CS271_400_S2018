TITLE Program Template     (template.asm)

; Author:
; Last Modified:
; OSU email address: 
; Course number/section:
; Project Number:                 Due Date:
; Description:

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
array  SWORD 8,2,3,5,-4,6,0,4
; (insert variable definitions here)

.code
main PROC

mov al,4Bh
and al,6Ch

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
