class_name DirectionDetector
extends Node

enum DIRECTION { LEFT = -1, RIGHT = 1 }
signal direction_changed(direction: DIRECTION)

@export var target: CharacterBody2D

var direction := DIRECTION.RIGHT

func _physics_process(_delta: float) -> void:
	var previous_direction := direction
	
	if target.velocity.x < 0:
		direction = DIRECTION.LEFT
	elif target.velocity.x > 0:
		direction = DIRECTION.RIGHT

	if direction != previous_direction:
		direction_changed.emit(direction)
