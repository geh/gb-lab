# Catrap

## Project Overview

**Catrap** is single-player, turn-based puzzle game with mechanics
similar to *Sokoban* and *Boulder Dash*.

A key objective of this project is **reverse engineering** the
original game mechanics. You are expected to:

- Play and/or watch the original game
- Identify all tile types
- Analyze interactions and movement rules
- Recreate the gameplay behavior as accurately as possible

Understanding and documenting the original mechanics is considered
part of the assignment.

### About Catrap

![](pitman.jpg)

**Catrap** first appeared as **Pitman** in 1985 for the Sharp MZ-700 computer
and was adapted to the Game Boy in 1990.

See the following gameplay videos for reference:

* Levels 1 to 10: <https://www.youtube.com/watch?v=l9NIReIiGY0>
* Full game: <https://www.youtube.com/watch?v=FfV4MnGfiA4>

Do **NOT** implement:

* the rewind feature
* levels with 2 players
* timer

The following level tiles encoding must be followed:

~~~
0 = Nothing
1 = Stairs
2 = Monster
3 = Rock
4 = Sand
5 = Wall
6 = Ghost
7 = Player
~~~

A level is stored as a tilemap of 12 columns and 12 rows.

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

**Stretch Goals**

* Step counter feature
* Smooth transitions in player and tiles movements
