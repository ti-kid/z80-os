
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

putString:
	push af
puts_loop:
		ld a,(hl)
		inc hl
		or a
		jr z,puts_exit
		cp 10
		jr nz,puts_regular
		xor a
		ld (curRow),a
		ld a,(curCol)
		inc a
		ld (curCol),a
		jr puts_loop
puts_regular:
		call putChar
		jr puts_loop
puts_exit:
	pop af
	ret
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
;Provides the necesarry delay to write to the LCD in 6mhz mode
;Inputs:
;	None
;Outputs:
;	LCD delay
lcdDelay:
	call $+3
	nop
	ret

;Sets Up The LCD and turns it ON
;Inputs:
;	None
;Outputs:
;	LCD working and On
lcdInit:
	push af
		ld a,$40
		out ($10),a
		call lcdDelay 
		ld a,5 ;Lcd Moves Down
		out ($10),a
		call lcdDelay
		ld a,1 ;8 bit mode
		out ($10),a
		call lcdDelay
		ld a,3 ;Turn ON
		out ($10),a
		call lcdDelay
		ld a,$f3 ;Contrast
		out ($10),a
		call lcdDelay
		ld a,$20 ;X = 0
		out ($10),a
		call lcdDelay
		ld a,$80 ;Y = 0
		pop af
	ret
