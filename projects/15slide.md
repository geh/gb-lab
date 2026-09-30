# Sliding 15-Puzzle

## General Description

The project consists in programming a game for the GameBoy, in assembly
language.

The game must follow the informal specification given as follows:

- [Sliding 15-puzzle](https://en.wikipedia.org/wiki/Sliding_puzzle)

## Requirements

- Implement a 4×4 sliding puzzle.
- Allow the player to move tiles using the directional buttons.
- Detect when the puzzle is solved.
- Provide a way to restart the puzzle.
- Display the puzzle clearly on screen.
- Initial configuration: either hard code one or more solvable configuration(s)
  (easy) or randomly generate a solvable configuration (hard)

Your project must fit in a single `.asm` that uses the standard
`hardware.inc` header. That file should be ready to be compiled
with `rgbasm` usual way, or to run on <https://gbdev.io/rgbds-live/>.
