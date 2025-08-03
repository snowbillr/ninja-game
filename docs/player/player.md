# Player Node

This document provides an overview of the `Player` node, which is the central component for the player character.

## Scene Structure

The `Player` is a `CharacterBody2D` located in `scenes/player/player.tscn`. Its scene tree includes:

- **`Sprite2D`**: Handles the player's visual representation.
- **`AnimationPlayer`**: Stores all the individual animation assets (e.g., `idle`, `run`, `attack`).
- **`AnimationTree`**: Manages complex animation transitions and blending, driven by the state machine.
- **`GSM`**: The Godot State Machine that controls the player's behavior by switching between different states.
- **`DirectionDetector`**: A simple node that determines which way the player is facing.

## Core Scripts and Resources

- **`player.gd`**: The main script for the `Player` node. It is responsible for:
    - Getting references to its child nodes.
    - Connecting to the `direction_changed` signal from the `DirectionDetector`.
    - Initializing the state machine (`GSM`).

- **`PlayerStats` (Resource)**: An export variable that holds the player's core movement parameters, such as `max_speed`, `acceleration_coefficient`, `friction_coefficient`, and `max_gravity`. This allows for easy tweaking of the player's feel from the inspector.

- **`AirMovementCharges` (Resource)**: An export variable that manages the number of available air jumps and air dashes, preventing infinite aerial movement.

## Relevant Systems

- **Player Movement**: @docs/player/movement.md
- **Player Attacks**: @docs/player/attacks.md
- **Player Animations**: @docs/player/animations.md
- **State Machine (GSM)**: @addons/gsm/README.md
