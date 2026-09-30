# Sokoban Deluxe

## Project Description

Implement **Sokoban Deluxe**, a version of Sokoban on the Game Boy with some
extended features. If you do not know Sokoban (or Push Box), you can try this
version online: <https://borgar.net/programs/sokoban/>

This project does not provide you a plan of the program to implement or the
data structures that you must use. You must decide these yourselves based on
your current experience in the lab. This is why you are advised to start as
early as possible.

## Minimum Requirements

Your project must include:

1. Sokoban Mechanics

* Player can walk in 4 directions.
* Boxes can be pushed, one at a time.
* Player and boxes can’t move through walls.
* The level is completed when all boxes are on goal tiles.
* A reset button should restart the level.

2. Levels

* See <http://www.sokobano.de/wiki/index.php?title=Level_format> for
  a few hints about level formats.
* Map should include walls, floor, boxes, goal tiles, and player.

* Store at least 9 levels. You can get levels from
  <https://borgar.net/programs/sokoban/>.
* Finishing a level takes you to the next one.
* Use a practical representation of levels and separate code from data,
  such that you can easily add new levels without having to rewrite
  parts of your program.

3. Presentation

* Use single 8x8 tiles for player, box, walls, etc. (no metaobjects)
* No graphical glitches or obvious bugs.

4. Title and Victory Screen:

*  Show a splash screen at startup and/or after level completion.

## Stretch Goals

* Undo Functionality:
  * Press a button to undo the last move.
* Move Counter:
  * Display the number of moves on screen.
