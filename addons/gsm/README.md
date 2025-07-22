# GSM: Godot State Machine

A simple, node-based state machine for Godot 4. This addon helps you organize character controllers, UI flows, or any other entity that behaves differently depending on its state.

## Core Concepts

*   **`GSM` Node**: The main node that manages the active state and handles transitions. It should be a child of the entity you want to control (the "actor").
*   **`GSMState` Nodes**: Children of the `GSM` node, where each child represents a distinct state (e.g., `Idle`, `Run`, `Jump`). You create these by attaching a script that extends `GSMState` to a `Node`.
*   **Transitions**: Logic that determines when to move from one state to another. Transitions can be handled declaratively using `Resource` objects or imperatively in code.

## How to Use

### 1. Scene Setup

1.  Add a `GSM` node to your scene, typically as a child of the character or object it will control (the "actor").
2.  In the `GSM` node's inspector, assign your character node to the `Actor` property.
3.  Add child `Node`s to the `GSM` node for each state you need (e.g., `Idle`, `Run`, `Jump`).
4.  Attach a new script to each of these state nodes that extends `GSMState`.
5.  Select the `GSM` node again and assign your desired starting state (e.g., the `Idle` node) to the `Init State` property.

**Example Scene Tree:**

```
- Player (CharacterBody2D)
  - GSM (the state machine node)
    - Idle (Node with Idle.gd script extending GSMState)
    - Run (Node with Run.gd script extending GSMState)
    - Jump (Node with Jump.gd script extending GSMState)
```

### 2. Creating States

Each state is a script that extends `GSMState`. You can override several methods to define the state's behavior.

```gdscript
# Idle.gd
extends GSMState

# Called when the state is entered.
# Use this to start animations, enable/disable processing, etc.
func _enter(args: Dictionary) -> void:
	print("Entering Idle state")
	actor.play_animation("idle")

# Called when the state is exited.
# Use this to clean up anything from _enter.
func _exit() -> void:
	print("Exiting Idle state")

# Called every frame. Return the name of a state to transition to it.
# This is one way to handle coded transitions.
func _transition() -> Variant:
	if gsm.actor.get_velocity().x != 0:
		return "Run"
	return null
```

### 3. Handling Transitions

There are two primary ways to transition between states.

#### a) Declarative Transitions (Inspector)

This is the easiest method for common cases like input or physics checks.

1.  Select a `GSMState` node (e.g., `Idle`).
2.  In the inspector, find the `Transitions` property and add a new element to the array.
3.  Choose a transition type from the dropdown, like `GSMInputTransition` or `GSMFloorCheckTransition`.
4.  Configure the properties of the transition resource.
    *   **To**: The name of the state to transition to (e.g., "Jump").
    *   **Input Action**: For `GSMInputTransition`, the action name from the Input Map (e.g., "jump").
    *   **On Floor**: For `GSMFloorCheckTransition`, whether to transition when the actor is on the floor or in the air.

The `GSM` node will automatically process these transitions for the active state.

#### b) Imperative Transitions (Code)

For more complex logic, you can trigger transitions directly from your state scripts.

**Method 1: Using `_transition()`**

As shown in the `Idle.gd` example above, you can return the name of a state from the `_transition()` function.

**Method 2: Calling `gsm.transition()`**

You have access to the parent state machine via the `gsm` variable. You can call `transition()` at any time.

```gdscript
# SomeState.gd
extends GSMState

func _physics_process(delta):
    if some_complex_condition:
        gsm.transition("AnotherState")
```

## Usability Tip: Creating a Typed Base State

For better code organization and type safety, you can create a base state script for your actor that all other states will inherit from. This allows you to get a typed reference to your actor once, instead of casting `gsm.actor` in every state.

**1. Create a base state script:**

This script will extend `GSMState` and get a typed reference to your actor.

```gdscript
# player_state.gd
class_name PlayerState extends GSMState

# Create a typed variable for your actor.
var player: Player = null

func _ready():
	# Assign the actor to the typed variable.
	# Now, any script that extends PlayerState will have a `player` property.
	self.player = self.gsm.actor
```

**2. Inherit from your base state:**

Now, make your individual state scripts (like `Idle`, `Run`, etc.) extend your new `PlayerState` instead of `GSMState`.

```gdscript
# idle.gd
extends PlayerState # <-- Inherit from your base state

func _enter(_args: Dictionary) -> void:
	# You can now access your actor's properties and methods
	# with full type-safety and autocompletion.
	self.player.animation_player.play("idle")

func _transition() -> Variant:
	if self.player.velocity.x != 0:
		return "Run"
	return null
```

This pattern keeps your state logic clean and reduces the chance of runtime errors.

## API Reference

### GSM (Node)

*   **`init_state: GSMState`**: (Export) The state to start in.
*   **`actor: Node`**: (Export) The node this state machine controls.
*   **`transition(to: String, args: Dictionary = {})`**: Changes the active state. The `args` dictionary is passed to the new state's `_enter` method.

### GSMState (Node)

*   **`transitions: Array[GSMTransition]`**: (Export) An array of declarative transition resources.
*   **`gsm: GSM`**: A reference to the parent `GSM` node.
*   **`_enter(args: Dictionary)`**: Lifecycle hook, called when the state is entered.
*   **`_exit()`**: Lifecycle hook, called when the state is exited.
*   **`_transition() -> Variant`**: Frame-by-frame transition check. Return a state name (`String`) to transition.

### Transition Resources

*   **`GSMInputTransition`**: Transitions on an `InputEvent`.
    *   `to: String`: Target state name.
    *   `input_action: String`: Input Map action name.
    *   `action_state: { PRESSED, RELEASED }`: The type of input to check for.
*   **`GSMFloorCheckTransition`**: Transitions based on the actor's floor status. Requires the `actor` to be a `CharacterBody2D`.
    *   `to: String`: Target state name.
    *   `on_floor: bool`: `true` to transition when on the floor, `false` to transition when in the air.
