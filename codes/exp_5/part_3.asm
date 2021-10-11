; Author: Utkarsh Patel (18EC35034)
; 
; Specification:
; Transmit the corresponding month in a year on serial port and display it on LCD after
; receiving it on serial port. For example, for key '1' LCD output is January,
; key '12' LCD output is December
; 
; Run this code with update frequency 1000

scanKey:
  MOV R0, #0          ; | R0 stores the key number being checked
                      ; | and will be locked when a pressed key is detected

  CLR F0;             ; reset flag to indicate scanning is initiated

  SETB P0.3           ; row3 has been checked
  CLR P0.0            ; start checking row0
  CALL colscan        ; checking columns
  JB F0, keyfound     ; key press identified

  SETB P0.0           ; row0 has been checked
  CLR P0.1            ; start checking row1
  CALL colscan        ; checking columns
  JB F0, keyfound     ; key press identified

  SETB P0.1           ; row1 has been checked
  CLR P0.2            ; start checking row2
  CALL colscan        ; checking columns
  JB F0, keyfound     ; key press identified

  SETB P0.2           ; row2 has been checked
  CLR P0.3            ; start checking row3
  CALL colscan        ; checking columns
  JB F0, keyfound      ; key press identified

  JMP scanKey

colscan:
  JB P0.4, colscan2
  SETB F0
  JNB P0.4, $
  RET

colscan2:
  INC R0
  JB P0.5, colscan3
  SETB F0
  JNB P0.5, $
  RET

colscan3:
  INC R0
  JB P0.6, colnotfound
  SETB F0
  JNB P0.6, $
  RET

colnotfound:
  INC R0
  RET
       

keyfound:
  MOV A,R0;
  MOV R1,A;

decodeMonth:
  CJNE R1, #0, feb
  MOV 40H, #'J'
  MOV 41H, #'A'
  MOV 42H, #'N'
  MOV 43H, #'U'
  MOV 44H, #'A'
  MOV 45H, #'R'
  MOV 46H, #'Y'
  MOV 47H, #0
  JMP configTransmission

feb:
  CJNE R1, #1, march
  MOV 40H, #'F'
  MOV 41H, #'E'
  MOV 42H, #'B'
  MOV 43H, #'R'
  MOV 44H, #'U'
  MOV 45H, #'A'
  MOV 46H, #'R'
  MOV 47H, #'Y'
  MOV 48H, #0
  JMP configTransmission

march:
  CJNE R1, #2, april
  MOV 40H, #'M'
  MOV 41H, #'A'
  MOV 42H, #'R'
  MOV 43H, #'C'
  MOV 44H, #'H'
  MOV 45H, #0
  JMP configTransmission

april:
  CJNE R1, #3, may
  MOV 40H, #'A'
  MOV 41H, #'P'
  MOV 42H, #'R'
  MOV 43H, #'I'
  MOV 44H, #'L'
  MOV 45H, #0
  JMP configTransmission

may:
  CJNE R1, #4, june
  MOV 40H, #'M'
  MOV 41H, #'A'
  MOV 42H, #'Y'
  MOV 43H, #0
  JMP configTransmission

june:
  CJNE R1, #5, july
  MOV 40H, #'J'
  MOV 41H, #'U'
  MOV 42H, #'N'
  MOV 43H, #'E'
  MOV 44H, #0
  JMP configTransmission

july:
  CJNE R1, #6, august
  MOV 40H, #'J'
  MOV 41H, #'U'
  MOV 42H, #'L'
  MOV 43H, #'Y'
  MOV 44H, #0
  JMP configTransmission

august:
  CJNE R1, #7, september
  MOV 40H, #'A'
  MOV 41H, #'U'
  MOV 42H, #'G'
  MOV 43H, #'U'
  MOV 44H, #'S'
  MOV 45H, #'T'
  MOV 46H, #0
  JMP configTransmission

september:
  CJNE R1, #8, october
  MOV 40H, #'S'
  MOV 41H, #'E'
  MOV 42H, #'P'
  MOV 43H, #'T'
  MOV 44H, #'E'
  MOV 45H, #'M'
  MOV 46H, #'B'
  MOV 47H, #'E'
  MOV 48H, #'R'
  MOV 49H, #0
  JMP configTransmission

october:
  CJNE R1, #9, november
  MOV 40H, #'O'
  MOV 41H, #'C'
  MOV 42H, #'T'
  MOV 43H, #'O'
  MOV 44H, #'B'
  MOV 45H, #'E'
  MOV 46H, #'R'
  MOV 47H, #0
  JMP configTransmission

november:
  CJNE R1, #10, december
  MOV 40H, #'N'
  MOV 41H, #'O'
  MOV 42H, #'V'
  MOV 43H, #'E'
  MOV 44H, #'M'
  MOV 45H, #'B'
  MOV 46H, #'E'
  MOV 47H, #'R'
  MOV 48H, #0
  JMP configTransmission

december:
  MOV 40H, #'D'
  MOV 41H, #'E'
  MOV 42H, #'C'
  MOV 43H, #'E'
  MOV 44H, #'M'
  MOV 45H, #'B'
  MOV 46H, #'E'
  MOV 47H, #'R'
  MOV 48H, #0
  JMP configTransmission

configTransmission:
  CLR SM0             ; |
  SETB SM1            ; | put serial port in 8-bit UART mode

  MOV A, PCON         ; |
  SETB ACC.7          ; |
  MOV PCON, A         ; | set SMOD in PCON to double baud rate

  MOV TMOD, #20H      ; put timer 1 in 8-bit auto-reload interval timing mode
  MOV TH1, #243       ; put -13 in timer 1 high byte (timer will overflow every 13 us)
  MOV TL1, #243       ; put same value in low byte so when timer is first started it will overflow after 13 us
  SETB TR1            ; start timer 1

  MOV R0, #40H        ; number of characters transmitted till now

loopTransmission:
  MOV A, @R0
  JZ configReceiver   ; if A contains null value, stop transmission and configure receiver
  MOV SBUF, A         ; move data to be sent to the serial port
  JNB TI, $           ; wait for TI to be set, indicating serial port has finished sending byte
  CLR TI              ; clear TI
  INC R0              ; increment R0 to point at next byte of data to be sent
  JMP loopTransmission

configReceiver:
  SETB REN                ; enable serial port receiver
  MOV 50H, #0
  MOV 51H, #0
  MOV 52H, #0
  MOV 53H, #0
  MOV 54H, #0
  MOV 55H, #0
  MOV 56H, #0
  MOV 57H, #0
  MOV 58H, #0
  MOV 59H, #0
  MOV R0, #50H            ; characters received from serial port will be stored in RAM starting with address 50H 

initReceiver:
  JNB RI, $               ; wait for byte to be received
  CLR RI                  ; clear the RI flag 
  MOV A, SBUF             ; move received byte to A
  CJNE A, #0DH, loopReceiver ; compare it with 0DH - it it's not, skip next instruction
  JMP initLCD             ; if it is the terminating character, jump to the LCD module

loopReceiver:
  MOV @R0,A               ; move from A to location pointed to by R0
  INC R0                  ; increment R0 to point at next location where data will be stored
  JMP initReceiver

initLCD:
  call configureFor4BitOperation
  call incrementCursorMode
  call displayOnCursonOnBlinkingOn
  call main


configureFor4BitOperation:  
  ; for configuring 4-bit operation in LCD

  clr P1.3     ; instruction flow mode

  clr P1.7     ; | 
  clr P1.6     ; |
  setb P1.5    ; |
  clr P1.4     ; | high nibble set

  setb P1.2    ; | 
  clr P1.2     ; | negative edge

  call delay   

  setb P1.2    ; |
  clr P1.2     ; | negative edge

  setb P1.7   

  setb P1.2    ; |
  clr P1.2     ; | negative edge

  call delay  

  ret 

incrementCursorMode:  
  ; for displaying next character on adjacent display
  ; Code = 0x06 = 0000 0110

  clr P1.3   ; instruction mode on

  clr P1.7   ; |  
  clr P1.6   ; | 
  clr P1.5   ; | 
  clr P1.4   ; | high nibble set 

  setb P1.2  ; | 
  clr P1.2   ; | negative edge 

  setb P1.6  ; | 
  setb P1.5  ; | low nibble set 

  setb P1.2  ; |
  clr P1.2   ; | negative edge

  call delay 

  ret

displayOnCursonOnBlinkingOn:
  ; turning on the display and cursor and choosing blinking
  ; Code = 0x0F = 0000 1111

  clr P1.3   ; instruction mode on

  clr P1.7   ; | 
  clr P1.6   ; |
  clr P1.5   ; | 
  clr P1.4   ; | high nibble set 

  setb P1.2  ; |  
  clr P1.2   ; | negative edge 

  setb P1.7  ; |
  setb P1.6  ; | 
  setb P1.5  ; | 
  setb P1.4  ; | low nibble set

  setb P1.2  ; |
  clr P1.2   ; | negative edge

  call delay 

  ret


main:
  SETB P1.3     ; clear RS - indicates that data is being sent to module
  MOV R1, #50H  ; data to be sent to LCD is stored in 8051 RAM, starting at location 30H
  acall loop

loop:
  MOV A, @R1          ; move data pointed to by R1 to A
  JZ finish           ; if A is 0, then end of data has been reached - jump out of loop
  CALL sendCharacter  ; send data in A to LCD module
  INC R1              ; point to next piece of data
  JMP loop            ; repeat

finish:
  JMP $

sendCharacter:
  MOV C, ACC.7    ; |
  MOV P1.7, C     ; |
  MOV C, ACC.6    ; |
  MOV P1.6, C     ; |
  MOV C, ACC.5    ; |
  MOV P1.5, C     ; |
  MOV C, ACC.4    ; |
  MOV P1.4, C     ; | high nibble set

  SETB P1.2       ; |
  CLR P1.2        ; | negative edge on E

  MOV C, ACC.3    ; |
  MOV P1.7, C     ; |
  MOV C, ACC.2    ; |
  MOV P1.6, C     ; |
  MOV C, ACC.1    ; |
  MOV P1.5, C     ; |
  MOV C, ACC.0    ; |
  MOV P1.4, C     ; | low nibble set

  SETB P1.2       ; |
  CLR P1.2        ; | negative edge on E

  CALL delay      ; wait for BF to clear

delay:
  MOV R0, #50
  DJNZ R0, $
  RET
