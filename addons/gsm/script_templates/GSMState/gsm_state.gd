# This is a template for a GSMState.
# It provides the basic structure for a state in the Godot State Machine.
extends GSMState


# Called by the state machine when this state becomes active.
# `args` is an optional dictionary passed from the `gsm.transition()` call.
func _enter(args: Dictionary) -> void:
	pass


# Called by the state machine when this state is exited.
# Use this for cleanup logic.
func _exit() -> void:
	pass


# Called on every `_process` frame while the state is active.
# Return the name of another state to transition to it, or `null` to stay in the current state.
func _transition() -> Variant:
	return null
