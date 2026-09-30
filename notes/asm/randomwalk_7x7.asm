; Program:   Random Walk
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Shows 40 moving objects on screen.
;   Relies on ShadowOAM / OAM separation and a fast copy function
;   to update all objects coordinates on time during VBlank.
;   Relies on a simple RNG (Random Number Generation) function to decide
;   which direction to move each object.
;   This program is non-interactive (does not use inputs).
;
; Exercises:
;   1. Initialize all objects to the same coordinates.
;   2. Experiment with the RandomByte function to make the overall state
;      look more unpredictable.
;   3. Prevent objects for moving off-screen. If movement would take
;      them outside, you can either choose a different direction, or
;      do nothing (easier).
;   4. Modify UpdateObjects so that only *one* object moves on each frame.
;      The object is chosen randomly. Make sure that your program does not
;      contain "magic values", in particular use OBJCOUNT whenever it is
;      meaningful. Your program must work for all values of OBJCOUNT
;      from 1 to 40.

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 40

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
  ld     hl, ShadowOAM
  call   ResetOAM
  call   InitializeObjects

; LCD on, enable object layer (no background)
  ld a, LCDC_ON | LCDC_OBJ_ON
  ld [rLCDC], a

MainLoop:
  call UpdateObjects
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop

SECTION "Functions", ROM0
InitializeObjects:
  ld hl,   ShadowOAM   ; hl points to first object entry
  ld b,    OBJCOUNT
.init:
  ld a,75
  ld [hl], a           ; Y
  inc      hl
  ld a,75
  ld [hl], a           ; X
  inc      hl
  inc      hl
  inc      hl
  dec      b
  jr nz, .init
  ret

CopyShadowOAMtoOAM:
  ld hl, ShadowOAM
  ld de, STARTOF(OAM)
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

UpdateObjects:
  ld hl,ShadowOAM
  ld b, OBJCOUNT
.loop
  push hl
  call Random2bits
  jr z, .moveLeft
  cp 1
  jr z, .moveUp
  cp 2
  jr z, .moveRight
.moveDown
  inc [hl]
  jr .next
.moveLeft
  inc hl
  dec [hl]
  jr .next
.moveUp
  dec [hl]
  jr .next
.moveRight
  inc hl
  inc [hl]
.next
  pop hl
  inc hl
  inc hl
  inc hl
  inc hl
  dec b
  jr nz, .loop
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
  ld [hl],a
  inc hl
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
  ld [hl],a
  inc hl
  ld [hl],a
  inc hl
  dec bc
  ld a,b
  or c
  jr nz, .copy
  ret

SECTION "Data", ROM0
Tiles:
; ID 0: smiling face
 DB %01111100
 DB %10000010
 DB %10101010
 DB %10000010
 DB %10111010
 DB %10000010
 DB %01111100
 DB %00000000
TilesEnd:

SECTION "Variables", WRAM0
ShadowOAM: DS 160 
