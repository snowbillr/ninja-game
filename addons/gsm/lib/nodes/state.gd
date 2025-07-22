class_name GSMState
extends Node

@export var input_transitions: Array[GSMInputTransition] = []
@export var floor_check_transitions: Array[GSMFloorCheckTransition] = []

@onready var gsm: GSM = $".."

## Lifecycle

func _init():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _enter(args: Dictionary) -> void:
	pass
	
func _exit() -> void:
	pass

## Transition Handling

func _transition() -> Variant:
	return null
