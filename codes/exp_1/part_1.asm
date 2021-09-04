; Author: Utkarsh Patel (18EC35034)
; 
; Specification:
; Program to simulate a traffic light with R->Y (5 s), Y-G (2 s), stay for 1 s and repeat
; 
; Run this file with Update Freq 100

start:
	MOV P1, #11111110B
	CALL delay1
	CALL delay1
	CALL delay1
	CALL delay1
	CALL delay1
	MOV P1, #11101111B
	CALL delay1
	CALL delay1
	MOV P1, #01111111B
	CALL delay1
	JMP start	

delay1: ; creating a delay of 1 s when Update Freq is set to 100
	MOV R0, #250
	MOV R1, #250
	DJNZ R0, $
	DJNZ R1, $
	RET
