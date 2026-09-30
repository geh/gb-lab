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

DEF OBJCOUNT EQU 16 ; must be 1 to 40

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
  call   InitializeBG
  ld a,10
  ld [Counter],a
  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a 

MainLoop:
  call UpdateObjects
  call PrepareTileReveal
  call WaitVBlank
  call CopyShadowOAMtoOAM
  call RevealBG
  call Scroll
  jp MainLoop

SECTION "Functions", ROM0
Scroll:
  ld hl, Counter
  dec [hl]
  ret nz
  ld a,8
  ld [Counter],a

  call Random2bits
  jr z, .left
  cp 1
  jr z, .up
  cp 2
  jr z, .right
.down
  ld hl, rSCY
  inc [hl]
  ret
.left
  ld hl, rSCX
  dec [hl]
  ret
.up
  ld hl, rSCY
  dec [hl]
  ret
.right
  ld hl, rSCX
  inc [hl]
  ret
  

PrepareTileReveal:
  call RandomByte
  and %00001111 ;  random value in [0-15]
  ld hl,ShadowOAM
  add a ; a = a+a ; a = a*2
  add a ;         ; a = a*4
  ld d,0
  ld e,a
  add hl, de   ; HL points to the object of interest

  ld a,[hl+] ; Y  
  sub 16 ; Y - 16
  srl a :: srl a :: srl a ; (Y - 16) / 8
  ld b,a
  
  ld a,[hl] ; X
  sub 8
  srl a :: srl a :: srl a ; (X - 8) / 8
  
  ld hl, TILEMAP0
  ld d,0
  ld e,a
  add hl, de  ;  TILEMAP0 + BG_X
  
  push hl
  ld h,0
  ld l,b
REPT 5
  add hl,hl ; BG_Y * 32
ENDR
  pop de     ;  TILEMAP0 + BG_X
  add hl,de  ;  TILEMAP0 + BG_X + BG_Y*32
  
  ld a,l
  ld [RevealAddress],a
  ld a,h
  ld [RevealAddress+1],a
  ret

RevealBG:
  ld a,[RevealAddress]
  ld l,a
  ld a,[RevealAddress+1]
  ld h,a
  ld [hl],17 ; empty tile
  ret

UpdateObjects:
  ld b,OBJCOUNT
  ld hl,ShadowOAM
.loop:
  push hl
  call RandomStep
  pop hl
  
  inc hl
  inc hl
  inc hl
  inc hl
  dec b
  jr nz, .loop

  ret

InitializeBG:
  ld hl, TILEMAP0
  ld bc, 1024
.loop:
  ld [hl], 18
  inc hl
  dec bc
  ld a,b
  or c
  jr nz, .loop
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
  ld [hl], 16          ; tile ID of face
  inc      hl
  inc      hl
  dec      b
  jr nz, .init
  ret

CopyShadowOAMtoOAM:
  ld hl, ShadowOAM
  ld de, STARTOF(OAM)
REPT OBJCOUNT*4
  ld a,[hl+]
  ld [de],a
  inc e
ENDR
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
 DB $00,$3C,$66,$66,$66,$66,$3C,$00 ; 0
 DB $00,$18,$38,$18,$18,$18,$3C,$00 ; 1
 DB $00,$3C,$4E,$0E,$3C,$70,$7E,$00 ; 2
 DB $00,$7C,$0E,$3C,$0E,$0E,$7C,$00 ; 3
 DB $00,$3C,$6C,$4C,$4E,$7E,$0C,$00 ; 4
 DB $00,$7C,$60,$7C,$0E,$4E,$3C,$00 ; 5
 DB $00,$3C,$60,$7C,$66,$66,$3C,$00 ; 6
 DB $00,$7E,$06,$0C,$18,$38,$38,$00 ; 7
 DB $00,$3C,$4E,$3C,$4E,$4E,$3C,$00 ; 8
 DB $00,$3C,$4E,$4E,$3E,$0E,$3C,$00 ; 9
 DB $00,$3C,$4E,$4E,$7E,$4E,$4E,$00 ; A
 DB $00,$7C,$66,$7C,$66,$66,$7C,$00 ; B
 DB $00,$3C,$66,$60,$60,$66,$3C,$00 ; C
 DB $00,$7C,$4E,$4E,$4E,$4E,$7C,$00 ; D
 DB $00,$7E,$60,$7C,$60,$60,$7E,$00 ; E
 DB $00,$7E,$60,$60,$7C,$60,$60,$00 ; F
; smiling face
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110 
 DB 0,0,0,0,0,0,0,0 ; empty tile
 ; fog
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
TilesEnd:

SECTION "Variables", WRAM0
ShadowOAM: DS 160
RevealAddress: DS 2
Counter: DS 1
