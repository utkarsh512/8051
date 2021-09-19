; Author: Utkarsh Patel (18EC35034)
; 
; Specification: Real time clock on LCD diplay unit
; Design a digital clock and display its output on LCD display unit. The clock should show the time in mm-ss format.
; It updates time automatically using the timer interrupt of the microcontroller. 
; 
; Run this code with update frequency 100

org 0000H  

mov 30H, #030H
mov 31H, #030H
mov 32H, #030H
mov 33H, #030H

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
  call delayLarge
  call displayClock
  call delayLarge
  call updateClock
  jmp main

displayClock:
  ; display clock on the LCD display

  setb P1.3 ; data mode on
  mov A, 30H
  call sendCharacter
  mov A, 31H
  call sendCharacter
  mov A, 32H
  call sendCharacter
  mov A, 33H
  call sendCharacter
  ret

updateClock:
  ; updating value of the clock

  inc 33H                
  mov A, 33H
  cjne A, #03AH, finishUpdate         
  mov 33H, #030H           

  inc 32H                
  mov A, 32H             
  cjne A, #036H, finishUpdate        
  mov 32H, #030H           

  inc 31H                 
  mov A, 31H              
  cjne A, #03AH, finishUpdate         
  mov 31H, #030H          

  inc 30H                 
  mov A, 30H
  cjne A, #036H, finishUpdate        
  mov 30H, #030H           
  ret

finishUpdate: 
  ; finsh updating clock

  call delay
  jmp resetDisplay

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
  ; diplsay current time on LCD display

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
  ; delay for internal LCD operation
  mov R0, #50
  DJNZ R0, $
  ret

delayLarge:
  ; delay for displaying
  mov R0, #150
  DJNZ R0, $
  ret


