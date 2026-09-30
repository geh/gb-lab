; Program:   Maze
; Author:    G. Hoffmann
; Date:      2026
;
; Description:
;
; Exercises:
;   1. Implement wall collision.
;   2. Implement exit detection and next level loading.
;   3. Implement start screen, win screen and coming back to start after win screen.

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 16

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld a,%11111100 ; black background
  ld [rBGP], a
  ld a,%10101000 ; grey object
  ld [rOBP0], a

  call   CopyTilesToVRAM
  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   ResetBG

  ld a,0          ; just load level 0 for now
  call LoadLevel

  call RenderGameFirst ; update OAM and VRAM for the first time

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

MainLoop:
  call readKeys
  call UpdateGame
  call WaitVBlank
  call RenderGameLoop
  jp MainLoop

SECTION "Functions", ROM0
UpdateGame:
  ld a, [current]
  bit 7,a
  jr nz, .down
  bit 6,a
  jr nz, .up
  bit 5,a
  jr nz, .left
  bit 4,a
  jr nz, .right
  ret
.down:
  ld hl, playerY
  inc [hl]
  ret
.up:
  ld hl, playerY
  dec [hl]
  ret
.left:
  ld hl, playerX
  dec [hl]
  ret
.right:
  ld hl, playerX
  inc [hl]
  ret
  
PlayerToOAM:
  ld  a, [playerY]
  sla a :: sla a :: sla a :: add 16
  ld  [STARTOF(OAM)],a
  ld  a, [playerX]
  sla a :: sla a :: sla a :: add 8
  ld  [STARTOF(OAM)+1],a
  ld a, 3
  ld  [STARTOF(OAM)+2],a
  ret

RenderGameLoop:
  call PlayerToOAM
  ret

RenderGameFirst:
; set player coordinate in OAM
  call PlayerToOAM
; copy level from WRAM (8*8 array) to VRAM
; each line to first of 32 bytes of TILEMAP0
  ld de, MapData
  ld hl, TILEMAP0
  ld c,8
.one_line:
  ld b,8
.one_tile:
  ld a, [de]
  inc de
  ld [hl+],a
  dec b
  jr nz, .one_tile
  push de
  ld de, (32-8) ;
  add hl,de     ; next line
  pop de
  dec c
  jr nz, .one_line
  ret

ResetBG:
  ld hl,TILEMAP0
  ld bc,1024
.loop:
  ld [hl], 1 ; blank/empty
  inc hl
  dec bc
  ld a,b
  or c
  jr nz,.loop
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

MACRO INCL
  push hl
  ld hl, \1
  inc [hl]
  pop hl  ; 5 bytes, 52 cycles
ENDM
; ld a,[label] :: inc a :: ld [label],a  ; 7 bytes, 36 cycles, destroys a

MACRO RESET
  xor a
  ld [\1],a    ; 20 cycles, destroys a
ENDM

LoadLevel:
  ; in:
  ;   a=level number (start at 0)
  ; out:
  ;   MapData, PlayerX and Player Y updated
  ld hl, Levels
  ld de, 36 ; level size
.loop:
  or a
  jr z,.skip
  add hl,de
  dec a
  jr .loop
.skip
  xor a
  ld [tmpX],a
  ld [tmpY],a
  ; load 6*6 level from hl, adding outer walls
  ; north wall
  ld de, MapData
  ld b,8
.wall_north
  ld a,1
  ld [de],a
  inc de
  dec b
  jr nz, .wall_north

  ld c,6
.copy6lines:
  INCL tmpY
  RESET tmpX
  ld a,1
  ld [de],a ; left wall
  inc de
  ld b,6
.copy1line:
  INCL tmpX
  ld a,[hl+]
  call MaybeLoadPlayer
  ld [de],a
  inc de
  dec b
  jr nz, .copy1line
  ld a,1
  ld [de],a ; right wall
  inc de
  dec c
  jr nz, .copy6lines  

  ld b,8
.wall_south
  ld a,1
  ld [de],a
  inc de
  dec b
  jr nz, .wall_south
  ret

; if a == player, set player coordinates and load 0 into map
MaybeLoadPlayer:
  cp 3
  ret nz
  ld a, [tmpX]
  ld [playerX], a
  ld a, [tmpY]
  ld [playerY], a
  ld a, 0 ; write an empty tile to WRAM
  ret

SECTION "Data", ROM0
Tiles:
; blank
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
; wall
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
 DB %10101010
 DB %01010101
; EXIT
 DB %11111111
 DB %10000001
 DB %10000001
 DB %10001101
 DB %10000001
 DB %10000001
 DB %10000001
 DB %11111111
; smiling face
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
MapData:       DS 8*8
current:       DS 1
previous:      DS 1
playerX:       DS 1
playerY:       DS 1
gameState:     DS 1
currentLevel:  DS 1
tmpX:          DS 1
tmpY:          DS 1

SECTION "Levels", ROM0
Levels:
; Level 0
db 0,0,0,0,2,0
db 0,1,1,1,1,0
db 0,0,0,0,1,0
db 0,1,0,0,0,0
db 0,1,1,1,1,0
db 3,0,0,0,0,0
; Level 1
db 3,0,0,0,0,0
db 0,1,1,1,1,0
db 1,0,0,0,1,0
db 0,0,1,0,1,0
db 0,1,1,0,1,0
db 0,2,1,0,0,0
