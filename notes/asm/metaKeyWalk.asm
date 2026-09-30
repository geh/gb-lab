; Program:   Random Walk with Metaobjects and Input
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Shows 40 moving objects on screen.
;   Relies on ShadowOAM / OAM separation and a fast copy function
;   to update all objects coordinates on time during VBlank.
;   Relies on a simple RNG (Random Number Generation) function to decide
;   which direction to move each object.
;
INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 40

CHARMAP " ", 1
CHARMAP "A", 13
CHARMAP "B", 14
CHARMAP "C", 15
CHARMAP "D", 16
CHARMAP "E", 17
CHARMAP "F", 18
CHARMAP "G", 19
CHARMAP "H", 20
CHARMAP "I", 21
CHARMAP "J", 22
CHARMAP "K", 23
CHARMAP "L", 24
CHARMAP "M", 25
CHARMAP "N", 26
CHARMAP "O", 27
CHARMAP "P", 28
CHARMAP "Q", 29
CHARMAP "R", 30
CHARMAP "S", 31
CHARMAP "T", 32
CHARMAP "U", 33
CHARMAP "V", 34
CHARMAP "W", 35
CHARMAP "X", 36
CHARMAP "Y", 37
CHARMAP "Z", 38

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
  ld hl, TILEMAP0
  ld de, PressStr
  ld b, PressStr.end - PressStr
.copy:
  ld a,[de]
  inc de
  ld [hl+],a
  dec b
  jr nz, .copy

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a


  call WaitKey

  call WaitVBlank
  ld a, 0
  ld [rLCDC], a
  call   ResetBG
  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a
  
  ld a,0
  ld [pause],a
  

MainLoop:
  call readKeys
  call UpdatePause
  call UpdateObjects
  call MaybeReset
  call Convert
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop


SECTION "Functions", ROM0
Convert:
  ld de, Coordinates
  ld hl, ShadowOAM
  ld b, (OBJCOUNT/4)
  
.loop:
  push bc
  
  ld a,[de]  ; Y coordinate
  ld c,a
  inc de
  ld a,[de]  ; X coordinate
  ld b,a
  inc de
  
  ; TOP LEFT OBJECT
  ld [hl],c ; Y 
  inc hl
  ld [hl],b ; X
  inc hl
  ld a, 39 ; tile ID
  ld [hl],a
  inc hl
  inc hl
  
  push bc
  ; TOP RIGHT OBJECT
  ld [hl],c ; Y 
  inc hl
  ld a,b
  add 8
  ld b,a
  ld [hl],b ; X+8
  inc hl
  ld a, 40 ; tile ID
  ld [hl],a
  inc hl
  inc hl
  pop bc
  
  push bc
  ; BOTTOM LEFT OBJECT
  ld a,c
  add 8
  ld c,a
  ld [hl],c ; Y + 8
  inc hl
  ld [hl],b ; X
  inc hl
  ld a, 41 ; tile ID
  ld [hl],a
  inc hl
  inc hl
  pop bc
  
  push bc
  ; BOTTOM RIGHT OBJECT
  ld a,c
  add 8
  ld c,a
  ld [hl],c ; Y + 8
  inc hl
  ld a,b
  add 8
  ld b,a
  ld [hl],b ; X + 8
  inc hl
  ld a, 42 ; tile ID
  ld [hl],a
  inc hl
  inc hl
  pop bc

  pop bc
  dec b
  jr nz, .loop
  ret


MaybeReset:
  ld a,[current]
  bit 0, a ; A key
  ret z
  call InitializeObjects
  ret

UpdatePause:
  ld a,[current]
  bit 1, a ; B key
  ret z
  ld a,[pause]
  xor 1
  ld [pause],a
  ret

WaitKey:
 call readKeys
 ld a,[current]
 or a
 jr z, WaitKey
 ret

ResetBG:
  ld hl,TILEMAP0
  ld bc,1024
.loop:
  ld [hl],1 ; blank
  inc hl
  dec bc
  ld a,b
  or c
  jr nz,.loop
  ret


InitializeObjects:
  ld hl,   Coordinates  ; hl points to first metaobject entry
  ld b,    (OBJCOUNT/4)
.init:
  ld a,75
  ld [hl+], a           ; set Y coordinate
  ld a,75
  ld [hl+], a           ; set X coordinate
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
  ld a,[pause]
  or a
  ret nz

  ld hl, Coordinates
  ld b, (OBJCOUNT/4)
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
  dec b
  jr nz, .loop
  ret

Random2bits:
  push bc
  call RandomByte; ld a,[rDiv] (16cy) ::  xor b (4cy) :: xor l (4cy) :: xor [hl] (8cy) (=32cy) , vs call/ret (24cy+16= 40cy)
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
  
; Alternatively (if you only keep the 2 low bits):
; REPT 3
;   rrca :: rrca :: xor b
; ENDR


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

;---------------------------------------------------------------------
readKeys:
;---------------------------------------------------------------------
; Output:
; b : raw state:   pressing key triggers given action continuously
;                  as long as it is pressed
; c : rising edge: pressing key triggers given action only once,
;                  key must be released and pressed again
; Requires to define variables `previous` and `current`
  ld    a,$20
  ldh   [rP1],a   
  ldh   a,[rP1] :: ldh a,[rP1]
  cpl
  and   $0F         ; lower nibble has down, up, left, right
  swap	a           ; becomes high nibble
  ld	b,a
  ld    a,$10
  ldh   [rP1],a
  ldh   a,[rP1] :: ldh a,[rP1] :: ldh a,[rP1]
  ldh   a,[rP1] :: ldh a,[rP1] :: ldh a,[rP1]
  cpl
  and   $0F         ; lower nibble has start, select, B, A
  or    b
  ld    b,a

  ld    a,[previous]  ; load previous state
  xor   b	      ; result will be 0 if it's the same as current read
  and   b	      ; keep buttons that were pressed during this read only
  ld    [current],a   ; store result in "current" variable and c register
  ld    c,a
  ld    a,b           ; current state will be previous in next read
  ld    [previous],a

  ld    a,$30         ; reset rP1
  ldh   [rP1],a
  ret

SECTION "Data", ROM0
PressStr:
  DB "PLEASE PRESS ANY KEY"
.end


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
; blank
DB 0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0
; digits and letters
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
Coordinates: DS 20
ShadowOAM: DS 160 
current: DS 1
previous: DS 1
pause: DS 1
