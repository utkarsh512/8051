; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Ramp Signal Generation
; Display inverted ramp signal on the DAC Scope. Change the slope of the ramp signal to 30o and 60 o
; 
; Run this code with update frequency 100

ORG 0000H       ; reset registers
N EQU 4         ; slope of ramp waveform
CLR P0.7        ; enable DAC WR line

loop:          
  MOV P1, A     ; move content of accumulator to P1 for display
  ADD A, #N     ; increment accumulator by N
  JMP loop      ; jump back to loop
