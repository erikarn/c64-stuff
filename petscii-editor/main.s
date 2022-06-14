
; start of screen memory - $0400 - $07e7
; start of basic area - $0800 -> $9fff
; color ram - $d800 -> $dbff

.define scinit $ff81
.define ioinit $ff84
.define chrin $ffcf
.define getin $ffe4
.define chrout $ffd2

.define vic_background $d021
.define vic_border $d020

Start:
	; Initialise the system defaults
	jsr scinit
	jsr ioinit

	; For now, just loop over and echo back to the
	; screen device what we input.

app_loop:
	; read a character
	jsr getin

	; let's handle the key input filtering here; anything
	; else can just go straight to display_and_loop

	; cursor key - don't allow scrolling up or down, make
	; sure our window stays fixed!

	; f1 - save
	cmp #$85

	; f2 - load
	cmp #$89

	; f3
	cmp #$86

	; f4
	cmp #$8a

	; f5 - cycle background
	cmp #$87
	beq menu_f5

	; f6 - cycle border
	cmp #$8b
	beq menu_f6

	; f7
	cmp #$88

	; f8
	cmp #$8c

display_and_loop:
	jsr chrout
	jmp app_loop

menu_f5:
	jsr cycle_background
	jmp app_loop

menu_f6:
	jsr cycle_border
	jmp app_loop

cycle_background:
	lda background_color
	adc #$01
	and #$0f
	sta background_color
	sta vic_background
	rts

cycle_border:
	lda border_color
	adc #$01
	and #$0f
	sta border_color
	sta vic_border
	rts

border_color:
.byte 14
background_color:
.byte 6

