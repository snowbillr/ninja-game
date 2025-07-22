class_name GSMState
extends Node

@onready var gsm: GSM = $".."

func _ready():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _enter(args: Dictionary) -> void:
	pass
	
func _check_transitions():
	pass
	
func _exit() -> void:
	pass
