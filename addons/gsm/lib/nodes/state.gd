class_name GSMState
extends Node

@export var transitions: Array[GSMTransition] = []

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
