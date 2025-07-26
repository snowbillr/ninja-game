# Player Movement System

This document outlines the context required to understand the player's movement implementation.

## Relevant Systems
- GSM state machine: @addons/gsm/README.md
- Player states: @assets/scenes/player/states

## State-Based Movement

The player's movement is managed by a state machine, where each state defines a specific behavior (e.g., standing on the ground, being in the air, dashing). This approach keeps the code organized and easy to manage.

### Core States

- **`ground`**: This is the default state when the player is on a solid surface.
  - **Horizontal Movement**: The player can move left and right with a gentle acceleration and friction effect, providing a smooth start and stop.
  - **Actions / Transitions**:
    - **Jump**: Pressing the "jump" button transitions the player to the `air` state, initiating a jump.
    - **Dash**: Pressing the "dash" button transitions the player to the `dash` state.
    - **Fall**: If the player walks off a ledge, they will transition to the `air` state.

- **`air`**: This state is active when the player is airborne (jumping or falling).
  - **Horizontal Movement**: Similar to the `ground` state, the player has control over their horizontal movement in the air, allowing for mid-air adjustments.
  - **Gravity**: A constant downward force is applied, which increases over time to a maximum value, creating a natural-feeling jump arc.
  - **Jumping**:
    - **Little Jump**: A small, initial jump is performed when the "jump" button is first pressed.
    - **Big Jump**: If the player continues to hold the "jump" button after the initial press, a timer is started. If the button is still held when the timer finishes, the player will perform a second, higher jump. Releasing the button before the timer completes cancels the big jump.
  - **Actions / Transitions**:
    - **Double Jump**: If the player has an available air jump, pressing the "jump" button again will trigger a second jump. This follows the same little/big jump logic.
    - **Air Dash**: If the player has an available air dash, pressing the "dash" button will transition to the `dash` state.
    - **Land**: When the player lands on a solid surface, they will transition back to the `ground` state.

- **`dash`**: This state provides a quick burst of horizontal movement.
  - **Movement**: The player moves at a fixed high speed in the direction they are facing for a short duration. During the dash, gravity does not affect the player.
  - **Actions / Transitions**:
    - **Jump**: The player can interrupt a dash by jumping, which transitions them to the `air` state.
  - **Completion**: Once the dash duration is over, the player will transition to the `air` state if they are airborne, or the `ground` state if they have landed.

## Air Movement Charges

To limit the player's abilities in the air, the concept of "air movement charges" is used. This is managed by the `air_movement_charges.gd` resource.

- **Jumps**: The player starts with a set number of air jumps (e.g., one double jump). Each time they jump in the air, a charge is consumed.
- **Dashes**: Similarly, the player has a limited number of air dashes. A charge is only consumed if the dash is performed in the air.
- **Reset**: All air movement charges are reset when the player returns to the `ground` state.