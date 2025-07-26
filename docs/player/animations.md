# Player Animation Refactor Plan

This document outlines the plan to refactor the player animation system to use Godot's `AnimationTree` node. This will decouple animation logic from the player's state machine, simplifying code and making animations easier to manage.

## 1. Existing Player Animations

The necessary animations already exist in the `AnimationPlayer` node within the `Player` scene (located in `player.tscn`). The following animations are available:

- **idle**: A looping idle animation.
- **run**: A looping run animation.
- **jump**: The initial upward jump animation.
- **fall**: A looping fall animation.
- **dash**: The dashing animation.
- **double_jump**: A non-looping flourish animation for the double jump.

## 2. Set up the `AnimationTree`

1.  Add an `AnimationTree` node to the `player.tscn` scene.
2.  Assign the `AnimationPlayer` to the `AnimationTree`'s `anim_player` property.
3.  Set the `Tree Root` to a new `AnimationNodeStateMachine`.

## 3. Configure the State Machine

The state machine will be the heart of the `AnimationTree`. We will create states that correspond to the player's core logic states.

### Core Concept: Mapping Logic to Visuals

The fundamental principle of this architecture is a direct, one-to-one mapping between a **logic state** (a `GSM` node like `Ground` or `GroundAttack1`) and a **visual state** (a node in the `AnimationTree` with the exact same name).

The power of this approach comes from the flexibility of the `AnimationTree`. The type of node used for the visual state is chosen based on the specific needs of that state's animation:

-   For a simple state that just plays one animation (e.g., `Dash`), the visual state will be an `Animation` node.
-   For a state that needs to blend between animations (e.g., `Ground` blending `idle` and `run`), the visual state will be a `BlendSpace1D`.
-   For a special, one-off animation that should return to the previous state (e.g., `DoubleJump`), the visual state will be a `OneShot` node.
-   For a state that contains its own internal animation logic (e.g., `Air` switching between `jump` and `fall`), it can be a nested `StateMachine`.

This keeps the `GSM` logic clean and focused on gameplay rules, while the `AnimationTree` handles the full complexity of the visual representation.

### States:

-   **Ground (Blend Space)**:
    -   This state will handle ground movement.
    -   It will be an `AnimationNodeBlendSpace1D` that blends between the `idle` and `run` animations.
    -   The blend will be controlled by a parameter, `ground_speed`, which we will update from the player script.

-   **Air (Nested State Machine)**:
    -   This state will manage all airborne animations (`jump`, `double_jump`, `fall`) by acting as its own nested state machine. This allows for more complex and responsive transitions.
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

-   **`Dash -> Air/Ground` (Auto)**: After the `dash` animation finishes, the transition can be configured to automatically move to either the `Air` or `Ground` state based on a condition (e.g., `is_on_floor()`).
-   **`Jump -> Fall` (Conditional)**: Inside the `Air` nested state machine, a transition from `Jump` to `Fall` will trigger automatically when the condition `velocity.y >= 0` is met.
-   **`DoubleJump -> Fall` (Conditional)**: Similarly, the `DoubleJump` animation will be cut short and transition to `Fall` as soon as the player's upward momentum ceases (`velocity.y >= 0`).

## 4. Update Player State Scripts

To keep the logic (`GSM`) and visual (`AnimationTree`) states in sync without manual effort, we will adopt a "convention over configuration" approach. The name of the logic state node (e.g., `Ground`) will directly map to the name of the animation state in the `AnimationTree`.

This is achieved by adding a small snippet to the base `PlayerState` script.

### `scenes/player/player_state.gd`

The base state script will be modified to automatically tell the `AnimationTree` to travel to the corresponding state upon entry.

```gdscript
class_name PlayerState
extends GSMState

# Automatically travel to the animation state that has the SAME NAME as this logic state node.
func _enter(_args: Dictionary) -> void:
    self.player.animation_tree.get("parameters/playback").travel(self.name)
```

### Individual State Scripts (`ground.gd`, `air.gd`, `dash.gd`)

With the automatic travel logic in the base class, the individual state scripts are now dramatically simplified. They no longer need to contain any boilerplate for playing animations. They only need to handle logic specific to that state.

-   **`ground.gd`**: The `_enter` function can be removed if it only contained the `travel()` call. Note that the animation state in the `AnimationTree` must be named "Ground" to match the `ground.gd` scene's root node name.
-   **`air.gd`**: The `_enter` function is still needed to handle the `do_jump` argument, but the base class handles the initial `travel("Air")`. When a double jump is performed, it will need to specifically travel to the `DoubleJump` sub-state:
    ```gdscript
    # In air.gd, when a double jump is performed:
    animation_tree.get("parameters/playback").travel("Air/DoubleJump")
    ```
-   **`dash.gd`**: The `_enter` function can be removed if it only contained the `travel()` call.

### `player.gd`

The `player.gd` script is still responsible for updating parameters that control animations within a state (like blend spaces).

-   Get a reference to the `$AnimationTree`.
-   In `_physics_process`, continuously update shared `AnimationTree` parameters:
    -   `$AnimationTree.set("parameters/Ground/blend_position", abs(velocity.x))`
    -   `$AnimationTree.set("parameters/Air/jump_fall_condition", velocity.y < 0)`

This approach eliminates the manual `travel()` calls, reduces code duplication, and ensures that the logic and animation states remain synchronized as long as their names match.

## 5. Implementation Steps

1.  **Modify `player_state.gd`**: Add the automatic `travel()` logic to the `_enter` function in the base state script (`scenes/player/player_state.gd`) as described above.
2.  **Confirm Animations**: Check that the existing animations in the `AnimationPlayer` are suitable for the new system.
3.  **Add `AnimationTree`**: Add and configure the `AnimationTree` and its `StateMachine` in `player.tscn`.
4.  **Create Animation States**: Create the `Ground` blend space and `Dash` animation state. For the `Air` state, create a **Nested State Machine** containing the `Jump`, `DoubleJump`, and `Fall` animation states and their transitions. **Crucially, ensure the names of these animation states exactly match the names of the corresponding logic state nodes** (e.g., "Ground", "Air", "Dash").
5.  **Refactor `player.gd`**: Update the main player script to continuously set the shared `AnimationTree` parameters for blend spaces and conditions.
6.  **Refactor State Scripts**: Remove the now-redundant manual `travel()` calls from the `_enter` functions of `ground.gd`, `air.gd`, and `dash.gd`, and add the specific `travel("Air/DoubleJump")` call for the double jump action.
7.  **Test**: Test all movement and actions to ensure animations are playing and transitioning correctly based on the new convention-based system.
