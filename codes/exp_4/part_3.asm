; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Trapezoidal Signal Generation  
; Write programs to generate a trapezoidal waveform having 40% duty ratio with 5% rise time and 5% fall time, 
; through the DAC interface. Display the waveform on DAC scope.
; 
; Run this code with update frequency 100

ORG 0000H        ; reset registers
CLR P0.7         ; enabling DAC WR line

N EQU 16         ; slope of trapezoid
N1 EQU 15        ; always N - 1

OT EQU 40H       ; on time
FT EQU 50H       ; off time

start:
  MOV A,#00H     ; initializing accumulator to zero

rise:
  MOV P1, A      ; moving content of accumulator to ADC input (to P1)
  ADD A, #N      ; incrementing accumulator (during rise time)
  JNB CY, rise   ; while overflow doesn't happen, keep incrementing
  MOV A, P1
  MOV R7, #OT    ; initializing on-time

logicHigh:       ; DUTY ON
  DJNZ R7, logicHigh 

temp:            ; temp module added to fix the falling condition
  MOV P1,A       
  SUBB A,#N1     

fall:
  MOV P1,A       ; moving content of accumulator to ADC input (to P1)
  SUBB A,#N      ; decrementing accumulator (during fall time)
  JNZ fall       ; while accumulator is not zero, keep decrementing
  MOV P1, A;
  MOV R7, #FT;

logicLow:        ; DUTY OFF
  DJNZ R7,logicLow;

SJMP start
