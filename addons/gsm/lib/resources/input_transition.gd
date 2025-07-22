class_name GSMInputTransition extends GSMTransition

enum ACTION_STATE { PRESSED, RELEASED }

@export var to: String
@export var input_action: String
@export var action_state: ACTION_STATE = ACTION_STATE.PRESSED

func satisfied(event: InputEvent) -> bool:
	if self.action_state == ACTION_STATE.PRESSED:
		return event.is_action_pressed(self.input_action)
	elif self.action_state == ACTION_STATE.RELEASED:
		return event.is_action_released(self.input_action)
	else:
		return false
