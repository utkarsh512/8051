; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Saw-tooth Waveform Generation
; Write a program to generate a saw-tooth waveform through the DAC interface. Display the waveform on DAC scope. 
; Find the maximum frequency and the maximum amplitude that can be achieved in the simulator.
; 
; Run this code with update frequency 100

ORG 0000H       ; reset registers
N EQU 4         ; slope of saw-tooth waveform
CLR P0.7        ; enable DAC WR line

start:          ; start new cycle
  MOV A, #00H   ; initializing accumulator to zero

loop:           ; update current cycle
  MOV P1, A     ; move the content of A to P1 for display
  ADD A, #N     ; increment accumulator by N
  JNB CY, loop  ; condition to break current cycle and start new cycle
  SJMP start    ; start new cycle
  END
