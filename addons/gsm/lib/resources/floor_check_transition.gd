class_name GSMFloorCheckTransition extends GSMTransition

@export var to: String
@export var on_floor: bool

func satisfied(actor: CharacterBody2D) -> bool:
	return self.on_floor == actor.is_on_floor()
