; Program:   10 bouncing metaobjects
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   A crossover between bounce.asm and walkMeta.asm.
;   Program is non-interactive.

INCLUDE "hardware.inc"

DEF METAOBJCOUNT  EQU 1

; DIRECTIONS
DEF NE    EQU $00
DEF SE    EQU $01
DEF SW    EQU $02
DEF NW    EQU $03

; BOUNCE AREA LIMITS
DEF WESTLIMIT EQU 8
DEF EASTLIMIT EQU 152
DEF NORTHLIMIT EQU 16
DEF SOUTHLIMIT EQU 144

; ## VARIABLES AND DATA STRUCTURES IN RAM ##

SECTION "Variables", WRAM0
metaObjectArray: DS 10*3
  ; for each meta-object, store direction (NE, SE, SW, NW), y and x.
  ; 10 meta-objects maximum
shadowOAM: DS 160

; ## BEGINNING OF CODE ##
SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0 ; Make room for the header

EntryPoint:

        call waitVBlank

	ld a, 0
	ld [rLCDC], a
        ld a,%11111100
        ld [rOBP1],a

CopyTiles:
	ld de, Tiles
	ld hl, _VRAM
	ld bc, TilesEnd - Tiles
.loop:
	ld a, [de]
	ldi [hl], a
	ldi [hl], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, .loop

        ld hl,_OAMRAM
        ld b, 40*4
        call clearMem

        ld hl,shadowOAM
        ld b, 40*4
        call clearMem

initMetaObjects:
; For each metaobject
;   dir = random(NE,SE,SW,NW)
;   y   = random(NORTHLIMIT, SOUTHLIMIT)
;   x   = random(WESTLIMIT, EASTLIMIT)
  ld hl,metaObjectArray
  ld b,METAOBJCOUNT
.loop:
  call dirRandom
  ld [hli],a
  call y_random
  ld [hli],a
  call x_random
  ld [hli],a
  dec b
  jp nz, .loop

  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call updateMetaObjects 
  call updateShadowOAM
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

clearMem:
; input:
; * hl: starting memory location
; * b: amount of bytes to set to 0
  ld a, 0
.loop:
  ld [hli], a
  dec b
  jp nz,.loop
  ret

updateMetaObjects:
  ld hl,metaObjectArray
  ld b,METAOBJCOUNT
update_loop:
  push bc
  push hl
  ld a,[hl] ; get direction
  cp NE
  jp z, update_NE
  cp SE
  jp z, update_SE
  cp SW
  jp z, update_SW
  cp NW
  jp z, update_NW
end_update:
  pop hl
  pop bc
  inc hl
  inc hl
  inc hl
  dec b
  jp nz, update_loop
  ret

updateShadowOAM:
; input:
;   * metaObjectArray
; output:
;   * shadowOAM 
; description:
;   * for each metaobject, this function converts its (y,x) coordinates
;     into the (y,x) coordinates of 4 objects in the shadowOAM.
;   * this enables to see 16*16 sprites on screen by using 8*8 objects
  ld hl,metaObjectArray+1 ; y of 1st entry
  ld de,shadowOAM
  ld b,METAOBJCOUNT
.loop
  push bc

  ld a,[hli]  ; y
  ld b,[hl]   ; x
  inc hl
  inc hl      ; next metaObject.y entry

  ld [de],a   ; obj0
  inc de
  push af
  ld a,b
  ld [de],a
  pop af
  inc de
  push af
  ld a,1
  ld [de],a
  pop af
  inc de
  inc de
  ld [de],a   ; obj1
  inc de
  push af
  ld a,b
  add 8
  ld [de],a
  pop af
  inc de
  push af
  ld a,2
  ld [de],a
  pop af
  inc de
  inc de
  add 8
  ld [de],a   ; obj2
  inc de
  push af
  ld a,b
  ld [de],a
  pop af
  inc de
  push af
  ld a,3
  ld [de],a
  pop af
  inc de
  inc de
  ld [de],a   ; obj3
  inc de
  ld a,b
  add 8
  ld [de],a
  inc de
  push af
  ld a,4
  ld [de],a
  pop af
  inc de
  inc de

  pop bc
  dec b
  jp nz, .loop
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

; input:
;   hl: OBJ entry in metaObjectArray
update_NE:
  ld d,h
  ld e,l ; de points to direction
  inc hl
  ld a,[hl] ; Y
  cp NORTHLIMIT
  jp nz, update_NE_1
  ld a, SE
  ld [de], a
  jp end_update
update_NE_1:
  inc hl
  ld a,[hl] ; X
  cp EASTLIMIT
  jp nz, update_NE_2
  ld a, NW
  ld [de],a 
  jp end_update
update_NE_2:
  inc a      ; INCREMENT X
  ld [hl], a ; STORE X 
  dec hl
  dec [hl]   ; DECREMENT Y
  jp end_update

update_SE:
  ld d,h
  ld e,l
  inc hl
  ld a,[hl] ; Y
  cp SOUTHLIMIT
  jp nz, update_SE_1
  ld a, NE
  ld [de], a
  jp end_update
update_SE_1:
  inc hl
  ld a,[hl] ; X
  cp EASTLIMIT
  jp nz, update_SE_2
  ld a, SW
  ld [de],a 
  jp end_update
update_SE_2:
  inc a      ; INCREMENT X
  ld [hl], a ; STORE X 
  dec hl
  inc [hl]   ; INCREMENT Y 
  jp end_update

update_SW:
  ld d,h
  ld e,l
  inc hl
  ld a,[hl] ; Y
  cp SOUTHLIMIT
  jp nz, update_SW_1
  ld a, NW
  ld [de], a
  jp end_update
update_SW_1:
  inc hl
  ld a,[hl] ; X
  cp WESTLIMIT
  jp nz, update_SW_2
  ld a, SE
  ld [de],a 
  jp end_update
update_SW_2:
  dec a
  ld [hl], a ; DECREMENT X 
  dec hl
  inc [hl]   ; INCREMENT Y 
  jp end_update

update_NW:
  ld d,h
  ld e,l
  inc hl
  ld a,[hl] ; Y
  cp NORTHLIMIT
  jp nz, update_NW_1
  ld a, SW
  ld [de], a
  jp end_update
update_NW_1:
  inc hl
  ld a,[hl] ; X
  cp WESTLIMIT
  jp nz, update_NW_2
  ld a, NE
  ld [de],a 
  jp end_update
update_NW_2:
  dec a
  ld [hl], a ; DECREMENT X 
  dec hl
  dec [hl]   ; DECREMENT Y 
  jp end_update


x_random:
; output:
;   a: random value in [WESTLIMIT, EASTLIMIT]
  call randomByte
  cp EASTLIMIT-WESTLIMIT
  jp c, x_random_1
  sub EASTLIMIT-WESTLIMIT
x_random_1:
  add WESTLIMIT
  ret

y_random:
; output:
;   a: random value in [NORTHLIMIT, SOUTHLIMIT]
  call randomByte
  cp SOUTHLIMIT-NORTHLIMIT
  jp c, x_random_1
  sub SOUTHLIMIT-NORTHLIMIT
y_random_1:
  add NORTHLIMIT
  ret

dirRandom:
; output:
;   a: random value in [0,3]
  call randomByte
  rra
  and %00000011
  ret

randomByte:
; output:
;   a: random value in [0,255]
  push bc
  ld c,a
  ld a,[rDIV]
  add c
  add l
  add l
  add l
  pop bc
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
; tile id 1; big smiling face NW corner
 DB %01111111
 DB %10000000
 DB %10000000
 DB %10011000
 DB %10011000
 DB %10000000
 DB %10000000
 DB %10000000

; tile id 2; big smiling face NE corner
 DB %11111110
 DB %00000001
 DB %00000001
 DB %00011001
 DB %00011001
 DB %00000001
 DB %00000001
 DB %00000001
; tile id 3; big smiling face SE corner
 DB %10000000
 DB %10000000
 DB %10100000
 DB %10010000
 DB %10001111
 DB %10000000
 DB %10000000
 DB %01111111

; tile id 4; big smiling face SW corner
 DB %00000001
 DB %00000001
 DB %00000101
 DB %00001001
 DB %11110001
 DB %00000001
 DB %00000001
 DB %11111110


TilesEnd:
