; Program:   First graphical program
; Author:    Guillaume Hoffmann
; Date:      2025
;
; Description:
;   A minimal program that demostrates the object layer.
;   Displays one still object on screen.
;   To do so, it resets the OAM, copy tile data from ROM to VRAM
;   and sets the coordinates of the first OAM entry to an on-screen
;   pair of coordinates.
;   Program is non-interactive.
;
; Exercises:
;   1. These exercises focus on how the OAM works and do not require
;      to modify the main loop.
;      a. Display 3 non-aligned objects on screen in different coordinates.
;      b. Using one loop, display 5 objects on screen with the same
;         x coordinate.
;      c. Using two loops, display 25 objects on screen in a grid
;         arrangement.
;      d. Add a second graphical tile of a frowning face (turn the
;         mouth upside down) to the program. 
;         Using two loops, display 25 objects on screen in a grid
;         arrangement, alternating between a smiling and a frowning
;         face.
;   2. These exercises focus on the LY register and how to use it to
;      synchonize between the CPU and the PPU.
;      a. Come back to the original version of the program with just one
;         still object and initialize its position to the top left corner
;         of the screen.
;      b. Add diagonal movement to the object, by modifying the main loop
;         of the program as follows: wait for the vertical blank, then
;         modify the OAM by incrementing by 1 both coordinates of the object.
;         Given that the screen refreshes at about 60 frames per second and
;         the height of the screen is 144 pixels, does the program work
;         according to your expectation?
;      c. Fix the previous program such that the object's coordinates are
;         modified only once per frame, by implementing and calling from
;         the main loop a function that waits for LY to be a certain value
;         at each repeat of the main loop.

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

  call   ResetOAM

  ld hl, STARTOF(OAM)
  ld b, 5
  ld e,0   ; TILE ID
  
  ld a, 30 ; FIRST Y COORDINATE
.outer_loop:
  ld c, 5
  ld d, 25 ; FIRST X COORDINATE
.inner_loop:
  ld [hl], a
  inc hl
  ld [hl], d
  inc hl
  push af
  ld a,e
  and %00000001
  ld [hl],a
  pop af
  inc e 
  inc hl
  inc hl
  push af  ; d = d + 20
  ld a,20  ;
  add a, d ;
  ld d, a  ;
  pop af   ;
  dec c
  jr nz, .inner_loop
  add a,20
  dec b
  jr nz, .outer_loop
*
  ld a, LCDC_ON | LCDC_OBJ_ON ; enable object layer, no background
  ld [rLCDC], a

MainLoop:
  jp MainLoop

SECTION "Functions", ROM0
WaitVBlank:
  ld a, [rLY]
  cp 144
  jr nz, WaitVBlank
  ret

ResetOAM:
  ld hl, STARTOF(OAM)
  ld b,40*4
.loop:
  ld [hl],0
  inc hl
  dec b
  jr nz,.loop
  ret

CopyTilesToVRAM:
  ld de, Tiles
  ld hl, STARTOF(VRAM)
  ld bc, Tiles.end - Tiles
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
;   Tiles are stored as 8 bytes. Each byte must be copied
;   twice to VRAM to follow the Game Boy format.
;   A black and white palette is used.

Tiles:
 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10011001
 DB %10100101
 DB %10000001
 DB %01111110

 DB %01111110
 DB %10000001
 DB %10100101
 DB %10000001
 DB %10100101
 DB %10011001
 DB %10000001
 DB %01111110
 

.end
