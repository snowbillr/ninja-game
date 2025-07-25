# Player Attack System

This document outlines the context required to understand the player's attacks implementation.

## Relevant Systems
- GSM state machine: @addons/gsm/README.md
- Player movement: @docs/player/movement.md

## Attack States

The following states will be added to the player's state machine:

- `GroundAttack1`: The first attack in the ground combo.
- `GroundAttack2`: The second attack in the ground combo (a knockback finisher).
- `GroundUpAttack`: A launcher attack from the ground.
- `AirAttack1`: The first attack in the air combo.
- `AirAttack2`: The second attack in the air combo (a knockback finisher).
- `AirDownAttack`: A spike attack from the air.
- `AirSlam`: A slam attack from the air.
- `DashAttack`: An attack that can be performed while dashing.

## Animation and Combo Timing

- Each attack animation must play to completion before transitioning to another state.
- Attack inputs can be buffered during an attack animation. If an attack input is buffered, the state will transition to the next appropriate attack state immediately after the current animation finishes.
- A short timer will be initiated at the end of each attack animation. If the attack input is pressed during this window, the player will transition to the next attack in the combo.

## Dash Mechanic

The player can dash out of any attack at any time.

- **Ground Dash:** Can be performed at any time while on the ground.
- **Air Dash:** Can be performed at any time while in the air, provided the player has an available air dash charge.

## State Transitions

### Ground States

- `Ground` -> `GroundAttack1`: On `attack` input.
- `Ground` -> `GroundUpAttack`: On `up` + `attack` input.
- `GroundAttack1` -> `GroundAttack2`: On `attack` input (buffered or timed).
- `GroundAttack1` -> `GroundUpAttack`: On `up` + `attack` input (buffered or timed).
- `GroundAttack1` -> `Ground`: After attack animation finishes and no valid combo input is made.
- `GroundAttack2` -> `Ground`: After attack animation finishes.
- `GroundUpAttack` -> `Air`: After attack animation finishes, launching the player and enemy.
- `(any ground attack state)` -> `Dash`: On `dash` input.

### Air States

- `Air` -> `AirAttack1`: On `attack` input.
- `Air` -> `AirDownAttack`: On `down` + `attack` input.
- `Air` -> `AirSlam`: On `down` + `jump` input (or a new input).
- `AirAttack1` -> `AirAttack2`: On `attack` input (buffered or timed).
- `AirAttack1` -> `AirDownAttack`: On `down` + `attack` input (buffered or timed).
- `AirAttack1` -> `AirSlam`: On `down` + `jump` input (or a new input).
- `AirAttack1` -> `Air`: After attack animation finishes and no valid combo input is made.
- `AirAttack2` -> `Air`: After attack animation finishes.
- `AirDownAttack` -> `Air`: After attack animation finishes.
- `AirSlam` -> `Ground`: On impact with the ground.
- `(any air attack state)` -> `Dash`: On `dash` input, if `can_dash()`.

### Dash States

- `Dash` -> `DashAttack`: On `attack` input.
- `DashAttack` -> `Ground`: After attack animation finishes on ground.
- `DashAttack` -> `Air`: After attack animation finishes in air.

## Implementation 

Each of the states listed in the State Transitions section will have their own Node that extends `GSMState`.

There will be some kind of shared implementation regarding input buffering. AITODO: Expand on this.

All of the `AirAttack*` states will not have any gravity applied to them (or potentially, very very little and on each hit their y velocity will be set to a slightly negative value). AITODO: Provide options for this.
