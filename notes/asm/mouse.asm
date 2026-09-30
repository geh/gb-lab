; Program:   Mouse and click (objects and background layers)
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   Displays one object and enable to move it with
;   the readKeys function.
;   Enable to click and modify the tile shown in background
;   below the object.
;   Program is interactive.

INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld   a, 0
  ld   [rLCDC], a
  ld   a,%11111100
  ld   [rOBP0], a
  call   CopyTilesToVRAM
  ld     hl, STARTOF(OAM)
  call   ResetOAM
  call   ResetBG

  ld a,50
  ld [mouse_y],a
  ld a,80
  ld [mouse_x],a
  ld a,2
  ld [STARTOF(OAM)+2],a

  ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON | LCDC_BLOCK01
  ld [rLCDC], a

MainLoop:
  call UpdateState
  call WaitVBlank
  call UpdateOAM_BG
  jp MainLoop

SECTION "Functions", ROM0
UpdateState:
  call readKeys  ; 7,6,5,4
  bit  7,b
  call nz, MoveDown
  bit  6,b
  call nz, MoveUp
  bit  5,b
  call nz, MoveLeft
  bit  4,b
  call nz, MoveRight
  ret
MoveUp:
  ld hl, mouse_y
  dec [hl]
  ret
MoveDown:
  ld hl, mouse_y
  inc [hl]
  ret
MoveLeft:
  ld hl, mouse_x
  dec [hl]
  ret
MoveRight:
  ld hl, mouse_x
  inc [hl]
  ret

UpdateOAM_BG:
  ld a,[mouse_y]
  ld [STARTOF(OAM)],a
  ld a,[mouse_x]
  ld [STARTOF(OAM)+1],a

  ld hl,current
  bit 0,[hl] ; new A press
  call nz, ModifyBG
  ret

ModifyBG:
  ; convert mouse coordinates to BG coordinate and change the byte there 
  ld hl, TILEMAP0
  ld a,[mouse_x] 
  srl a
  srl a
  srl a
  sub 1
  ld c,a
  ld b,0
  add hl,bc  ;  TILEMAP0 + ((mouse_x - 8) / 8) 
  
  ld a,[mouse_y]
  sub 16
  srl a
  srl a
  srl a
  sla a
  sla a
  sla a ; set low bits to zero
  ld c,a
  ld b,0
  add hl,bc
  add hl,bc
  add hl,bc
  add hl,bc ; _SCRN0 + X + ((mouse_y - 16) / 8) * 32 (ROW_SIZE)
 
  ld a,[hl]  ; toggle between 0 and 1
  xor 1
  ld [hl],a
  ret


WaitVBlank:
  ld a, [rLY]
  cp 144
  jr nz, WaitVBlank
  ret

ResetBG:
  ld hl, TILEMAP0
  ld bc, 1024
  ld a,0
.loop:
  ld [hl+],a
  dec c
  jr nz,.loop
  dec b
  jr nz,.loop

  ld a,0
  ld [rSCX],a
  ld [rSCY],a
  ret

ResetOAM:
; input:
; * HL: location of OAM or Shadow OAM
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

SECTION "Variables", WRAM0
mouse_x: DS 1
mouse_y: DS 1
current: DS 1
previous: DS 1

SECTION "Data", ROM0
Tiles:
; ID 0: empty
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
 DB %00000000
; ID 1: wall
 DB %01111110
 DB %10000001
 DB %10000001
 DB %10000001
 DB %10000001
 DB %10000001
 DB %10000001
 DB %01111110
; ID 2: mouse pointer
 DB %11000000
 DB %10000000
 DB %00100000
 DB %00010000
 DB %00001000
 DB %00000100
 DB %00000010
 DB %00000000
TilesEnd:
