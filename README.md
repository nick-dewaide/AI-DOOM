# Doom Clone Game

## Overview
This project is a simple Doom-like game built using Love2D. It features a variety of systems including player movement, enemy AI, weapon mechanics, and level progression. The game aims to replicate the classic first-person shooter experience with modern enhancements.

## Project Structure
- **main.lua**: Entry point of the game, initializes the engine and contains the main game loop.
- **conf.lua**: Configuration settings for the game, including window size and title.
- **assets/**: Contains all game assets including images, audio, and fonts.
  - **images/**: Subdirectories for sprites, textures, and UI images.
  - **audio/**: Subdirectories for music and sound effects.
  - **fonts/**: Font files for rendering text.
- **src/**: Contains the source code for the game.
  - **engine/**: Core engine functionalities.
    - **gamestate.lua**: Manages game states.
    - **camera.lua**: Handles camera movement and projection.
  - **map/**: Map loading and level structure.
    - **maploader.lua**: Loads map data.
    - **level.lua**: Defines level structure.
    - **maps/**: Contains specific level data.
  - **player/**: Player management.
    - **player.lua**: Manages player attributes.
    - **controls.lua**: Handles player input.
  - **rendering/**: Rendering systems.
    - **renderer.lua**: Responsible for rendering the game world.
    - **raycaster.lua**: Implements raycasting for 3D view.
  - **entities/**: Defines entities in the game.
    - **entity.lua**: Base entity class.
    - **enemies/**: Enemy definitions and AI.
    - **items/**: Item and pickup management.
  - **weapons/**: Weapon and combat systems.
    - **weapon.lua**: Defines weapon attributes.
    - **combat.lua**: Handles combat mechanics.
  - **physics/**: Collision detection logic.
  - **interaction/**: Interactable objects like doors and switches.
  - **progression/**: Level progression management.
  - **ui/**: User interface management.
- **libs/**: Third-party libraries or utilities.
- **README.md**: Documentation for the project.

## Setup Instructions
1. Clone the repository to your local machine.
2. Ensure you have Love2D installed.
3. Open the project folder with Love2D to run the game.

## Gameplay
- Navigate through levels, defeat enemies, and collect items.
- Use various weapons to combat foes and progress through the game.
- Interact with doors and switches to unlock new areas.

## Future Enhancements
- Additional levels and enemies.
- Enhanced AI behaviors.
- More weapon types and combat mechanics.
- Improved graphics and audio effects.