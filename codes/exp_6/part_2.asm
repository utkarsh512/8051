; Run this file with update frequency 100

ORG 0000H

MOV 50H, #'0'
MOV 51H, #'A'
MOV 52H, #'C'

MOV TMOD, #50H	; put timer 1 in event counting mode
SETB TR1		; start timer 1

CLR P1.3		; clear RS - indicates that instructions are being sent to the module

; function set	
CLR P1.7		; |
CLR P1.6		; |
SETB P1.5		; |
CLR P1.4		; | high nibble set

SETB P1.2		; |
CLR P1.2		; | negative edge on E

CALL delay		; wait for BF to clear	

SETB P1.2		; |
CLR P1.2		; | negative edge on E

SETB P1.7		; low nibble set (only P1.7 needed to be changed)

SETB P1.2		; |
CLR P1.2		; | negative edge on E
CALL delay		; wait for BF to clear

; entry mode set
; set to increment with no shift
CLR P1.7		; |
CLR P1.6		; |
CLR P1.5		; |
CLR P1.4		; | high nibble set

SETB P1.2		; |
CLR P1.2		; | negative edge on E

SETB P1.6		; |
SETB P1.5		; |low nibble set

SETB P1.2		; |
CLR P1.2		; | negative edge on E

CALL delay		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
CLR P1.7		; |
CLR P1.6		; |
CLR P1.5		; |
CLR P1.4		; | high nibble set

SETB P1.2		; |
CLR P1.2		; | negative edge on E

SETB P1.7		; |
SETB P1.6		; |
SETB P1.5		; |
SETB P1.4		; | low nibble set

SETB P1.2		; |
CLR P1.2		; | negative edge on E

CALL delay		; wait for BF to clear

again:
	CALL setDirection	; set the motor's direction
	MOV A, TL1			; move timer 1 low byte to A

	PUSH ACC

	; converting revolution count to BCD
	MOV B, #10
	DIV AB
	MOV R2, B
	MOV B, #10
	DIV AB
	MOV R1, B
	SETB P1.3
	ADD A, 50H
	CALL sendChar
	MOV A, R1
	ADD A, 50H
	CALL sendChar
	MOV A, R2
	ADD A, 50H
	CALL sendChar
	MOV A, #0
	MOV C, F0
	MOV ACC.0, C
	MOV R1, A
	MOV A, #51H
	ADD A, R1
	MOV R1, A
	MOV A, @R1
	CALL sendChar
	CALL delay

	; reset display to make room for next value
	CLR P1.3        ; lcd instruction mode on

	CLR P1.7        ; |
	CLR P1.6        ; |
	CLR P1.5        ; |
	CLR P1.4        ; | higher nibble value
	CALL pass       ; negative edge on enable
	SETB P1.4       ; | lower nibble value
	CALL pass       ; negative edge on enable
	CALL delay1

	POP ACC
	JMP again		; do it all again

setDirection:
	PUSH ACC		; save value of A on stack

	PUSH 20H		; | save value of location 20H (first bit-addressable 
					; |	location in RAM) on stack

	CLR A			; clear A
	MOV 20H, #0		; clear location 20H
	MOV C, P2.0		; put SW0 value in carry
	MOV ACC.0, C	; then move to ACC.0
	MOV C, F0		; move current motor direction in carry
	MOV 0, C		; and move to LSB of location 20H (which has bit address 0)

	CJNE A, 20H, changeDir		; | compare SW0 with F0
	JMP finish	

changeDir:
	CLR P3.0		; |
	CLR P3.1		; | stop motor

	CALL clearTimer	; reset timer 1 (revolution count restarts when motor direction changes)
	MOV C, P2.0		; move SW0 value to carry
	MOV F0, C		; and then to F0 - this is the new motor direction
	MOV P3.0, C		; move SW0 value (in carry) to motor control bit 1
	CPL C			; invert the carry

	MOV P3.1, C		; | and move it to motor control bit 0 (it will therefore have the opposite
					; | value to control bit 1 and the motor will start 
					; | again in the new direction)
finish:
	POP 20H			; get original value for location 20H from the stack
	POP ACC			; get original value for A from the stack
	RET				; return from subroutine

clearTimer:
	CLR A			; reset revolution count in A to zero
	CLR TR1			; stop timer 1
	MOV TL1, #0		; reset timer 1 low byte to zero
	SETB TR1		; start timer 1
	RET				; return from subroutine

pass:               ; negative edge on enable
  SETB P1.2
  CLR P1.2
  MOV R7, #50     ; small delay for lcd buffer
  DJNZ R7, $
  RET

sendChar:    ; send data in accumlator to current address of DDRAM in LCD to display it
	MOV C, ACC.7	; |
	MOV P1.7, C		; |
	MOV C, ACC.6	; |
	MOV P1.6, C		; |
	MOV C, ACC.5	; |
	MOV P1.5, C		; |
	MOV C, ACC.4	; |
	MOV P1.4, C		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	MOV C, ACC.3	; |
	MOV P1.7, C		; |
	MOV C, ACC.2	; |
	MOV P1.6, C		; |
	MOV C, ACC.1	; |
	MOV P1.5, C		; |
	MOV C, ACC.0	; |
	MOV P1.4, C		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET

delay:
  MOV R7, #50
  DJNZ R7, $
  RET

delay1:
  MOV R7, #255
  DJNZ R7, $
  MOV R7, #255
  DJNZ R7, $
  MOV R7, #255
  DJNZ R7, $
  MOV R7, #255
  DJNZ R7, $
  MOV R7, #255
  DJNZ R7, $
  MOV R7, #255
  DJNZ R7, $
  RET
