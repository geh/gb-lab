# Projects

The projects below are ordered approximately from simpler to more
challenging.

  1. [15-slide puzzle](projects/15slide.md)
  2. [2048](projects/2048.md)
  3. [1D Pacman](projects/1Dpacman.md)
  4. [Sokoban](projects/sokoban1.md)
  5. [Sokoban Deluxe](projects/sokoban2.md)
  6. [Catrap](projects/catrap.md)
  7. [Rock Slide](projects/rockslide.md)
  8. [Othello](projects/othello.md)
  9. [Tetris](projects/tetris.md)
 10. [Klotski](projects/klotski.md)

## Project constraints

Unless a project explicitly states otherwise, projects are expected to:

- use RGBDS
- run on the Game Boy
- avoid DMA and interrupts
- avoid pre-existing game engines or frameworks
- avoid `rst` instructions
- fit in a 32 KB ROM
- use the same set of tiles for objects and background (`LCDC_BLOCK01`).
- use a tile format in ROM of 8 bytes per tile, that are then copied
  to VRAM by doubling each byte (palettes changes are allowed)
