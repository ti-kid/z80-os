.binarymode Intel

.defpage $00, $4000, 0
.page 0

#define curCol $8000
#define curRow $8001

;Completly restarts system, waits for on, and setups memory and LCD.
;Inputs:
;	None
;Outputs:
;	Int mode 1
;	Memory Setup
;	LCD On
boot:
	ld hl,init
	push hl
	jp sleep
	 
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
;Turns off LCD and goes into Low Power Till On is pressed.
;Inputs:
;	None
;Outputs:
;	None
sleep:
	di
	im 1
	push af
		in a,(3) ;save interrupts
		push af
			ld a,2 ;lcd off
			out ($10),a
			ld a,1 ;On is the only int and low power mode is on
			out (3),a
			ei
			halt
			di
		pop af
		out (3),a
	pop af
	ret

init:
memInit:
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
lcdInit:
	ld a,$40
	out ($10),a
	call lcdDelay
	ld a,5
	out ($10),a
	call lcdDelay
	ld a,1
	out ($10),a
	call lcdDelay
	ld a,3
	out ($10),a
	call lcdDelay
	ld a,$90
	out ($10),a
	call lcdDelay
	ld a,$f3
	out ($10),a
	call lcdDelay
	ld a,$20
	out ($10),a
	call lcdDelay

	 ld a,'H'
	 call putChar
	 inc a
	 call putChar
	 ld a,$20
	 call putChar
Loop:
	 call getkey
	 inc a
	 jr c,Loop
	 call dispHexA
	 jr $

lcdDelay:
	call $+3
	nop
	ret

putChar:
	push af
		  push bc
		  push de
		  push hl
		  ld l,a

		  ld a,(curCol)

		  cp 16
		  jr nc,_putchar_err
		  
		  add a,$20
		  out ($10),a

		  ld a,(curRow)
		  
		  add a,a
		  add a,a
		  add a,a
		  
		  cp 56
		  jr nc,_putchar_err
		  add a,$80
		  out ($10),a
		  call lcdDelay

		  xor a
		  out ($10),a

		  ld a,l
		  sub $20
		  jr c,_putchar_err
		  ld l,a
		  ld h,0
		  add hl,hl
		  ld de,CHAR_MAP
		  add hl,de
		  ld e,(hl)
		  inc hl
		  ld d,(hl)
		  ld b,7
	 _putchar_loop:
		  ld a,(de)
		  inc de
		  out ($11),a
		  call lcdDelay
		  djnz _putchar_loop
		  ld hl,0
		  jr _putchar_exit
	 _putchar_err:
		  pop hl
		  pop de
		  pop bc
		  pop af
		  ret
	 _putchar_exit:
		  ld a,(curCol)
		  inc a
		  cp 16
		  jr c,_putchar_y_noinc
		  ld a,(curRow)
		  inc a
		  ld (curRow),a
		  xor a
	 _putchar_y_noinc:
		  ld (curCol),a
		  pop hl
		  pop de
		  pop bc
		  pop af
		  ret
#include "font.asm"



getkey:
	 ld bc,$0808
	 ld hl,keygroups
_getkey_loop1:
	 ld a,$FF
	 out (1),a
	 
	 push hl
	 push bc

	 ld c,b
	 dec c
	 ld b,0
	 add hl,bc

	 ld a,(hl)

	 pop bc
	 pop hl

	 call lcdDelay
	 
	 out (1),a
	 in a,(1)


_getkey_loop2:
	 add a,a
	 jr nc,_done_key
	 dec c
	 jr nz,_getkey_loop2

	 ld c,8
	 djnz _getkey_loop1

	 ld a,$FF
	 ret

_done_key:
	 dec b
	 ld a,b
	 add a,a
	 add a,a
	 add a,a
	 or c
	 ret

keygroups:
.db $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f


dispHexHL:
	push af
		ld a,h
		call dispHexA
		ld a,l
		call dispHexA
	pop af	
	ret
dispHexA:
	push af
	push hl
	push bc
		push af
			rrca
			rrca
			rrca
			rrca
			call dispha
		pop	af
		call dispha
	pop	bc
	pop	hl
	pop	af
	ret
dispha:
	and	15
	cp 10
	jp nc,dhlet
	add	a,48
	jp dispdh
dhlet:
	add	a,55
dispdh:
	call putChar
	ret
