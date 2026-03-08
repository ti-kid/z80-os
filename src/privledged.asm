    rst 0 ; Crash before runaway code breaks things

	jp _unlockFlash ;$4001
	jp _lockFlash ;$4004

_unlockFlash:
	ld a,i
	ld a, i
	push af
	di
	ld a, 1
	nop
	nop
	im 1
	di
	out ($14), a
	pop af
	ret po
	ei
	ret
    
_lockFlash:
	ld a, i
	ld a, i
	push af
	di
	xor a
	nop
	nop
	im 1
	di
	out ($14), a
	pop af
	ret po
	ei
	ret
