.binarymode Intel

.defpage $00, $4000, 0
.page 0

#define curCol $8000
#define curRow $8001
boot:
        jp Init
        .fill 038h - $, 0
        reti
        .fill 056h - $, 0
        .dw $A55A 

Init:
   di
   im 1
memInit:
   ld a,1
   out (6),a
   in a,(2)
   rlca
   ld a,$41
   jr nc,LowerModel
HigherModel:
   out (5),a
   ld a,$81
   out (7),a
   jr memDone
LowerModel:
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
    call putc
    ld a,$20
    call putc
    xor a
    ex af,af'
    ei
Loop:
    call getkey
    inc a
    jr c,Loop
    call DispHexA
    jr $

lcdDelay:
   call $+3
   nop
   ret

putc:
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


DispHexHL:
        push af
        ld a,h
        call DispHexA
        ld a,l
        call DispHexA
        pop af
        ret
DispHexA:
        push    af
        push    hl
        push    bc
        push    af
        rrca
        rrca
        rrca
        rrca
        call    dispha
        pop     af
        call      dispha
        pop     bc
        pop     hl
        pop     af
        ret
dispha:
        and     15
        cp      10
        jp      nc,dhlet
        add     a,48
        jp      dispdh
dhlet:
        add     a,55
dispdh:
        call   putc
        ret
