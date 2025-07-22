class_name GSM
extends Node

@export var init_state: GSMState = null
@export var actor: Node = null

var state: GSMState = null

func _ready():
	self.state = init_state

func _process(_delta: float) -> void:
	if self.state.process_mode == Node.PROCESS_MODE_INHERIT:
		var state_name = self.state._transition()
		if state_name != null:
			self.transition(state_name)
	
func start(args: Dictionary = {}):
	self.state._enter(args)
	self.state.process_mode = Node.PROCESS_MODE_INHERIT

func transition(to: String, args: Dictionary = {}):
	var to_state = self.get_node(to)
	
	self.state._exit()
	self.state.process_mode = Node.PROCESS_MODE_DISABLED
	
	self.state = to_state
	
	self.state._enter(args)
	self.state.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	for floor_check_transition in self.state.floor_check_transitions:
		if floor_check_transition.on_floor:
			if self.actor.is_on_floor():
				self.transition(floor_check_transition.to)
				return
		elif not floor_check_transition.on_floor:
			if not self.actor.is_on_floor():
				self.transition(floor_check_transition.to)
				return

func _unhandled_input(event: InputEvent) -> void:
	for input_transition in self.state.input_transitions:
		if input_transition.action_state == input_transition.ACTION_STATE.PRESSED:
			if event.is_action_pressed(input_transition.input_action):
				self.transition(input_transition.to)
				return
		elif input_transition.action_state == input_transition.ACTION_STATE.RELEASED:
			if event.is_action_released(input_transition.input_action):
				self.transition(input_transition.to)
				return
