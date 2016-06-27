;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFINITIONS FOR WORKING WITH SOUND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BEEP_SUB	EQU  $A951		; Produces Beep of length B, pitch in $008c
BEEP_FREQ	EQU $008C
PIA_CTRL1 		EQU $FF01  		; BIT 
PIA_CTRL2 		EQU $FF03  		; BIT 
PIA_DATA  		EQU $FF20 		;  PIA DATA BYTE
PIA_SND_ENABLE 	EQU $FF23	

;A_6; 60 = A#
; 64 = A (880 HZ)
; 69 = G# (830 HZ)
; 73 = G (783 HZ)
; 78 = F# (749 HZ)
; 83 = F (698 HZ)
; 88 = E (659 HZ)
; 94 = D# (622 HZ)
; 100 = D (587 HZ)
; 106 = C# (55 4HZ)
; 110 = Middle C (523 HZ)
; 120 = B
;AS_4 EQU 127; = A#
;A_4 EQU #135; A (440HZ)