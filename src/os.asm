.binarymode Intel

.defpage $00, $4000, 0
.defpage $0A, $4000, $4000
.defpage $39, $4000, $4000
.defpage $3C, $4000, $4000
.page 0

#define curCol $8100
#define curRow $8101
#define kernelGarbage $8000
#define key_mode $8102
;;;;;;;;;;
;; System And Memory
;;;;;;;;;;

;Completly restarts system, waits for on, and setups memory and LCD.
;Inputs:
;	None
;Outputs:
;	Int mode 1
;	Memory Setup
;	LCD On
boot:
	jr init
	 
	.fill 038h - $, 0

;System interrupt.
;Inputs:
;	None
;Outputs:
;	None
sysInt:
	reti

	.fill 056h - $, 0
	.dw $A55A 


init:
	ld a,1
	out (6),a
	in a,(2)
	rlca
	ld a,$41
	jr nc,lowerModel
higherModel:
	out (5),a
	ld a,$81
	out (7),a
	jr memDone
lowerModel:
	out (6),a
	out (7),a
memDone:
	ld sp,0
	call sleep
	call lcdInit
;This loads init and runs it (or atleast in the furute it will)
;Inputs:
;	None
;Outputs:
;	System startup screen
startup:
	ld a,'H'
	call putChar
	inc a
	call putChar
	ld a,$20
	call putChar
Loop:
	jr $
;;;;;;;;;;
;; LCD and Display
;;;;;;;;;;


#include "util.asm"
#include "display_and_text.asm"
#include "input.asm"
#include "flash.asm"
#include "file.asm"
.echo "\n\n",$,"\n\n"

.page $0A
.db $57
.fill $4100 - $
.db $68

.page $39
.dw $7FFF
.db "init" , 255, 0
.fill $7F00-$
.db 'F'
.db fileType, "init", 255, 255, 255, 255
.dw $D00

.page $3C
#include "privledged.asm"
