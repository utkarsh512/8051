; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Sinusoidal Signal Generation  
; Write programs to generate a sinusoidal waveform through the DAC interface. Display the waveform on the DAC. 
; 
; Run this code with update frequency 10

ORG 0000              ; reset vectors
CLR P0.7              ; enabling DAC WR line

start:                ; starting a new cycle
  MOV DPTR, #0070H    ; setting DPTR to point to memory at 70H
  MOV R0, #12         ; for loop

loop:                 ; reading value of signal and displaying it on the scope
  CLR A               ; clearing accumulator
  MOVC A, @A+DPTR     ; reading value using DPTR
  MOV P1, A           ; move content of accumulator to P1 for display
  INC DPTR            ; increment DPTR to read new value
  DJNZ R0, loop       ; looping 12 times

SJMP start            ; jump back to start

ORG 0070H             ; storing value of sinusoidal signal using step size of 30 degrees
DB 128, 192, 238, 255, 238, 192, 128, 64, 17, 0, 17, 64, 128;

END
