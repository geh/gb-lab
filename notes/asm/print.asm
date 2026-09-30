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
;   1. Initialize the objects coordinates randomly.
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

DEF OBJCOUNT EQU 1

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
  ld     hl, ShadowOAM
  call   ResetOAM
  call   InitializeObjects
  call   ResetBG

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

MainLoop:
  call UpdateObjects
  call PreparePrint
  call WaitVBlank
  call CopyShadowOAMtoOAM
  call CommitPrint
  jp MainLoop

SECTION "Functions", ROM0
PreparePrint:
  ld hl, STARTOF(OAM)  ; Y
  ld a, [hl]
  swap a
  and %00001111
  add 2
  ld [topY],a
  ld a,[hl]
  and %00001111
  add 2
  ld [botY],a

  inc hl  ; X

  ld a,[hl]
  swap a
  and %00001111
  add 2
  ld [topX],a
  ld a,[hl]
  and %00001111
  add 2
  ld [botX],a
  ret

CommitPrint:
  ld hl,topY
  ld de,TILEMAP0
REPT 4
  ld a,[hl+]
  ld [de],a
  inc de
ENDR
  ret

ResetBG:
  ld hl,TILEMAP0
  ld bc,1024
.loop:
  ld [hl],1 ; nothing
  inc hl
  dec bc
  ld a,b
  or c
  jr nz,.loop
  ret
  
InitializeObjects:
  ld hl,   ShadowOAM   ; hl points to first object entry
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
  swap a         ; Swap nibbles
  xor b          ; XOR high and low nibbles
  ld b,a
  rrca
  rrca           ; Shift right 2
  xor b          ; Mix more
  and %00000011  ; Keep 2 bits
  pop bc
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
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110
 ; ID 1: blank
 DB 0,0,0,0,0,0,0,0
 
 DB $00,$3C,$66,$66,$66,$66,$3C,$00 ; 0
 DB $00,$18,$38,$18,$18,$18,$3C,$00 ; 1
 DB $00,$3C,$4E,$0E,$3C,$70,$7E,$00
 DB $00,$7C,$0E,$3C,$0E,$0E,$7C,$00
 DB $00,$3C,$6C,$4C,$4E,$7E,$0C,$00
 DB $00,$7C,$60,$7C,$0E,$4E,$3C,$00
 DB $00,$3C,$60,$7C,$66,$66,$3C,$00
 DB $00,$7E,$06,$0C,$18,$38,$38,$00
 DB $00,$3C,$4E,$3C,$4E,$4E,$3C,$00 ; 8
 DB $00,$3C,$4E,$4E,$3E,$0E,$3C,$00 ; 9
 DB $00,$3C,$4E,$4E,$7E,$4E,$4E,$00 ; A
 DB $00,$7C,$66,$7C,$66,$66,$7C,$00 ; B
 DB $00,$3C,$66,$60,$60,$66,$3C,$00 ; C
 DB $00,$7C,$4E,$4E,$4E,$4E,$7C,$00 ; D
 DB $00,$7E,$60,$7C,$60,$60,$7E,$00 ; E
 DB $00,$7E,$60,$60,$7C,$60,$60,$00 ; F
TilesEnd:

SECTION "Variables", WRAM0
ShadowOAM: DS 160
; nibbles to display
topY: DS 1
botY: DS 1
topX: DS 1
botX: DS 1
