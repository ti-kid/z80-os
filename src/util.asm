
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

;Unallocates all memory for usage
;Inputs:
;	None
;Ouputs:
;	Memory is zero'd except for $FFFF and $FFFE
;	Unfortunatly, I dont know how I would save registers.
;	So it destorys all regs
restartMemory:
	ret
	xor a
	ld hl,$8000
	ld de,$8001
	ld bc,$$7000
	ld (hl),a
	ldir
	ret
;A general error routine for debugging
;Inputs:
;	A is the "return val"
;Outputs:
;	Prints "YAAAY" if A is 0 else "AWWW"
errorPrint:
	push hl
		or a
		jr z,yaay
aww:
		ld hl,bad_s
		call putString
		jr errExit
yaay:
		ld hl,good_s
		call putString
errExit:
	pop hl
	ret
bad_s: .db " AWW ",0
good_s: .db "YAAY",0
