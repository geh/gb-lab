; Program:   Random Walk (1 object at a time)
; Author:    Guillaume Hoffmann
; Date:      2026
;
; Description:
;   Shows 40 objects on screen.
;   On each new frame, one object moves into one random direction.
;   Relies on a simple random number generator function to decide
;   which direction to move.
;   This program is non-interactive (does not use inputs).
;
; Exercises:
;   1. Implement a ShadowOAM / OAM separation and a fast copy function
;      to update all objects coordinates before VBlank, and copy
;      ShadowOAM to OAM during VBlank.
;   2. Prevent objects for moving off-screen. If movement would take
;      them outside, you can either choose a different direction, or
;      do nothing (easier).

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 10 ; must be 1 to 40

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld a,%11111100 ; black and white palette
  ld [rOBP0], a

  call   CopyTilesToVRAM
  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   InitializeObjects

; LCD on, enable object layer (no background)
  ld a, LCDC_ON | LCDC_OBJ_ON
  ld [rLCDC], a

MainLoop:
  call WaitVBlank

  ld hl, STARTOF(OAM)
  ld a, [select]
  add a
  add a ; select * 4
  ld d,0
  ld e,a
  add hl,de ; point to one object
  call RandomStep
  
  ; now increment select
  ld a,[select]
  inc a
  cp OBJCOUNT
  jr nz, .skip
  ld a,0
.skip:
  ld [select],a

  jp MainLoop

SECTION "Functions", ROM0
InitializeObjects:
  ld hl,   STARTOF(OAM)   ; hl points to first object entry
  ld b,    OBJCOUNT
.init:
  ld a,75
  ld [hl], a           ; set Y coordinate
  inc      hl
  ld a,75
  ld [hl], a           ; set X coordinate
  inc      hl
  inc      hl
  inc      hl
  dec      b
  jr nz, .init
  ret

CopyShadowOAMtoOAM:
  ; TODO
  ret

RandomStep:
; input: HL: points to OAM entry
; modifies HL
  call Random2bits
  jr z, .left
  cp 1
  jr z, .up
  cp 2
  jr z, .right
.down
  inc [hl]
  ret
.left
  inc hl
  dec [hl]
  ret
.up
  dec [hl]
  ret
.right
  inc hl
  inc [hl]
  ret

Random2bits:
  push bc
  call RandomByte
  ld b,a

  swap a         ; swap nibbles
  xor b          ; XOR high and low nibbles
  ld b,a
  rrca
  rrca           ; shift right 2
  xor b          ; mix more
  and %00000011  ; keep 2 bits
  pop bc
  ret
  
RandomByte:
; Return a "random" byte into A
; by mixing a few values with XOR
  ld a,[rDIV]
  xor b
  xor l
  xor [hl]
  ret

WaitVBlank:
  ld a, [rLY]
  cp 144
  jr nz, WaitVBlank
  ret

ResetOAM:
; input: HL: location of OAM or Shadow OAM
  ld b,40*4
  ld a,0
.loop:
  ld [hl+],a
  dec b
  jr nz,.loop
  ret

CopyTilesToVRAM:
  ld de, Tiles
  ld hl, STARTOF(VRAM)
  ld bc, TilesEnd - Tiles
.copy:
  ld a,[de]
  inc de
  ld [hl+],a
  ld [hl+],a
  dec bc
  ld a,b
  or c
  jr nz, .copy
  ret

SECTION "Data", ROM0
Tiles:
; ID 0: smiling face
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
select: DS 1
