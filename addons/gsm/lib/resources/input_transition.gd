class_name GSMInputTransition extends Resource

enum ACTION_STATE { PRESSED, RELEASED }

@export var to: String
@export var input_action: String
@export var action_state: ACTION_STATE = ACTION_STATE.PRESSED
