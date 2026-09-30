; Program:   Move one object with arrow keys
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Displays one object and enable to move it with
;   the readKeys function.
;   Program is interactive.

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 1

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0 ; Make room for the header

EntryPoint:

  call waitVBlank

CopyTileDataToVRAM:
  ld de, Tiles
  ld hl, _VRAM
  ld bc,TilesEnd - Tiles
.copy:
  ld a,[de]
  inc de
  ld [hl+],a
  ld [hl+],a
  dec bc
  ld a,b
  or c
  jr nz, .copy

  ld a,%11111100 ; set a black and white palette
  ld [rOBP0], a

ResetOAM:
  ld hl, _OAMRAM
  ld b, 40*4
  ld a, 0
.loop:
  ld [hl+],a
  dec b
  jr nz,.loop

ResetShadowOAM:
  ld hl, shadowOAM
  ld b, 40*4
  ld a, 0
.loop:
  ldi [hl],a
  dec b
  jr nz,.loop

  ld a, 20
  ld [obj_y],a
  ld [obj_x],a
 
; turn LCD on, only enable object layer (no background)
; see https://gbdev.io/pandocs/LCDC.html
  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call readKeys
  call updateObject
  call UpdateShadowOAM
  call waitVBlank
  call copyShadowOAMtoOAM
  jp MainLoop

SECTION "Routines", ROM0
waitVBlank:
.wait:
  ld a, [rLY]
  cp 144
  jp nz, .wait
  ret

copyShadowOAMtoOAM:
  ld hl,shadowOAM
  ld de,_OAMRAM
  ld b, OBJCOUNT
.loop:
  ld a,[hl+]
  ld [de],a
  inc e
  ld a,[hl+]
  ld [de],a
  inc e
  ld a,[hl+]
  ld [de],a
  inc e
  ld a,[hl+]
  ld [de],a
  inc e
  dec b
  jr nz, .loop
  ret

updateObject:
; This function must be called after ReadKeys.
; To get the proper values in B and C.

  bit 7, b  ; checks for DOWN key pressed
  jr nz,.move_down
  bit 6, b  ; checks for UP key pressed
  jr nz,.move_up
  bit 5, b  ; checks for LEFT key pressed
  jr nz,.move_left
  bit 4, b  ; checks for RIGHT key pressed
  jr nz,.move_right
  ret
.move_up:
  ld hl,obj_y
  dec [hl]
  ret
.move_down:
  ld hl,obj_y
  inc [hl]
  ret
.move_left:
  ld hl,obj_x
  dec [hl]
  ret
.move_right:
  ld hl,obj_x
  inc [hl]
  ret

UpdateShadowOAM:
  ld a,[obj_y]
  ld [shadowOAM],a
  ld a,[obj_x]
  ld [shadowOAM+1],a
  ret

;-------------------------------------------------------------------------------
readKeys:
;-------------------------------------------------------------------------------
; this function returns two different values in b and c registers:
; b : raw state:   pressing key triggers given action continuously
;                  as long as it is pressed
; c : rising edge: pressing key triggers given action only once,
;                  key must be released and pressed again

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

	ld	a,[previous]  ; load previous P15 & P14 state
	xor	b	      ; result will be 0 if it's the same as current read
	and	b	      ; keep buttons that were pressed during this read only
	ld	[current],a   ; store final result in variable and register
	ld	c,a
	ld	a,b           ; current P15 & P14 state will be previous in next read
	ld	[previous],a

	ld	a,$30         ; reset rP1
        ldh     [rP1],a
	ret

SECTION "TilesData", ROM0

Tiles:
; tile id 0 ; smiling face
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110
TilesEnd:


SECTION "Variables", WRAM0
shadowOAM: DS 40*4 
previous: DS 1
current:  DS 1
obj_x: DS 1
obj_y: DS 1

