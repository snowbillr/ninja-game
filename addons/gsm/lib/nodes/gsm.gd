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
	for state_transition in self.state.transitions:
		if state_transition is GSMFloorCheckTransition:
			if state_transition.satisfied(self.actor):
				self.transition(state_transition.to)

func _unhandled_input(event: InputEvent) -> void:
	for state_transition in self.state.transitions:
		if state_transition is GSMInputTransition:
			if state_transition.satisfied(event):
				self.transition(state_transition.to)
