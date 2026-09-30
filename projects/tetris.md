# Tetris

## Project Description

**Tetris**

Relevant sources:

* <https://www.retrogames.cc/gameboy-games/tetris-world.html>
* <https://play.tetris.com>
* <https://howtotetris.com/tetris-mechanisms/>

Core Specifications:

* A 10 cells wide x 18 cells high playing field
* The 7 classic shapes (I, J, L, O, S, T, Z)
* Movement: The player must be able to move the piece left/right.
  (Rotation is not necessary for the core specification)
* Game Logic:
  * Pieces lock when they land after the usual delay.
  * Complete horizontal lines are cleared, and blocks above fall down.
  * The game ends when a new piece cannot be placed at the top.
* User Interface:
  * The current piece and the static stack of locked blocks must be visible.
  * Line counter

Stretch goals:

* Soft drop
* [Rotation](https://strategywiki.org/wiki/Tetris/Rotation_systems) both ways
* Line clear animation (see the gameboy version)
* Hard drop (see tetris.com version)
* Ghost shape (see tetris.com version)
* Levels and Increasing speed (according to line counter)
* Scoring
