class_name GSM
extends Node

@export var init_state: GSMState = null
@export var actor: Node = null

var state: GSMState = null

func _ready():
	self.state = init_state
	
	self.state._enter({})
	self.state.process_mode = Node.PROCESS_MODE_INHERIT

func transition(to: String, args: Dictionary = {}):
	var to_state = self.get_node(to)
	
	self.state._exit()
	self.state.process_mode = Node.PROCESS_MODE_DISABLED
	
	self.state = to_state
	
	self.state._enter(args)
	self.state.process_mode = Node.PROCESS_MODE_INHERIT

func get_state():
	return state
