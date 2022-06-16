
; start of screen memory - $0400 - $07e7
; start of basic area - $0800 -> $9fff
; color ram - $d800 -> $dbff

.define scinit $ff81
.define ioinit $ff84
.define chrin $ffcf
.define getin $ffe4
.define chrout $ffd2
.define screen $ffed
.define cursor_plot $fff0

.define vic_background $d021
.define vic_border $d020

Start:
	jmp main

; clc (clear carry), sec (set carry)

border_color:
.byte 14
background_color:
.byte 6
scr_width:
.byte 39
scr_height:
.byte 24
cur_x:
.byte 0
cur_y:
.byte 0

main:
	; Initialise the system defaults
	jsr scinit
	jsr ioinit

	; get screen size
	jsr init_scr_size

	; For now, just loop over and echo back to the
	; screen device what we input.

app_loop:
	; Get the current screen cursor position
	jsr read_cursor_pos

	; read a character
	jsr getin

	; let's handle the key input filtering here; anything
	; else can just go straight to display_and_loop

	; cursor key - don't allow scrolling up or down, make
	; sure our window stays fixed!

	; return
	cmp #$0d
	beq app_loop
	; shift-return
	cmp #$8d
	beq app_loop

	; stop - $03
	; home - $13
	; delete - $14

	; run - $83
	; clear - $93
	cmp #$93
	; insert - $94

	; cursor down
	cmp #$11
	beq cursor_down

	; cursor right
	cmp #$1d
	beq cursor_right

	; cursor up
	cmp #$91

	; cursor left
	cmp #$9d

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

cursor_down:
	jsr handle_cursor_down
	jmp app_loop

cursor_right:
	jsr handle_cursor_right
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

; Handle cursor down.
;
; If we're on the bottom row then don't allow scrolling.
handle_cursor_down:
	jsr check_cursor_last_row
	bcs handle_cursor_down_end
	; Not the last row, allow it to the editor
	lda #$11
	jsr chrout
handle_cursor_down_end:
	rts

; Handle cursor right.
;
; If we're at the bottom right then we don't advance the
; cursor, that way the screen editor won't do silly things
; like scroll.
handle_cursor_right:
	jsr check_cursor_last_row
	bcc handle_cursor_right_ok
	jsr check_cursor_last_column
	bcs handle_cursor_right_end
handle_cursor_right_ok:
	lda #$1d
	jsr chrout
handle_cursor_right_end:
	rts

; Check to see if the cursor is at the last row.
; A, X, Y trashed.
; Set carry if it is, clear carry if not.
; Note: if it's at or past the last row it'll return true..
check_cursor_last_row:
	lda cur_y
	cmp scr_height
	rts

; Check to see if the cursor is at the last column.
; A ,X, Y trashed.
; Set carry if it is, clear carry if not.
; Note: if it's at or past the last column it'll return true..
check_cursor_last_column:
	lda cur_x
	cmp scr_width
	rts

; Initialise the screen geometry for cursor comparisons
init_scr_size:
	jsr screen
	; Store x-1, y-1 for easy edge comparisons
	dex
	dey
	stx scr_width
	sty scr_height
	rts

; Read cursor position.
; Cursor position is stored in cur_x, cur_y.
; All registers trashed.
read_cursor_pos:
	sec
	jsr cursor_plot
	stx cur_y
	sty cur_x
	rts


