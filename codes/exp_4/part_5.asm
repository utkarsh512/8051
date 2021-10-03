; Author: Utkarsh Patel (18EC35034)
; 
; Specification: ADC output on LCD panel
; Using the ADC, convert a voltage (analog) into digital form.
; Display the output of the ADC on the LCD panel.
; 
; Run this code with update frequency 1000

org 0000H        ; reset vectors

MOV 30H, #'0'    ; storing ASCII values for digits
MOV 31H, #'1'
MOV 32H, #'2'
MOV 33H, #'3'
MOV 34H, #'4'
MOV 35H, #'5'
MOV 36H, #'6'
MOV 37H, #'7'
MOV 38H, #'8'
MOV 39H, #'9'

CLR P1.3         ; lcd instruction mode on

; configuring lcd 4-bit mode operation

CLR P1.7         ; |
CLR P1.6         ; |
SETB P1.5        ; |
CLR P1.4         ; | higher nibble value
CALL pass        ; negative edge on enable
CALL pass       
SETB P1.7        ; lower nibble value
CALL pass        ; negative edge on enable

; entry mode set

CLR P1.7         ; |      
CLR P1.6         ; |
CLR P1.5         ; |
CLR P1.4         ; | higher nibble value
CALL pass        ; negative edge on enable
SETB P1.6        ; |
SETB P1.5        ; | lower nibble value
CALL pass        ; negative edge on enable

; lcd display ON - cursor ON - blinking ON

CLR P1.6         ; |
CLR P1.5         ; | higher nibble value
CALL pass        ; negative edge on enable
SETB P1.7        ; |
SETB P1.6        ; |
SETB P1.5        ; |
SETB P1.4        ; | lower nibble value
CALL pass        ; negative edge on enable

SETB P1.3        ; lcd data mode on

CLR P3.7         ; turning ADC output ON
loop:
  CLR P3.6       ; |
  SETB P3.6      ; | postive edge on ADC WR to start conversion
  CALL delay     ; waiting for conversion to start and INTR to go high
  JB P3.2, $     ; waiting for the INTR to go low i.e completion of the conversion
  MOV A, P2      ; take the data from the ADC on P2 and send it to the accumulator
  
  ; converting the obtained value to BCD
  MOV B, #10
  DIV AB
  MOV R3, B
  MOV B, #10
  DIV AB
  MOV R2, B
  MOV R1, A

  ; R1:R2:R3 contains the BCD value, e.g. 5V -> 255 (digital value) -> R1 = 2, R2 = 5, R3 = 5
  CALL sendcharacter    ; displaying R1
  MOV A, R2
  CALL sendcharacter    ; displaying R2
  MOV A, R3
  CALL sendcharacter    ; displaying R3
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
  CALL delay;

  SETB P1.3       ; lcd data mode on
  JMP loop 

pass:             ; negative edge on enable
  SETB P1.2
  CLR P1.2
  MOV R7, #50     ; small delay for lcd buffer
  DJNZ R7, $
  RET

sendcharacter:    ; send data in accumlator to current address of DDRAM in LCD to display it
  ADD A, #30H
  MOV R1, A
  MOV A, @R1
  MOV C, ACC.7    ; |
  MOV P1.7, C     ; |
  MOV C, ACC.6    ; |
  MOV P1.6, C     ; |
  MOV C, ACC.5    ; |
  MOV P1.5, C     ; |
  MOV C, ACC.4    ; |
  MOV P1.4, C     ; | higher nibble value
  CALL pass       ; negative edge on enable
  MOV C, ACC.3    ; |
  MOV P1.7, C     ; |
  MOV C, ACC.2    ; |
  MOV P1.6, C     ; |
  MOV C, ACC.1    ; |
  MOV P1.5, C     ; |
  MOV C, ACC.0    ; |
  MOV P1.4, C     ; | lower nibble value
  CALL pass       ; negative edge on enable
  RET

delay:
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
