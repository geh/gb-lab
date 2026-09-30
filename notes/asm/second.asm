; Program:   Second graphical program
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   A minimal program that demostrates the object layer.
;   Displays one moving object on screen.
;   To do so, it resets the OAM, copy tile data from ROM to VRAM
;   and sets the coordinates of the first OAM entry to an on-screen
;   pair of coordinates.
;   Tile format in ROM is 8 bytes, each byte is copied twice to VRAM,
;   and a black and white palette is used.
;   The object's movement is one pixel per frame.
;   Program is non-interactive.
;
; Possible exercises:
;   * Display and animate 2 or 3 objects.
;   * Animate the single object following a square path on screen.

INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  call WaitVBlank
  ld a, 0
  ld [rLCDC], a

  ld a,%11111100 ; b&w palette
  ld [rOBP0], a

  call   CopyTilesToVRAM

  ld     hl, _OAMRAM
  call   ResetOAM

  ld hl, _OAMRAM
  ld [hl],50  ; Y coordinate
  inc hl
  ld [hl],80  ; X coordinate
  inc hl

; LCD on, enable object layer (no background)
  ld a, LCDCF_ON | LCDCF_OBJON
  ld [rLCDC], a

MainLoop:
  call WaitVBlank
  ld hl,_OAMRAM
  inc [hl]
  call WaitEndVBlank
  jp MainLoop

SECTION "Functions", ROM0
WaitVBlank:
.loop:
  ld a, [rLY]
  cp 144
  jr nz, .loop
  ret

WaitEndVBlank:
.loop:
  ld a, [rLY]
  cp 152
  jr nz, .loop
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
  ld hl, _VRAM
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

SECTION "Data", ROM0
Tiles:
; ID 0: smiling face
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110
TilesEnd:

