; Name:
; ID:

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

  call CopyTileDataToVRAM
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
  ld     hl, _OAMRAM
  call   ResetOAM
  ld     hl, ShadowOAM
  call   ResetOAM
  ld a,0
  ld [Paused],a
  ld [previous],a
  ld [current],a
  ret

UpdatePaused:
  ld hl,current
  bit 0, [hl]  ; check if A was pressed
  ret z
  ; toggle Paused variable
  ld a,[Paused]
  ld b,a
  ld a,1
  sub b
  ld [Paused],a
  ret

UpdateAngle:
  ld a,[Paused]
  or a
  ret nz
  ld hl, Angle
  inc [hl]      ; 0 to 255 and overflow
  ret

UpdateShadowOAM:
; reads [Angle]
; updates shadow oam
  ld hl,yLUT
  ld a,[Angle]
  ld d,0
  ld e,a
  add hl,de
  ld a,[hl]
  ld [ShadowOAM],a

  ld hl,xLUT
  ld a,[Angle]
  ld d,0
  ld e,a
  add hl,de
  ld a,[hl]
  ld [ShadowOAM+1],a
  ret

WaitVBlank:
  ld a, [rLY]
  cp 144
  jr nz, WaitVBlank
  ret

CopyTileDataToVRAM:
  ld de, Tiles
  ld hl, _VRAM
  ld bc, TilesEnd - Tiles
  call CopyMemory
  ret

CopyMemory:
; input:
; de : source
; hl : destination
; bc : how many bytes
.copy:
  ld a,[de]
  inc de
  ld [hl],a
  inc hl
  dec bc
  ld a,b
  or c
  jr nz, .copy
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
; tile id 0 ; smiling face
 DB %01111110,%00000000
 DB %10000001,%00000000
 DB %10100101,%00000000
 DB %10000001,%00000000
 DB %10100101,%00000000
 DB %10011001,%00000000
 DB %10000001,%00000000
 DB %01111110,%00000000
TilesEnd:

SECTION "Variables", WRAM0
ShadowOAM: DS 160
Angle: DS 1   ; current angle of the object
Paused: DS 1  ; 1 if paused, 0 otherwise
previous: DS 1
current: DS 1
