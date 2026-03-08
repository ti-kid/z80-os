;Returns keycode or 0 if none
;Inputs:
;	None
;Ouputs:
;	A has keycode
getKey:
	push hl
	push bc
		ld bc,$0808
		ld hl,keygroups
getkey_loop1:
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

		out (1),a
		in a,(1)

getkey_loop2:
		add a,a
		jr nc,done_key
		dec c
		jr nz,getkey_loop2

		ld c,8
		djnz getkey_loop1

		ld a,$FF
	pop bc
	pop hl
	ret

done_key:
		dec b
		ld a,b
		add a,a
		add a,a
		add a,a
		or c
	pop bc
	pop hl
	ret

keygroups:
.db $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f

;Waits till all keys are let go
;Inputs:
;	None
;Outputs:
;	No keys are pressed
flushkeys:
    push af
    push bc
    ; Done in a loop; runs far too fast on actual hardware
        ld b, $80
flsuh:      xor a
        out (1), a
        nop \ nop
        in a, (1)
        inc a
        jr nz, flsuh
        djnz flsuh
    pop bc
    pop af
    ret
;Gets an Ascii charectar
;Inputs:
;	None
;Outputs:
;	A has ascii char
getAscii:
        push hl
        push de
loop:
        ld hl,key_mode
        call getKey
        or a
        jr z,loop
        call flushkeys
        cp $30
        jr z,alpha_key
        cp $38
        jr z,second_key
        cp 9
        jr z,enter_key
        cp 15
        jr z,clear_key
        push af
        ld a,(hl)
        or a
        jr z,regular_kp
        dec a
        jr z,alpha_kp
        dec a
        jr z,sec_kp
sec_n_al_key:
        ld hl,sec_al_table
        jr shared_kp
sec_kp:
        pop af
        jr loop
alpha_kp:
        ld hl,alpha_table
        jr shared_kp
regular_kp:
        ld hl, regular_table
shared_kp:
        pop af
        dec a
        ld d,0
        ld e,a
        add hl,de
        ld a,(hl)
        or a
        jr z,loop
        pop de
        pop hl
        ret
alpha_key:
        ld a,1
        xor (hl)
        ld (hl),a
        jr loop
second_key:
        ld a,2
        xor (hl)
        ld (hl),a
        jr loop
enter_key:
        ld a,'\n'
        pop hl
        ret
clear_key:
        xor a
        ld (hl),a
        jr loop
alpha_table:
        .db 0, 0, 0, 0, 0, 0, 0, 0
        .db "\0\"WRMH\0\0"
        .db "?;VQLG\0\0"
        .db ":ZUPKFC\0"
        .db " YTOJEB\0"
        .db "\0XSNIDA\0"
sec_al_table:
        .db 0, 0, 0, 0, 0, 0, 0, 0
        .db "\0'wrmh\0\0"
        .db "?;vqlg\0\0"
        .db ":zupkfc\0"
        .db " ytojeb\0"
        .db "\0XSNIDA\0"
regular_table:
        .db 0, 0, 0, 0, 0, 0, 0, 0
        .db "\0+-x/^\0\0"
        .db "_369)}]\0"
        .db ".258({[\0"
        .db "0147,\0\0\0\0"
        .db "\0\0\0\0><\0\0"
        .db 0,0,0,0,0,0,0,0
