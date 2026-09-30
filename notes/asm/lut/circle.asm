INCLUDE "hardware.inc"
INCLUDE "tables.inc"

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank

  ld a, 0
  ld [rLCDC], a  ; turn off LCD
  ld a,%11111100 ; black and white palette
  ld [rOBP0], a

  call CopyTilesToVRAM
  call ResetVariables

  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call readKeys
  call UpdatePaused
  call UpdateAngle
  call UpdateShadowOAM
  call WaitVBlank
  call CopyShadowOAMtoOAM
  jp MainLoop

SECTION "Functions", ROM0
ResetVariables:
; TODO
; Initialize all variables of the program to 0, including OAMs
  ret

UpdatePaused:
; TODO
; check if A key was pressed
; if yes, toggle the Paused variable between 0 and 1
  ret

UpdateAngle:
; TODO
; if Paused == 1, do nothing
; if Paused == 0, increment Angle variable
  ret

UpdateShadowOAM:
; TODO
; Using the lookup tables yLUT and xLUT, convert
; Angle variable to (y,x) coordinates of the object on screen
  ret

WaitVBlank:
.loop:
  ld a, [rLY]
  cp 144
  jr nz, .loop
  ret

CopyTilesToVRAM:
  ld de, Tiles
  ld hl, _VRAM
  ld bc, TilesEnd - Tiles
.loop:
  ld a,[de]
  inc de
  ld [hl+],a
  ld [hl+],a
  dec bc
  ld a,b
  or c
  jr nz, .loop
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

ResetOAM:
; input: HL: location of OAM or Shadow OAM
  ld b,40*4
  ld a,0
.loop:
  ld [hl+],a
  dec b
  jr nz,.loop
  ret

readKeys:
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



SECTION "TilesData", ROM0
Tiles:
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
Angle:     DS 1  ; current angle of the object
Paused:    DS 1  ; 0 if not paused, 1 if paused
previous:  DS 1  ; Used by readKeys
current:   DS 1  ; Used by readKeys
