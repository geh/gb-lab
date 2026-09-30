; Program:   40 bouncing objects
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Displays 40 objects in movement.
;   Objects move in 4 directions (NE, SE, SW, NW).
;   Initial coordinates and orientation are random, then objects
;   advance and bounce on the border of the screen.
;   Program is non-interactive.

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 40

; DIRECTIONS
DEF NE  EQU 0
DEF SE  EQU 1
DEF SW  EQU 2
DEF NW  EQU 3

; LIMITS FOR 8*8 OBJECTS
DEF WESTLIMIT  EQU 8
DEF EASTLIMIT  EQU 160
DEF NORTHLIMIT EQU 16
DEF SOUTHLIMIT EQU 152

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a
  ld a,%11111100
  ld [rOBP1],a

  call   CopyTilesToVRAM
  ld     hl, _OAMRAM
  call   ResetOAM
  ld     hl, ShadowOAM
  call   ResetOAM

  call   InitializeObjects

  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call UpdateObjects
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop



SECTION "Functions", ROM0

InitializeObjects:
; Initialize Shadow OAM and dirarray
  ld hl,dirarray
  ld de,ShadowOAM
  ld b,OBJCOUNT
.loop:
  ; For each object OBJ:
  ;   OBJ.X   = random(WESTLIMIT, EASTLIMIT)
  ;   OBJ.Y   = random(NORTHLIMIT, SOUTHLIMIT)
  ;   OBJ.DIR = random(NE,SE,SW,NW)
  call RandomDirection
  ld [hl+],a
  call RandomCoordinate
  ld [de],a
  inc de
  call RandomCoordinate
  ld [de],a
  inc de
  ld a, 0
  ld [de],a ; use first tile
  inc de
  ld [de],a ; set attributes to zero
  inc de

  dec b
  jp nz, .loop
  ret


UpdateObjects:
  ld hl,dirarray
  ld de,ShadowOAM
  ld b,OBJCOUNT
update_loop:
  ld a,[hl] ; get OBJ direction
  cp NE
  jp z, update_NE
  cp SE
  jp z, update_SE
  cp SW
  jp z, update_SW
  ;cp NW
  jp update_NW
end_update:
  inc hl
  inc de
  inc de
  inc de
  inc de
  dec b
  jp nz, update_loop
  ret

CopyShadowOAMtoOAM:
  ld hl, ShadowOAM
  ld de, _OAMRAM
  ld b, 40
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

WaitVBlank:
.wait:
  ld a, [rLY]
  cp 144
  jp nz, .wait
  ret

; input:
;   hl: OBJ entry in DIRARRAY
;   de: OBJ entry in Shadow OAM
update_NE:
  ld a,[de] ; Y
  cp NORTHLIMIT
  jr nz, .update_NE_1
  ld a, SE
  ld [hl], a
  jp end_update
.update_NE_1:
  inc de
  ld a,[de] ; X
  cp EASTLIMIT
  jr nz, .update_NE_2
  ld a, NW
  ld [hl],a 
  dec de ; restore de value
  jp end_update
.update_NE_2:
  inc a      ; INCREMENT X
  ld [de], a ; STORE X 
  dec de
  ld a,[de]
  dec a
  ld [de],a  ; DECREMENT Y 
  jp end_update

; input:
;   hl: OBJ entry in DIRARRAY
;   de: OBJ entry in Shadow OAM
update_SE:
  ld a,[de] ; Y
  cp SOUTHLIMIT
  jr nz, .update_SE_1
  ld a, NE
  ld [hl], a
  jp end_update
.update_SE_1:
  inc de
  ld a,[de] ; X
  cp EASTLIMIT
  jr nz, .update_SE_2
  ld a, SW
  ld [hl],a 
  dec de ; restore de value
  jp end_update
.update_SE_2:
  inc a      ; INCREMENT X
  ld [de], a ; STORE X 
  dec de
  ld a,[de]
  inc a
  ld [de],a  ; INCREMENT Y 
  jp end_update

; input:
;   hl: OBJ entry in DIRARRAY
;   de: OBJ entry in Shadow OAM
update_SW:
  ld a,[de] ; Y
  cp SOUTHLIMIT
  jr nz, .update_SW_1
  ld a, NW
  ld [hl], a
  jp end_update
.update_SW_1:
  inc de
  ld a,[de] ; X
  cp WESTLIMIT
  jr nz, .update_SW_2
  ld a, SE
  ld [hl],a 
  dec de ; restore de value
  jp end_update
.update_SW_2:
  dec a
  ld [de], a ; DECREMENT X 
  dec de
  ld a,[de]
  inc a
  ld [de],a  ; INCREMENT Y 
  jp end_update

; input:
;   hl: OBJ entry in DIRARRAY
;   de: OBJ entry in Shadow OAM
update_NW:
  ld a,[de] ; Y
  cp NORTHLIMIT
  jr nz, .update_NW_1
  ld a, SW
  ld [hl], a
  jp end_update
.update_NW_1:
  inc de
  ld a,[de] ; X
  cp WESTLIMIT
  jr nz, .update_NW_2
  ld a, NE
  ld [hl],a 
  dec de ; restore de value
  jp end_update
.update_NW_2:
  dec a
  ld [de], a ; DECREMENT X 
  dec de
  ld a,[de]
  dec a
  ld [de],a  ; DECREMENT Y 
  jp end_update

RandomCoordinate:
  call RandomByte
  and %01111111 ; [0,127]
  add 16        ; [16,143]
  ret

RandomDirection:
  call RandomByte
  and %00000011  ; [0,3]
  ret

RandomByte:
  ld a,[rDIV]
  xor b
  xor l
  xor [hl]
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
  ld hl, _VRAM
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
ShadowOAM: DS 160
dirarray: DS 40  ; for each object, store direction (NE, SE, SW, NW)
