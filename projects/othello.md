# Othello

## Project Description

**Othello** (also known as Reversi).

Relevant sources:

* <https://www.retrogames.cc/gameboy-games/othello-japan.html>
* <https://www.eothello.com/>
* <https://en.wikipedia.org/wiki/Reversi>

Core Specifications:

* A fully functional **player vs. player** mode
* A functional **player vs. computer** mode. The computer may make random valid
  moves.
* Game logic: the program must correctly enforce all Othello rules
  * A move is only allowed if it flips at least one opponent's piece
  * All pieces flipped in all 8 directions from the placed piece must be flipped
  * If a player has no valid moves, their turn is skipped
  * The game ends when no player has a valid move
* User Interface:
  * The current player (Black/White) must be clearly indicated
  * The winner is declared at the end of a game
   
Stretch goals:

* Animated piece flips (similar to the gameboy game)
* Piece counting animation (similar to the gameboy game)
* Displaying legal moves locations (as in `eothello.com`)
* Better AI (some greedy evaluation is fine, or minmax if you are up for it)
