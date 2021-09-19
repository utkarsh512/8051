; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Display name and real-time clock on LCD display using mode switch
; In normal mode, display your name. On pressing the mode switch, the display to clock mode.
; On pressing the mode button once more, the display ; returns to normal mode (i.e., display your name). 
; It should be noted that the real time clock should get updated during the normal mode. 
;
; Instruction
; * Displaying name is the default mode
; * Press P2.7 to switch to real-time clock mode
; * Unpress P2.7 to switch to display name mode
; 
; Run this code with update frequency 100

org 0000H  

mov 70H, #030H
mov 71H, #030H
mov 72H, #030H
mov 73H, #030H

MOV 30H, #'U'
MOV 31H, #'T'
MOV 32H, #'K'
MOV 33H, #'A'
MOV 34H, #'R'
MOV 35H, #'S'
MOV 36H, #'H'

init:
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
  jnb P2.7, displayClock  ; if P2.7 is 1, diplay clock
  jb P2.7, displayName    ; else diplay name

main2:
  call updateClock
  jmp main

displayClock:
  ; display clock on LCD

  setb P1.3   ; data mode on
  mov A, 70H
  call sendCharacter
  mov A, 71H
  call sendCharacter
  mov A, 72H
  call sendCharacter
  mov A, 73H
  call sendCharacter
  call delayLarge
  call resetDisplay
  jmp main2

displayName:
  ; display name on LCD

  setb P1.3   ; data mode on
  mov A, 30H
  call sendCharacter
  mov A, 31H
  call sendCharacter
  mov A, 32H
  call sendCharacter
  mov A, 33H
  call sendCharacter
  mov A, 34H
  call sendCharacter
  mov A, 35H
  call sendCharacter
  mov A, 36H
  call sendCharacter
  call delayLarge
  call resetDisplay
  jmp main2

loop:
  MOV A, @R1          ; move data pointed to by R1 to A
  JZ finish           ; if A is 0, then end of data has been reached - jump out of loop
  CALL sendCharacter  ; send data in A to LCD module
  INC R1              ; point to next piece of data
  JMP loop            ; repeat
 
finish:
  jmp main2

updateClock:
  ; update clock state

  inc 73H                
  mov A, 73H
  cjne A, #03AH, finishUpdate         
  mov 73H, #030H           

  inc 72H                
  mov A, 72H             
  cjne A, #036H, finishUpdate        
  mov 72H, #030H           

  inc 71H                 
  mov A, 71H              
  cjne A, #03AH, finishUpdate         
  mov 71H, #030H          

  inc 70H                 
  mov A, 70H
  cjne A, #036H, finishUpdate        
  mov 70H, #030H           
  call finishUpdate

finishUpdate:
  call delayLarge
  jmp main

resetDisplay:
  ; reset LCD display
  ; Code = 0x01 = 0000 0001

  clr P1.3   ; instruction mode on

  clr P1.7   ; |
  clr P1.6   ; |
  clr P1.5   ; |
  clr P1.4   ; | high nibble set

  setb P1.2  ; | 
  clr P1.2   ; | negative edge

  clr P1.7   ; |
  clr P1.6   ; |
  clr P1.5   ; |
  setb P1.4  ; | low nibble set

  setb P1.2  ; |
  clr P1.2   ; | negative edge

  call delay
  ret

sendCharacter:
  ; display current character on the display

  mov C, ACC.7    
  mov P1.7, C    ; | 
  mov C, ACC.6   
  mov P1.6, C    ; |
  mov C, ACC.5    
  mov P1.5, C    ; |
  mov C, ACC.4    
  mov P1.4, C    ; | high nibble set

  setb P1.2      ; | 
  clr P1.2       ; | negative edge

  mov C, ACC.3    
  mov P1.7, C    ; | 
  mov C, ACC.2    
  mov P1.6, C    ; | 
  mov C, ACC.1    
  mov P1.5, C    ; |
  mov C, ACC.0   
  mov P1.4, C    ; | low nibble set

  setb P1.2      ; | 
  clr P1.2       ; | negative edge

  call delay      
  ret

delay:
  mov R0, #50
  DJNZ R0, $
  ret

delayLarge:
  mov R0, #150
  DJNZ R0, $
  ret


