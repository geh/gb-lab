INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank

  ld a, 0
  ld [rLCDC], a  ; turn off LCD
  ld a,%11111100 ; black and white palette
  ld [rBGP],  a  ; background palette

  call CopyCharacters
  call ResetVariables
  call ResetBG

  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8000 
  ld [rLCDC], a

MainLoop:
  call readKeys
  call HandleInput
  call binToDec
  call WaitVBlank
  call copyDigitsRev
  jp MainLoop

SECTION "Functions", ROM0
HandleInput:
  ld hl, current
  bit 7, [hl]
  call z,down
  bit 6, [hl]
  call z, up
  ret
down:
  ld hl, counter
  dec [hl]
  ret
up:
  ld hl, counter
  inc [hl]
  ret

binToDec:
  ld a,[counter]
  ld b,3
.loop:
  call divide_by_10  ; a := a / 10; c = rem(a,10)
  ld [hl],c
  inc c
  inc hl
  dec b
  jr nz, .loop
  ret

divide_by_10:
; input: a
; output: a : quotient, c : remainder
  push hl
  ld l,b

  ld b,0
  ld c,0
.loop:
  cp b
  jr nc, .break
  inc c
  add 10
  jr .loop
.break:
  sub 10 
  dec c ; c : quotient
  sub b ; a - b
  cpl
  add 1 ; b - a : remainder

  ld b,a
  ld a,c ; quotient
  ld c,b ; remainder
  ld b,l
  pop hl
  ret


copyDigitsRev:
  ld b,3
.loop:
  ld a,[hl+]
  ld [de],a
  dec de
  dec b
  jr nz, .loop
  ret

ResetVariables:
  ld a,0
  ld [previous],a
  ld [current],a
  ld [counter],a
  ret

ResetBG:
  ld  bc,32*32
  ld hl, _SCRN0
.loop
  ld [hl],10 ; ID of blank tile
  inc hl
  dec bc
  ld a,b
  or c
  jr nz, .loop

  ld hl, _SCRN0
  ld a,9
.loop2:
  ldi [hl],a
  dec a
  jr nz, .loop2

  ret

WaitVBlank:
  ld a, [rLY]
  cp 144
  jr nz, WaitVBlank
  ret

CopyCharacters:
; from the Tetris source code
  ld hl, Tiles
  ld bc, TilesEnd - Tiles
  ld de, _VRAM
.loop:
  ldi a, [hl]
  ld [de], a
  inc de           ; copy each byte twice into _VRAM
  ld [de], a       ; because characters are stored as only black and white
  inc de           ; but the GB uses two bytes per character to allow for 4 colors
  dec bc
  ld a, b
  or c
  jr nz, .loop
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
 DB 0,0,0,0,0,0,0,0                 ; blank
TilesEnd:

SECTION "Variables", WRAM0
previous: DS 1
current: DS 1
counter: DS 1
buffer: DS 3
