; Author: Utkarsh Patel (18EC35034)
; 
; Specification:
; Using the keypad, enter your date of birth (DD/MM/YYYY format), transmit it on serial port,
; receive it on serial port and display on the LCD
; 
; Run this code with update frequency 1000

startReading:
  MOV R7, #0          ; number of keys read till now

loopRead:
  CJNE R7, #8, scanKey   ; reading 8 characters (DD/MM/YYYY)
  JMP configTransmission

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

  JMP loopRead 

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
  ; the keys identified from keypad are stored in RAM starting from 30H to 37H
  MOV A, #30H
  ADD A, R7           ; A contains address to store current key
  MOV R1, A           ; copying the address to R1
  MOV A, R0           ; copying identified key to A
  MOV @R1, A          ; writing the key to corresponding address
  INC R7              ; increment key counter
  JMP loopRead

configTransmission:
  ; trasmitting the stored keys via UART

  ; dictionary mapping for keys
  MOV 38H, #0         ; | as DOB is 8 char long (stored in 30H to 37H)
                      ; | make 38H null-terminated

  MOV 40H, #'#'       ; key value for R0 = 0x00
  MOV 41H, #'0'       ; key value for R0 = 0x01
  MOV 42H, #'*'       ; key value for R0 = 0x02
  MOV 43H, #'9'       ; key value for R0 = 0x03
  MOV 44H, #'8'       ; key value for R0 = 0x04
  MOV 45H, #'7'       ; key value for R0 = 0x05
  MOV 46H, #'6'       ; key value for R0 = 0x06
  MOV 47H, #'5'       ; key value for R0 = 0x07
  MOV 48H, #'4'       ; key value for R0 = 0x08
  MOV 49H, #'3'       ; key value for R0 = 0x09
  MOV 4AH, #'2'       ; key value for R0 = 0x0A
  MOV 4BH, #'1'       ; key value for R0 = 0x0B

  ; configuring for transmission
  CLR SM0             ; |
  SETB SM1            ; | put serial port in 8-bit UART mode

  MOV A, PCON         ; |
  SETB ACC.7          ; |
  MOV PCON, A         ; | set SMOD in PCON to double baud rate

  MOV TMOD, #20H      ; put timer 1 in 8-bit auto-reload interval timing mode
  MOV TH1, #243       ; put -13 in timer 1 high byte (timer will overflow every 13 us)
  MOV TL1, #243       ; put same value in low byte so when timer is first started it will overflow after 13 us
  SETB TR1            ; start timer 1

  MOV R0, #0          ; number of characters transmitted till now

initTransmission:
  CJNE R0, #8, loopTransmission  ; transmitting 8 characters
  JMP configReceiver             ; if 8 characters are transmitted, configure receiver

loopTransmission:
  MOV A, #30H             ; |
  ADD A, R0               ; | correct address to read current key
  MOV R1, A               ; |
  MOV A, @R1              ; |
  ADD A, #40H             ; |
  MOV R1, A               ; |
  MOV A, @R1;             ; | decoding key value from key index

  JZ configReceiver       ; if A contains null value, stop transmission and configure receiver
  MOV SBUF, A             ; move data to be sent to the serial port
  INC R0                  ; increment R0 to point at next byte of data to be sent 
  JNB TI, $               ; wait for TI to be set, indicating serial port has finished sending byte
  CLR TI                  ; clear TI
  JMP initTransmission

configReceiver:
  SETB REN                ; enable serial port receiver
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
