;FLOOD-IT
KBSCAN 	EQU $A1CB
LAST_LINE EQU 1504 
KEY_ESC EQU 3
KEY_B EQU 66
KEY_D EQU 68
KEY_E EQU 69
KEY_G EQU 71
KEY_H EQU 72
KEY_I EQU 73
KEY_L EQU 76
KEY_P EQU 80
KEY_Q EQU 81
KEY_R EQU 82
KEY_T EQU 84
KEY_U EQU 85
KEY_W EQU 87
KEY_2 EQU 50
KEY_5 EQU 53
KEY_EQUALS EQU 61
KEY_SLASH EQU 47
GREEN EQU 96
DARK_GREEN EQU 32
BLACK EQU 128
WHITE EQU 207
YELLOW EQU 159
BLUE EQU 175
LIGHT_BLUE EQU 223
RED EQU 191
VRAM EQU 1024
;PROG_LENGTH set END_DATA-START_DATA
	
	; .BIN FILE HEADER
;	.db 0x00	;
;	.dw PROG_LENGTH
;	.db 0x0E	; address to load prog into
;	.db 0x00

	ORG 0x0E00 ; START CODE HERE
START
;START_DATA: 
	LDU #0x7FFF ; setup user stack
	
	; set user stack to top of user ram
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LOOP TO FILL THE SCREEN WITH ALL 'A' CHARS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDD #0		; loop counter
	LDY #1024	; load addr to copy to
fill_loop_top:
	PSHS D		; save A (loop counter)
	JSR RND5	;GET RND COLOR
	LDX NEXTFIB-1
	LDA COLORS,X
	STA ,Y+	; copy char to location stored in Y increment Y
	PULS D	; restore A (loop counter)
	ADDD	#1 ; increment loop counter
	CMPD #480	; done (hit bottom of screen)?
	BNE fill_loop_top
	JSR DRAW_LEGEND
	
KB_LOOP:
	JSR KBSCAN  ; PUTS KEYCODE INTO A - 0 = NO KEY
	CMPA 0	
	BEQ KB_LOOP	; IF 0 (NO KEY), REPEAT LOOP
	;KEY WAS PRESSED
	CMPA #KEY_ESC
	BEQ DONE
	CMPA #KEY_H
	BNE @a
	JSR DRAW_INSTRUCTIONS
	;LDX CHARNUM 
@a	STA 0x0400  ; ,X  
	;STX CHARNUM
	JMP KB_LOOP
 
DONE:	
	LDA #128
	STA CLR_COLOR
	JSR CLS
	RTS ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PUTS THE NEXT FIBONACCI NUMBER IN A AND NEXTFIB
;NO REGISTERS AFFECTED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RND5:
	PSHS A
	;COMPUTE NEXT
	LDA FIB1
	ADDA FIB2
	STA NEXTFIB
	;SHIFT 2 INTO 1
	LDA FIB2
	STA FIB1
	;SHIFT NEW INTO 2
	LDA NEXTFIB
	STA FIB2
	;MASK OF LEFT BITS
;	ANDA RNDMASK
	CMPA #0
	BGE MODLOOP
	NEGA	; flip to pos
MODLOOP:
	CMPA #6
	BMI RNDDONE
	SUBA #6 ; SUBTRACT 5 OFF TO PUT NUMBER IN RANGE
	BRA MODLOOP
RNDDONE:
	STA NEXTFIB	
	PULS A
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DRAW_LEGEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DRAW_LEGEND:
	LDX #LEGEND
	LDY #LAST_LINE
	JSR STRCPY
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DRAW_INSTRUCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DRAW_INSTRUCTIONS:
	LDA #BLACK
	STA CLR_COLOR
	JSR CLS
	LDX #INSTRUCTIONS1
	LDY #VRAM
	JSR STRCPY
	LDX #INSTRUCTIONS2
	LDY #VRAM+32
	JSR STRCPY
	LDX #INSTRUCTIONS3
	LDY #VRAM+64
	JSR STRCPY
	LDX #INSTRUCTIONS4
	LDY #VRAM+96
	JSR STRCPY
	LDX #INSTRUCTIONS5
	LDY #VRAM+128
	JSR STRCPY
	LDX #INSTRUCTIONS6
	LDY #VRAM+160
	JSR STRCPY
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLS
;CLEARS SCREEN WITH COLOR STORED IN CLR_COLOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLS:
	PSHS D,X

	LDX #VRAM
@a 
	LDA CLR_COLOR 	
	STA ,X+
	TFR  X,D	; PUT X in D
	ADDD #1
	CMPD #1544 ; bottom of screen mem
	BNE @a
	TFR D,X	; PUT D back in X
	PULS X,D
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CLEAR_FLAGS
; SETS EACH OF THE 60 FLAG BYTES TO 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEAR_FLAGS:
	
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SAVE_BOARD
; THIS ROUTINE COPIES THE SCREEN MEMORY INTO
; GRAPHICS BUFFER 1. THIS IS REQUIRED PRIOR
; TO DISPLAYING THE HELP SCREEN SO THE BOARD
; STATE DOESN'T GET CLOBBERED.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SAVE_BOARD:
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STRCPY:
; SRC AND DEST NEED TO BE STORED IN X,Y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
STRCPY:
	PSHS A
@a	LDA ,X+
	CMPA 0
	BEQ STRCPY_DONE
	STA ,Y+
	BRA @a
STRCPY_DONE:
	PULS A
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; program data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	COLOR CODE ARRAY
COLORS:
	.db GREEN	; DARK GREEN
	.db BLACK
	.db WHITE
	.db BLUE 
	.db YELLOW 
	.db RED
;	RANDOM NUMBER STUFF
FIB1:		
	.db 1 ; 55
FIB2:
	.db 1 ; 89
	.db 0	;padding so we can load nextfib into  X (which is 16 bits)
NEXTFIB:	
	.db 1 
	.db 0	;padding so we can load nextfib into  X (which is 16 bits)
RNDMASK .db %00000111
STRCPYSRC:
	.dw 0x00
STRCPYDEST:
	.dw 0x00
CLR_COLOR .db 32	
LEGEND:	
	.STRZ "MOVES   /25   H=HELP  BREAK=QUIT"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HELP SCREEN BUFFER.  THIS SECTION CONTAINS
;16 LINES OF 32 CHARACTERS.  WHEN THE HELP SCREEN IS
;DISPLAYED THE CONTENTS OF THIS MEMORY AND THE VRAM
;WILL BE SWITCHED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
INSTRUCTIONS1:
	.STR "THE OBJECTIVE IS TO MAKE THE "	
INSTRUCTIONS:
	.STR "SCREEN ALL ONE COLOR.  YOU CAN"
INSTRUCTIONS3:
	.STR "DO THIS BY STRATEGICALLY"
INSTRUCTIONS4:
	.STR "BUCKET FILLING THE TOP LEFT"
INSTRUCTIONS5:
	.STR "SQUARE. HOWEVER, YOU ONLY HAVE"
INSTRUCTIONS6:
	.STR "25 TURNS, SO CHOOSE YOUR MOVES"
INSTRUCTIONS7:
	.STR "WISELY. USE THE FOLLOWING KEYS"
INSTRUCTIONS8:	
	.STR "X KEY = BLACK. B=BLUE"
INSTRUCTIONS9:
	.STRZ "W KEY = WHITE. C=CYAN"
INSTRUCTIONS10:
	.STRZ "G KEY = GREEN. Y=YELLOW"
INSTRUCTIONS_11:
	.STRZ "PRESS SPACE TO RETURN TO GAME."
	
MARKED_FLAGS:
	;.resb 60 ; (32 * 15)/8

	END START