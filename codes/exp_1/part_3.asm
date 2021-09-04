; Author: Utkarsh Patel
;
; Specification: Display 18EC on the 7-segment display, each character on different display
; 
; Run the program with Update Freq 100

start:
	SETB P3.3
	SETB P3.4
	MOV P1, #11111001B
	CALL delay
	CLR P3.3
	MOV P1, #10000000B
	CALL delay
	CLR P3.4
	SETB P3.3
	MOV P1, #10000110B
	CALL delay
	CLR P3.3
	MOV P1, #11000110B
	CALL delay
	JMP start	

delay:
	MOV R0, #250
	DJNZ R0, $
	RET
