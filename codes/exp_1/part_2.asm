; Author: Utkarsh Patel (18EC35034)
; 
; Specification:
; Using assembly language code, display all digits of your cell phone number sequentially on one Seven segment display unit.
; For readability, display each digit for one second before going to the next digit. After displaying the whole number, 
; black out for 3 seconds and then repeat displaying the number
;
; Run this code with update frequency = 100

start:
	SETB P3.3 ; to select 7-seg display 3
	SETB P3.4 ; P3.3 and P3.4 must be logic high
	MOV P1, #10010000B
	CALL delay1
	MOV P1, #10010010B
	CALL delay1
	MOV P1, #10011001B
	CALL delay1
	MOV P1, #11111000B
	CALL delay1
	MOV P1, #10000010B
	CALL delay1
	MOV P1, #10100100B
	CALL delay1
	MOV P1, #11111001B
	CALL delay1
	MOV P1, #11111001B
	CALL delay1
	MOV P1, #11111001B
	CALL delay1
	MOV P1, #11111001B
	CALL delay1
	MOV P1, #11111111B
	CALL delay1
	CALL delay1
	CALL delay1
	CALL start
       
delay1: ; creating a delay of 1 s when Update Freq is set to 100
	MOV R0, #250
	MOV R1, #250
	DJNZ R0, $
	DJNZ R1, $
	RET
