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
CHARMAP " ", 0
CHARMAP "A", 14
CHARMAP "B", 15
CHARMAP "C", 16
CHARMAP "D", 17
CHARMAP "E", 18
CHARMAP "F", 19
CHARMAP "G", 20
CHARMAP "H", 21
CHARMAP "I", 22
CHARMAP "J", 23
CHARMAP "K", 24
CHARMAP "L", 25
CHARMAP "M", 26
CHARMAP "N", 27
CHARMAP "O", 28
CHARMAP "P", 29
CHARMAP "Q", 30
CHARMAP "R", 31
CHARMAP "S", 32
CHARMAP "T", 33
CHARMAP "U", 34
CHARMAP "V", 35
CHARMAP "W", 36
CHARMAP "X", 37
CHARMAP "Y", 38
CHARMAP "Z", 39


SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:

Title:
  ld a,0
  ld [currentLevel], a
  
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

  call LoadTitle

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

  call WaitKey

StartLevel:
  ld a,[currentLevel]
  cp ((Levels.end - Levels)/36)
  jp z, EndScreen

  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   ResetBG

  ld a, [currentLevel]
  call LoadLevel
  call RenderGameFirst ; update OAM and VRAM for the first time

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

MainLoop:
  call readKeys
  call MovePlayer
  call CheckExit
  call WaitVBlank
  call RenderGameLoop
  jp MainLoop

EndScreen:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   ResetBG

  call LoadEnd

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

  call WaitKey
  jp Title
  
  

SECTION "Functions", ROM0
LoadTitle:
  ld hl,  TitleBG
  ld de, TILEMAP0
  ld b, TitleBG.end - TitleBG
.loop:
  ld a,[hl+]
  ld [de],a
  inc de
  dec b
  jr nz, .loop
  ret
  
LoadEnd:
  ld hl, EndBG
  ld de, TILEMAP0
  ld b, EndBG.end - EndBG
.loop:
  ld a,[hl+]
  ld [de],a
  inc de
  dec b
  jr nz, .loop
  ret

WaitKey:
.loop:
  call readKeys
  ld a,[current]
  or a
  jr z, .loop
  ret

CheckExit:
  ld a, [playerX]
  ld b,a
  ld a, [playerY]
  ld c,a
  call GetTile
  cp 2
  ret nz
  ; exit
  
  ld hl, currentLevel
  inc [hl]
  pop hl ; reset stack pointer
  jp StartLevel

GetTile:
; in: b:X , c:Y
; out: a: tile from MapData[X,Y]
  ld hl, MapData
  push de
  ld d,0
  ld e,b
  add hl,de
  ld e,c
  sla e :: sla e :: sla e
  add hl, de
  pop de
  ld a,[hl]
  ret

MovePlayer:
  ld a, [playerX]
  ld b,a
  ld a, [playerY]
  ld c,a
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
  inc c
  call GetTile
  cp 1 ; wall?
  ret z
  ld hl, playerY
  inc [hl]
  ret
.up:
  dec c
  call GetTile
  cp 1 ; wall?
  ret z
  ld hl, playerY
  dec [hl]
  ret
.left:
  dec b
  call GetTile
  cp 1 ; wall?
  ret z
  ld hl, playerX
  dec [hl]
  ret
.right:
  inc b
  call GetTile
  cp 1 ; wall?
  ret z
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
characters:
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
 DB $00,$7C,$4E,$4E,$4E,$4E,$7C,$00
 DB $00,$7E,$60,$7C,$60,$60,$7E,$00
 DB $00,$7E,$60,$60,$7C,$60,$60,$00
 DB $00,$3C,$66,$60,$6E,$66,$3E,$00
 DB $00,$46,$46,$7E,$46,$46,$46,$00
 DB $00,$3C,$18,$18,$18,$18,$3C,$00
 DB $00,$1E,$0C,$0C,$6C,$6C,$38,$00
 DB $00,$66,$6C,$78,$78,$6C,$66,$00
 DB $00,$60,$60,$60,$60,$60,$7E,$00
 DB $00,$46,$6E,$7E,$56,$46,$46,$00
 DB $00,$46,$66,$76,$5E,$4E,$46,$00
 DB $00,$3C,$66,$66,$66,$66,$3C,$00
 DB $00,$7C,$66,$66,$7C,$60,$60,$00
 DB $00,$3C,$62,$62,$6A,$64,$3A,$00
 DB $00,$7C,$66,$66,$7C,$68,$66,$00
 DB $00,$3C,$60,$3C,$0E,$4E,$3C,$00
 DB $00,$7E,$18,$18,$18,$18,$18,$00
 DB $00,$46,$46,$46,$46,$4E,$3C,$00
 DB $00,$46,$46,$46,$46,$2C,$18,$00
 DB $00,$46,$46,$56,$7E,$6E,$46,$00
 DB $00,$46,$2C,$18,$38,$64,$42,$00  ; X
 DB $00,$66,$66,$3C,$18,$18,$18,$00  ; Y
 DB $00,$7E,$0E,$1C,$38,$70,$7E,$00  ; Z
 DB $00,$00,$00,$00,$00,$60,$60,$00  ; .
 DB $00,$00,$00,$3C,$3C,$00,$00,$00  ; -
characters_end:
TilesEnd:


SECTION "Backgrounds", ROM0
TitleBG:
db "WELCOME"
.end

EndBG:
db "YOU WON"
.end

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
; Level 1
db 0,0,0,0,1,3
db 0,1,1,0,1,0
db 0,1,1,0,1,0
db 0,1,1,0,1,0
db 0,1,1,0,1,0
db 0,2,1,0,0,0
.end

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
