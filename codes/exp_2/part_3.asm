; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Stop-watch
; In stopwatch mode, there are two more buttons namely, start and stop. On pressing the start button, the
; stopwatch sets to zero and continue counting time and then on pressing the stop button it display the
; counted duration.
;
; Instructions: 
; * Default mode is clock mode
; * Press P2.7 to switch to stop-watch mode and release it to switch to clock mode
; * Press P2.0 to start stop-watch and release it to reset stop-watch
; 
; Run this code with update frequency 100

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

; temporary location of storing clock state
mov 30H, #00                 ; temporary location to store m1
mov 31H, #00                 ; temporary location to store m0
mov 32H, #00                 ; temporary location to store s1
mov 33H, #00                 ; temporary location to store s0

; temporary location for storing stop-watch mode
mov 40H, #00                 ; temporary loc to store m1
mov 41H, #00		     ; temporary loc to store m0
mov 42H, #00		     ; temporary loc to store s1
mov 43H, #00		     ; temporary loc to store s0
mov TMOD, #00H               ; setting TMOD

start:
	acall changeClockState
	jmp start

changeClockState:               ; changing state of the clock
	inc 33H                 ; increment s0
	mov A, 33H
	cjne A, #0AH, X         ; check s0 > 9
	mov 33H, #00            ; set s0 to 0

	inc 32H                 ; increment s1
	mov A, 32H             
	cjne A, #06, X          ; check s1 > 5
	mov 32H, #00            ; set s1 = 0

	inc 31H                 ; increment m0
	mov A, 31H              
	cjne A, #0AH, X         ; check m0 > 9
	mov 31H, #00            ; set m0 = 0

	inc 30H                 ; increment m1
	mov A, 30H
	cjne A, #06, X          ; check m1 > 5
	mov 30H, #00            ; set m1 = 0
	acall X

changeStopWatchState:           ; changing stop-watch state
	inc 43H                 ; increment s0
	mov A, 43H
	cjne A, #0AH, Y         ; check s0 > 9
	mov 43H, #00            ; set s0 to 0

	inc 42H                 ; increment s1
	mov A, 42H             
	cjne A, #06, Y          ; check s1 > 5
	mov 42H, #00            ; set s1 = 0

	inc 41H                 ; increment m0
	mov A, 41H              
	cjne A, #0AH, Y         ; check m0 > 9
	mov 41H, #00            ; set m0 = 0

	inc 40H                 ; increment m1
	mov A, 40H
	cjne A, #06, Y          ; check m1 > 5
	mov 40H, #00            ; set m1 = 0
	acall Y
X:
	clr TF1
	jb P2.7, displayClock           ; if P2.7 is zero, call displayClock module
	jnb P2.7, changeStopWatchState  ; else           , call changeStopWatchState module

Y:
	clr TF1
	jb P2.7, displayClock           ; if P2.7 is zero, display state of clock on 7-seg
	jb P2.0, resetStopWatch         ; if P2.0, reset the stop-watch
	jnb P2.7, displayStopWatch      ; if P2.7 is one, display state of stop-watch on 7-seg

displayClock: ; displaying clock on multiplexed 7-seg display
	; displaying s0 on disp0
	mov A, 30H
	setb P3.4
	setb P3.3
	acall displayDigit

	; displaying s1 on disp1
	mov A, 31H
	clr P3.3
	acall displayDigit

	; displaying m0 on disp2
	mov A, 32H
	setb P3.3
	clr P3.4
	acall displayDigit

	; displaying m1 on disp3
	mov A, 33H
	clr P3.3
	acall displayDigit

	ret
	
displayStopWatch: ; displaying clock on multiplexed 7-seg display
	; displaying s0 on disp0
	mov A, 40H
	setb P3.4
	setb P3.3
	acall displayDigit

	; displaying s1 on disp1
	mov A, 41H
	clr P3.3
	acall displayDigit

	; displaying m0 on disp2
	mov A, 42H
	setb P3.3
	clr P3.4
	acall displayDigit

	; displaying m1 on disp3
	mov A, 43H
	clr P3.3
	acall displayDigit

	ret

resetStopWatch:
	mov 40H, #00
	mov 41H, #00
	mov 42H, #00
	mov 43H, #00
	acall displayStopWatch

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
