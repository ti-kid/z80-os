#define fileStartP 4
#define fileEndP $39
#define totalSectors (fileEndP - fileStartP + 1) * $40
#define fileType $1F
#define dirType $7F
;Puts the Sector in $4000-$7FFF
;Inputs;
;	HL is sector num
;Outputs:
;	HL is addr an bankA has the sector somewhere init
openSector:
	push bc
	push af
		ld b,6
		xor a
openSect_loop:
		srl h
		rr l
		rra
		djnz openSect_loop
		rra \ rra
		add a,$40
		ld h,a
		ld a,l
		add a,4
		out (6),a
		ld l,0
	pop af
	pop bc
	ret

;Checks if the filesystem has been installed
;Inputs:
;	None
;Outputs:
;	A is 0 if valid, non-zero for invalid
checkFileSystem:
	push ix
	push af
	push de
		in a,(6)
		push af
			ld ix, totalSectors-1
			;call getSector
			ld a,ixh
			out (6),a
			ld a,ixl
			ld h,a
			ld l,0
			ld a,(hl)
			sub 'F'
			ld (kernelGarbage),a
		pop af
		out (6),a
	pop de
	pop af
	pop ix
	ld a,(kernelGarbage)
	ret

