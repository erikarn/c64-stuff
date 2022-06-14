
; start of screen memory - $0400 - $07e7
; start of basic area - $0800 -> $9fff
; color ram - $d800 -> $dbff

.define scinit $ff81
.define ioinit $ff84
.define chrin $ffcf
.define chrout $ffd2

Start:
	; Initialise the system defaults
	jsr scinit
	jsr ioinit

	; For now, just loop over and echo back to the
	; screen device what we input.
loop:
	jsr chrin
	jsr chrout
	jmp loop

