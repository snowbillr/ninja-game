class_name GSMState
extends Node

@export var transitions: Array[GSMInputTransition] = []

@onready var gsm: GSM = $".."

func _ready():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _enter(args: Dictionary) -> void:
	pass
	
func _check_transitions():
	pass
	
func _exit() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	for transition in transitions:
		if transition is GSMInputTransition:
			if transition.action_state == transition.ACTION_STATE.PRESSED:
				if event.is_action_pressed(transition.input_action):
					self.gsm.transition(transition.to)
					return
			elif transition.action_state == transition.ACTION_STATE.RELEASED:
				if event.is_action_released(transition.input_action):
					self.gsm.transition(transition.to)
					return
