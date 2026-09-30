; Program:   Random Walk (Smooth)
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   A version of random walk where entities have a state of which direction
;   they are moving. This makes animation smoother since entities maintain
;   their direction for some distance until it is elapsed. Entities can
;   also be idle for some time.
;   Pressing the A key resets the objects coordinates.

INCLUDE "hardware.inc"

DEF OBJCOUNT EQU 20

DEF IDLE   EQU 0
DEF UP     EQU 1
DEF RIGHT  EQU 2
DEF DOWN   EQU 3
DEF LEFT   EQU 4

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld a,%11111100 ; black and white palette
  ld [rOBP0], a

  call   CopyTileDataToVRAM
  ld     hl, STARTOF(OAM)
  call   ResetOAM
  ld     hl, ShadowOAM
  call   ResetOAM
  ld     hl, Coordinates
  ld     b, 80
  call   ResetMEM
  ld     hl, States
  ld     b, 80
  call   ResetMEM

  call   InitializeObjects

; LCD on, enable object layer (no background)
  ld a, LCDC_ON | LCDC_OBJ_ON
  ld [rLCDC], a

MainLoop:
  call readKeys
  call MaybeReset
  call UpdateObjects
  call UpdateShadowOAM
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop

SECTION "Functions", ROM0
MaybeReset:
  ld hl,current
  bit 0, [hl]  ; check if A was pressed
  call nz, InitializeObjects 
  ret

InitializeObjects:
  ld hl, Coordinates
  ld b,  OBJCOUNT
.init:
  call RandomByte
  ld [hl+], a
  call RandomByte
  ld [hl+], a
  dec b
  jr nz, .init

  ld hl, States
  ld b, 80
  call ResetMEM
  ret

UpdateShadowOAM:
  ld hl, Coordinates
  ld de, ShadowOAM
  ld b, OBJCOUNT
.loop:
  ; copy Coordinates
  ld a,[hl+]
  ld [de],a
  inc de
  ld a,[hl+]
  ld [de],a
  inc de
  ; skip tile ID (0)
  inc de
  ; skip attributes
  inc de
  dec b
  jr nz,.loop
  ret

CopyShadowOAMtoOAM:
  ld hl, ShadowOAM
  ld de, STARTOF(OAM)
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

UpdateObjects:
; when idle:
; * 1/16 probability: choose direction (among 4), choose counter (4..16)
; * otherwise stay idle
; when non idle:
;  * move object along chose direction, decrement counter
;  * if counter == 0, set object to idle
  ld b, OBJCOUNT
  ld hl, Coordinates
  ld de, States
.updateLoop:
  ld a,[de]
  or a ; is it IDLE?
  jr nz, .moving
.idle:
  call RandomByte
  ld c, a :: swap c :: xor c
  and %00001111
  ; probability 15/16 of staying IDLE
  jr nz, .next
  ; choose random direction
  call RandomByte
  and %00000011  ; [0..3]
  inc a          ; [1..4] (conveniently, the state values for moving into some direction)
  ld [de],a
  inc de
  call RandomByte
  and %00001111  ; [0..15]
  add 4
  ld [de],a      ; [4..19]
  dec de
  jr .next
.moving:
  ld a,[de]      ; get direction
  dec a
  jr z, .move_up
  dec a
  jr z, .move_right
  dec a
  jr z, .move_down
.move_left:
  inc hl
  dec [hl]  ; x--
  dec hl
  jr .move_done
.move_right:
  inc hl
  inc [hl]  ; x++
  dec hl
  jr .move_done
.move_up:
  dec [hl]  ; y--
  jr .move_done
.move_down:
  inc [hl]  ; y--
.move_done:
  ; update counter
  inc de
  ld a,[de]
  dec a     ; counter--
  ld [de],a
  dec de
  or a
  jr nz, .next
.become_idle:
  ld a,0
  ld [de],a
.next:
  inc hl
  inc hl
  inc de
  inc de
  dec b
  jr nz, .updateLoop
  ret


;---------------------------------------------------------------------
readKeys:
;---------------------------------------------------------------------
; Output:
; b : raw state:   pressing key triggers given action continuously
;                  as long as it is pressed
; c : rising edge: pressing key triggers given action only once,
;                  key must be released and pressed again
  ld    a,$20
  ldh   [rP1],a   
  ldh   a,[rP1]
  ldh   a,[rP1]
  cpl
  and   $0f         ; lower nibble has down, up, left, right
  swap	a           ; becomes high nibble
  ld	b,a
  ld    a,$10
  ldh   [rP1],a
  ldh   a,[rP1]
  ldh   a,[rP1]
  ldh   a,[rP1]
  ldh   a,[rP1]
  ldh   a,[rP1]
  ldh   a,[rP1]
  cpl
  and   $0f         ; lower nibble has start, select, B, A
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
ResetMEM:
  ld a,0
.loop:
  ld [hl],a
  inc hl
  dec b
  jr nz,.loop
  ret

CopyTileDataToVRAM:
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


SECTION "TilesData", ROM0
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
TilesEnd:


SECTION "Variables", WRAM0
ShadowOAM: DS 160 
Coordinates: DS 80 ; (y,x)
States: DS 80 ; (DIRECTION, COUNTER)
previous: DS 1
current: DS 1
