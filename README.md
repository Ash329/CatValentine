# Cat Valentine

A small 2D pixel-art platformer made in Godot and a heart felt gift. You play as a cat exploring a farm full of cows, chickens, butterflies and mice.

<!-- Screenshots -->
<!-- ![Main menu](screenshots/main_menu.png) -->
<!-- ![Valentine level](screenshots/valentine.png) -->
<!-- ![Anniversary level](screenshots/anniversary.png) -->

## Levels

Pick a level from the main menu:

- **Valentine Level**: `scenes/levels/Game.tscn`
- **Anniversary**: `scenes/levels/Anniversary.tscn`
- **Untitled**: locked, coming later

## Controls

| Action     | Keys                  |
|------------|-----------------------|
| Move left  | `A` / `←`             |
| Move right | `D` / `→`             |
| Jump       | `Space`               |
| Attack     | `J` / left mouse click |

On the game over screen:

| Action    | Key |
|-----------|-----|
| Try again | `R` |
| Main menu | `M` |

The level also restarts on its own after a few seconds.

## Features

- A cat that can run, jump and do a charged dash attack
- Wandering farm animals: cows in several colors (including a rare pink one), chickens that run away from you, and butterflies
- Mice you can attack
- A friendly NPC that follows you and shows hearts when you reach it
- A custom game over screen with a pixel-art cat

## Running the project

1. Install [Godot 4.5](https://godotengine.org/download).
2. Clone this repo:
   ```bash
   git clone <repo-url>
   ```
3. Open Godot, click **Import**, and pick the `project.godot` file.
4. Press **F5** to run. The game starts at the main menu.

## Exporting

The project has a **Windows Desktop** export preset. To build it, go to **Project → Export** in Godot. You need the Godot export templates installed first.

## Project structure

```
Assets/       sprites, tilesets, backgrounds and the m6x11 font
Scripts/      GDScript for the player, NPCs, enemies and UI
scenes/
  levels/     playable levels (Game, Anniversary)
  player/     the player cat
  npcs/       cows, chickens, butterflies and the follower NPC
  enemies/    mouse
  ui/         main menu and chat
  world/      shared world pieces
```
