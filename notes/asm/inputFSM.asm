; Program:   Combo with arrow keys
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Interactive program of moving an object around with a secret feature.
;   By entering the sequence up, up, down, down, left, right, left, right,
;   the displayed sprite is inverted.
;   Program is interactive.


INCLUDE "hardware.inc"

DEF DOWN  EQU %10000000
DEF UP    EQU %01000000
DEF LEFT  EQU %00100000
DEF RIGHT EQU %00010000

SECTION "Variables", WRAM0
shadowOAM: DS 40*4 
previous: DS 1
current:  DS 1
fsmState: DS 1

SECTION "Header", ROM0[$100]
  jp EntryPoint
  DS $150 - @, 0 ; Make room for the header

EntryPoint:
  ld a,0
  ld [fsmState],a

  call waitVBlank
  ld a, 0
  ld [rLCDC], a

  ld a,%11111100 ; set a black and white palette
  ld [rOBP0], a

  ld de, Tiles
  ld hl, _VRAM
  ld bc,TilesEnd - Tiles
  call copyMem

  ld hl,_OAMRAM
  ld b, 40*4
  call clearMem

  ld hl,shadowOAM
  ld b, 40*4
  call clearMem

  ld a,50
  ld [shadowOAM],a
  ld [shadowOAM+1],a
 
; turn LCD on, only enable object layer (no background)
; see https://gbdev.io/pandocs/LCDC.html
  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call readKeys
  call updateFSM
  call updateObject
  call waitVBlank
  call copyShadowOAMtoOAM
  jp MainLoop

SECTION "Routines", ROM0
copyMem:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, copyMem
        ret

clearMem:
  ld a, 0
.loop:
  ld [hli], a
  dec b
  jp nz,.loop
  ret

waitVBlank:
.wait:
  ld a, [rLY]
  cp 144
  jp nz, .wait
  ret

copyShadowOAMtoOAM:
  ld hl,shadowOAM
  ld de,_OAMRAM
  ld b, 40
.loop:
  ldi a,[hl]
  ld [de],a
  inc e
  ldi a,[hl]
  ld [de],a
  inc e
  ldi a,[hl]
  ld [de],a
  inc e
  ldi a,[hl]
  ld [de],a
  inc e
  dec b
  jr nz, .loop
  ret

updateObject:
  ld hl, current
  bit 7, [hl]  ; checks for DOWN key pressed
  call nz,move_down
  ld hl, current
  bit 6, [hl]  ; checks for UP key pressed
  call nz,move_up
  ld hl, current
  bit 5, [hl]  ; checks for LEFT key pressed
  call nz,move_left
  ld hl, current
  bit 4, [hl]  ; checks for RIGHT key pressed
  call nz,move_right
  ret

move_up:
  ld hl,shadowOAM ; y of 1st OBJ
  dec [hl]
  ret

move_down:
  ld hl,shadowOAM ; y of 1st OBJ
  inc [hl]
  ret

move_left:
  ld hl,shadowOAM+1 ; x of 1st OBJ
  dec [hl]
  ret

move_right:
  ld hl,shadowOAM+1 ; x of 1st OBJ
  inc [hl]
  ret

updateFSM:
  ld a,[fsmState]
  cp 8
  jp z, .done
  ld hl, fsmTransition
  ld d,0
  ld e,a
  add hl,de
  ld b,[hl]     ; key that should be pressed to go to next state
  ld a,[current]
  cp b
  jp nz, .else
  ld hl,fsmState
  inc [hl]
  ret
.else:
  or a   ; if no key pressed, stay in same state
  ret z
  ld a,0
  ld [fsmState],a  ; come back to reset state
  ret
.done:
  ld hl,_OAMRAM+3
  set 6, [hl]
  ld hl,_OAMRAM+2
  ld [hl],0
  ret

SECTION "Data", ROM0
fsmTransition:
  DB UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT

;-------------------------------------------------------------------------------
readKeys:
;-------------------------------------------------------------------------------
; this function returns two different values in b and c registers:
; b - returns raw state (pressing key triggers given action continuously as long as it's pressed - it does not prevent bouncing)
; c - returns debounced state (pressing key triggers given action only once - key must be released and pressed again)

        ld      a,$20
        ldh     [rP1],a   
        ldh     a,[rP1]
        ldh     a,[rP1]
	cpl
        and     $0f         ; lower nibble has down, up, left, right
	swap	a           ; becomes high nibble
	ld	b,a
        ld      a,$10
        ldh     [rP1],a
        ldh     a,[rP1]
        ldh     a,[rP1]
        ldh     a,[rP1]
        ldh     a,[rP1]
        ldh     a,[rP1]
        ldh     a,[rP1]
	cpl
        and     $0f         ; lower nibble has start, select, B, A
	or	b
        ld      b,a

	ld	a,[previous]			; this is when important part begins, load previous P15 & P14 state
	xor	b				; result will be 0 if it's the same as current read
	and	b				; keep buttons that were pressed during this read only
	ld	[current],a			; store final result in variable and register
	ld	c,a
	ld	a,b				; current P15 & P14 state will be previous in next read
	ld	[previous],a

	ld	a,$30				; reset rP1
        ldh     [rP1],a
	ret

SECTION "TilesData", ROM0

Tiles:
; tile id 0 ; smiling face
 DB %01111110,%00000000
 DB %10000001,%00000000
 DB %10100101,%00000000
 DB %10000001,%00000000
 DB %10100101,%00000000
 DB %10011001,%00000000
 DB %10000001,%00000000
 DB %01111110,%00000000
TilesEnd:
