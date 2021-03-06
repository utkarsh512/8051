; Author: Utkarsh Patel (18EC35034)
; 
; Specification:
; Design a digital clock using the 7-segment display modules. The clock normally displays the time in mm-ss format
; It updates time automatically using the timer interrupt of the microcontroller.
; 
; Run this file with Update Freq 100

org 0000H    
mov 70H, #11000000B          ; Codes for digits stored from 70H
mov 71H, #11111001B
mov 72H, #10100100B
mov 73H, #10110000B
mov 74H, #10011001B
mov 75H, #10010010B
mov 76H, #10000010B
mov 77H, #11111000B
mov 78H, #10000000B
mov 79H, #10010000B 

mov 30H, #00                 ; temporary location to store m1
mov 31H, #00                 ; temporary location to store m0
mov 32H, #00                 ; temporary location to store s1
mov 33H, #00                 ; temporary location to store s0
mov TMOD,#00H               ; setting TMOD

start:
	inc 33H                 ; incremeting s0  	
	mov A, 33H   
	cjne A, #0AH, X         ; checking whether s0 > 9, if true proceed, else continue
	mov 33H, #00            ; s0 = 0
	
	inc 32H                 ; incrementing s1
	mov A, 32H
	cjne A, #06, X          ; checking whether s1 > 5, if true proceed, else continue
	mov 32H,#00             ; s1 = 0

	inc 31H                 ; incrementing m0	
	mov A, 31H	   
	cjne A, #0AH, X         ; checking whether m0 > 9, if true proceed, else continue 
	mov 31H,#00             ; m0 = 0

	inc 30H                 ; incrementing m1
	mov A, 30H
	cjne A, #06, X          ; checking whether m1 > 5, if true proceed, else continue
	MOV 30H,#00;

	X:                      ; display time on 7-seg display
		clr TF1
		acall displayClock

	jmp start

displayClock: ; displaying clock on multiplexed 7-seg display
	; displaying s0 on disp0
	mov A, 33H
	clr P3.4
	clr P3.3
	acall displayDigit

	; displaying s1 on disp1
	mov A, 32H
	setb P3.3
	acall displayDigit

	; displaying m0 on disp2
	mov A, 31H
	clr P3.3
	setb P3.4
	acall displayDigit

	; displaying m1 on disp3
	mov A, 30H
	setb P3.3
	acall displayDigit

	ret

displayDigit: ; display current digit on 7-segment display
	add A, #70H
	mov R1, A
	mov P1, @R1
	acall delay
	ret

delay: ; creating a delay of 0.25 sec
	mov R0, #125
	djnz R0, $
	ret
