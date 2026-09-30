# Rock Slide

## Project Overview

**Rock Slide** is a single-player, turn-based puzzle game.

A key objective of this project is **reverse engineering** the
original game mechanics. You are expected to:

- Play and/or watch the original game
- Identify all tile types
- Analyze interactions and movement rules
- Recreate the gameplay behavior as accurately as possible

Understanding and documenting the original mechanics is considered
part of the assignment.

### About Rock Slide

![](rockslide.png)

**Rock Slide** is a DOS game released in 1989 by Viking Tecnologies.
Think of it as Boulder Dash without enemies and simpler rocks fall mechanics.
Gravity does not affect the player, but it does to rocks, and rocks can
kill the player.

* You can download the file [`Rock-Slide_DOS_EN.zip`](https://www.myabandonware.com/game/rock-slide-486) and run it on the DOSBOX emulator (you will need to install DOSBOX
  on your system and learn to use it). WINE also works.
* You can play it online at <https://www.myabandonware.com/game/rock-slide-486/play-4h3>
* You can also open `SLIDER.DAT` with a text editor to see the levels (note that
  the encoding is different from the proposed one).
* Find a video gameplay here: <https://www.youtube.com/watch?v=GBNSFdISqok>

Do implement:

* Live counter (levels start with 9 lives)

Do **not** implement:

* Random levels
* Timer

The following level tiles encoding must be followed:

~~~
0 = Dirt
1 = Rock
2 = NPC
3 = Money
4 = Solid wall
5 = Empty space
6 = Player start
~~~

A level is stored as a tilemap of 20 columns and 16 rows.

The game must contain at least 10 levels.

### Features to Implement

The game must include the following sequence:

1. Title screen.
2. Start game from first level when any key is pressed
3. When a level is cleared, the next level starts.
4. When the last level is cleared, an ending screen is shown.
5. Return to the title screen after a key press.

Controls during the game:

* Player is controlled by the 4 direction keys
* Start resets the level
* `A` changes to the next level and `B` changes to the previous level

**Stretch Goals**:

* Step counter feature
* Smooth transitions in player and tiles movements
