# Player Animation System

This document outlines the player animation system, which uses Godot's `AnimationTree` node to decouple animation logic from the player's state machine. 

## Relevant Systems
- Player: @docs/player/player.md
- GSM state machine: @addons/gsm/README.md
- Player movement: @docs/player/movement.md
- Player attacks: @docs/player/attacks.md

## 1. Player Animations

The necessary animations exist in the `AnimationPlayer` node within the `Player` scene (located in `player.tscn`). The following animations are available:

- **idle**: A looping idle animation.
- **run**: A looping run animation.
- **jump**: The initial upward jump animation.
- **fall**: A looping fall animation.
- **dash**: The dashing animation.
- **double_jump**: A non-looping flourish animation for the double jump.

## 2. The `AnimationTree` Setup

An `AnimationTree` node is used in the `player.tscn` scene.

- The `AnimationPlayer` is assigned to the `AnimationTree`'s `anim_player` property.
- The `Tree Root` is set to a new `AnimationNodeStateMachine`.

## 3. State Machine Configuration

The state machine is the heart of the `AnimationTree`. It contains states that correspond to the player's core logic states.

### Core Concept: Mapping Logic to Visuals

The fundamental principle of this architecture is a direct, one-to-one mapping between a **logic state** (a `GSM` node like `Ground` or `GroundAttack1`) and a **visual state** (a node in the `AnimationTree` with the exact same name).

The power of this approach comes from the flexibility of the `AnimationTree`. The type of node used for the visual state is chosen based on the specific needs of that state's animation:

-   For a simple state that just plays one animation (e.g., `Dash`), the visual state is an `Animation` node.
-   For a state that needs to blend between animations (e.g., `Ground` blending `idle` and `run`), the visual state is a `BlendSpace1D`.
-   For a state that contains its own internal animation logic (e.g., `Air` switching between `jump` and `fall`), it can be a nested `StateMachine`.

This keeps the `GSM` logic clean and focused on gameplay rules, while the `AnimationTree` handles the full complexity of the visual representation.

### States:

-   **Ground (Blend Space)**:
    -   This state handles ground movement.
    -   It is an `AnimationNodeBlendSpace1D` that blends between the `idle` and `run` animations.
    -   The blend is controlled by a parameter, `ground_speed`, which is updated from the player script.

-   **Air (Nested State Machine)**:
    -   This state manages all airborne animations (`jump`, `double_jump`, `fall`) by acting as its own nested state machine. This allows for more complex and responsive transitions.
    -   **Sub-States:**
        -   `Jump`: The initial upward jump animation.
        -   `DoubleJump`: The flourish animation for the second jump.
        -   `Fall`: The looping fall animation.
    -   **Transitions (within Air):**
        -   `(Entry) -> Jump`: Default state when entering `Air` from `Ground`.
        -   `Jump -> Fall`: Transitions automatically when `velocity.y >= 0`.
        -   `DoubleJump -> Fall`: Also transitions automatically when `velocity.y >= 0`, cutting the animation short if the player loses upward momentum.

-   **Dash (Animation)**:
    -   A simple state that plays the `dash` animation.

### Animation State Transitions

The transitions in the `AnimationTree` state machine define the valid pathways between animation states. It's important to distinguish between transitions initiated by the game logic (`GSM`) and those handled automatically by the `AnimationTree` itself.

#### `GSM`-Driven Transitions

These transitions occur when the player's logic state changes, forcing the `AnimationTree` to follow suit via the `travel()` command. The connections must exist in the editor for the `travel()` call to succeed.

-   **`(Entry) -> Ground`**: The default starting state for the player.
-   **`Ground <-> Air`**: The `GSM` dictates when the player is airborne or grounded.
-   **`Any -> Dash`**: The `GSM` can initiate a dash from any state, interrupting the current animation.
-   **`Dash -> Air`**: A dash can be interrupted by a jump, which is a `GSM`-driven state change.
-   **`Air -> Air/DoubleJump`**: The `GSM` explicitly tells the `AnimationTree` to travel to the `DoubleJump` sub-state when the action is performed.

#### `AnimationTree`-Internal Transitions

These transitions are configured in the `AnimationTree` editor and run automatically based on conditions or timers, without further input from the `GSM`. This is where the `AnimationTree`'s power to manage complex animation flow shines.

-   **`Dash -> Air/Ground` (Auto)**: After the `dash` animation finishes, the transition is configured to automatically move to either the `Air` or `Ground` state based on a condition (`is_on_floor()`).
-   **`Jump -> Fall` (Conditional)**: Inside the `Air` nested state machine, a transition from `Jump` to `Fall` triggers automatically when the condition `velocity.y >= 0` is met.
-   **`DoubleJump -> Fall` (Conditional)**: Similarly, the `DoubleJump` animation is cut short and transition to `Fall` as soon as the player's upward momentum ceases (`velocity.y >= 0`).

## 4. Player State Scripts

To keep the logic (`GSM`) and visual (`AnimationTree`) states in sync without manual effort, a "convention over configuration" approach is used. The name of the logic state node (e.g., `Ground`) directly maps to the name of the animation state in the `AnimationTree`.

This is achieved by a small snippet in the base `MovementState` script.

### `scenes/player/player_state.gd`

The base state script automatically tells the `AnimationTree` to travel to the corresponding state upon entry.

```gdscript
class_name MovementState
extends GSMState

# Automatically travel to the animation state that has the SAME NAME as this logic state node.
func _enter(_args: Dictionary) -> void:
    self.player.animation_tree.get("parameters/playback").travel(self.name)
```

### Individual State Scripts (`ground.gd`, `air.gd`, `dash.gd`)

With the automatic travel logic in the base class, the individual state scripts are now dramatically simplified. They no longer need to contain any boilerplate for playing animations. They only need to handle logic specific to that state.

-   **`ground.gd`**: The `_enter` function is removed as it only contained the `travel()` call. The animation state in the `AnimationTree` is named "ground" to match the `ground.gd` scene's root node name.
-   **`air.gd`**: The `_enter` function is still needed to handle the `do_jump` argument, but the base class handles the initial `travel("air")`. When a double jump is performed, it specifically travels to the `DoubleJump` sub-state:
    ```gdscript
    # In air.gd, when a double jump is performed:
    animation_tree.get("parameters/playback").travel("Air/DoubleJump")
    ```
-   **`dash.gd`**: The `_enter` function is removed as it only contained the `travel()` call.

### `player.gd`

The `player.gd` script is responsible for updating parameters that control animations within a state (like blend spaces).

-   It gets a reference to the `$AnimationTree`.
-   In `_physics_process`, it continuously updates shared `AnimationTree` parameters:
    -   `$AnimationTree.set("parameters/ground/blend_position", abs(velocity.x))`
    -   `$AnimationTree.set("parameters/air/jump_fall_condition", velocity.y < 0)`

This approach eliminates manual `travel()` calls, reduces code duplication, and ensures that the logic and animation states remain synchronized as long as their names match.
