; Program:   Random Walk with Metaobjects (incomplete)
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Uses 40 objects to show 10 moving metaobjects on screen.
;   Movement is randomly decided as in the original random walk program.
;   Program is non-interactive.
;
; Exercises:
;   * Fill-in the TODOs to complete the program.
; Stretch goals:
;   * Implement pausing (include the readKeys function)
;   * Add state to the entities: 0: normal 1: blinking. At each frame,
;     randomly choose AT MOST one entity and make it blink.

INCLUDE "hardware.inc"

DEF METAOBJCOUNT EQU 10

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
  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   InitializeObjects

; LCD on, enable object layer (no background)
  ld a, LCDC_ON | LCDC_OBJ_ON
  ld [rLCDC], a

MainLoop:
  call UpdateObjects
  call UpdateShadowOAM
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop

SECTION "Functions", ROM0

InitializeObjects:
  ; TODO: use the RandomByte function to fill the array with random (y,x) coordinate
  ld hl,   MetaCoord ; array of (y,x) coordinates, of METAOBJCOUNT entries.
  ld b,    METAOBJCOUNT
.init:
  ld a,75
  ld [hl+],a
  ld a,75
  ld [hl+],a
  dec b
  jr nz, .init
  ret

UpdateObjects:
  ld hl, MetaCoord
  ld b,  METAOBJCOUNT
; for each face, choose a random direction (left, up, right, down) and walk
.loop:
  push hl
  call Random2bits
  jr z, .left
  dec a
  jr z, .up
  dec a
  jr z, .right
.down:
  inc [hl]
  jr .next
.left:
  inc hl
  dec [hl]
  jr .next
.up:
  dec [hl]
  jr .next
.right:
  inc hl
  inc [hl]
.next:
  pop hl
  dec b
  inc hl :: inc hl
  jr nz, .loop
  ret

Random2bits:
; Better randomness than just calling RandomByte and masking the 6 top bits
; Outputs:
; * A: bottom 2 bits are random; top 6 bits are 0
; * Zero flag set if A==0
  push bc
  call RandomByte
  ld b,a
  swap a
  xor b
  ld b,a
  rrca
  rrca
  xor b
  pop bc
  and %00000011  ; Keep 2 bits
  ret

UpdateShadowOAM:
  ld hl, MetaCoord
  ld de, ShadowOAM
  ld b,  METAOBJCOUNT
.loop:
  push bc
  ld a,[hl+]
  ld b,a
  ld a,[hl+]
  ld c,a
  ; BC contain (y,x) coordinates
  
  ; Transform each MetaCoord entry into 4 ShadowOAM entries:
  ;   MetaObject (y,x)
  ;                    ---> 
  ;                          (y,x,     1, 0)
  ;                          (y,x+8,   2, 0)
  ;                          (y+8,x,   3, 0)
  ;                          (y+8,x+8, 4, 0)

  ; (y,x, 1, 0) (code provided below)
  ld a,b
  ld [de],a
  inc de
  ld a,c
  ld [de],a
  inc de
  ld a,1 ; TILE ID
  ld [de],a
  inc de
  ld a,0
  ld [de],a
  inc de

  ; TODO (y,x+8,   2, 0)

  ; TODO  (y+8,x,   3, 0)

  ; TODO  (y+8,x+8, 4, 0)

  pop bc
  dec b
  jr nz, .loop
  ret



CopyShadowOAMtoOAM:
  ld hl, ShadowOAM
  ld de, STARTOF(OAM)
  ld b, 40 ; update the whole OAM
.loop:
REPT 4
  ld a,[hl+]
  ld [de],a
  inc e
ENDR
  dec b
  jr nz, .loop
  ret

RandomByte:
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
  ld [hl+],a
  ld [hl+],a
  dec bc
  ld a,b
  or c
  jr nz, .copy
  ret

SECTION "Data", ROM0
Tiles:
; smiling face
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110
; big face NW corner
 DB %01111111
 DB %10000000
 DB %10000000
 DB %10011000
 DB %10011000
 DB %10000000
 DB %10000000
 DB %10000000
; big face NE corner
 DB %11111110
 DB %00000001
 DB %00000001
 DB %00011001
 DB %00011001
 DB %00000001
 DB %00000001
 DB %00000001
; big face SE corner
 DB %10000000
 DB %10000000
 DB %10100000
 DB %10010000
 DB %10001111
 DB %10000000
 DB %10000000
 DB %01111111
; big face SW corner
 DB %00000001
 DB %00000001
 DB %00000101
 DB %00001001
 DB %11110001
 DB %00000001
 DB %00000001
 DB %11111110
TilesEnd:

SECTION "Variables", WRAM0
MetaCoord: DS 20 ; (y,x) coordinates of faces
ShadowOAM: DS 160 
