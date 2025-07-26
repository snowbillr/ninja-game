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

### States:

-   **Ground (Blend Space)**:
    -   This state will handle ground movement.
    -   It will be an `AnimationNodeBlendSpace1D` that blends between the `idle` and `run` animations.
    -   The blend will be controlled by a parameter, `ground_speed`, which we will update from the player script.

-   **Air (State)**:
    -   This state will manage jumping and falling.
    -   We will use a `Transition` node with a condition based on the player's `velocity.y` to automatically switch between the `jump` and `fall` animations.

-   **Dash (Animation)**:
    -   A simple state that plays the `dash` animation.

-   **DoubleJump (OneShot)**:
    -   An `AnimationNodeOneShot` that plays the `double_jump` animation.
    -   This will be triggered from the `air.gd` script and will return to the **Air** state when finished.

### Transitions:

-   `(Entry) -> Ground`: The starting state.
-   `Ground -> Air`: Triggered when the player jumps or walks off a ledge.
-   `Air -> Ground`: Triggered when the player lands on a solid surface.
-   `Any -> Dash`: Triggered when the player initiates a dash. This allows dashing from both the `Ground` and `Air` states.
-   `Dash -> Air`: Triggered when the player jumps to interrupt a dash.
-   `Dash -> Air/Ground`: After the dash duration is over, the state machine will automatically transition to the `Air` or `Ground` animation state based on whether the player is on the floor.

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
-   **`air.gd`**: The `_enter` function is still needed to handle the `do_jump` argument, but the `travel("Air")` call is removed. It will still need to trigger the `double_jump` OneShot, as this is a special case.
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
4.  **Create Animation States**: Create the `Ground` blend space, `Air` state, and `Dash` state. **Crucially, ensure the names of these animation states exactly match the names of the corresponding logic state nodes** (e.g., "Ground", "Air", "Dash").
5.  **Implement `DoubleJump`**: Implement the `DoubleJump` `OneShot` node for the special flourish animation.
6.  **Refactor `player.gd`**: Update the main player script to continuously set the shared `AnimationTree` parameters for blend spaces and conditions.
7.  **Refactor State Scripts**: Remove the now-redundant manual `travel()` calls from the `_enter` functions of `ground.gd`, `air.gd`, and `dash.gd`.
8.  **Test**: Test all movement and actions to ensure animations are playing and transitioning correctly based on the new convention-based system.
