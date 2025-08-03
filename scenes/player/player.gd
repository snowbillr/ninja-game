class_name Player extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var gsm: GSM = $GSM
@onready var direction_detector: Node = $DirectionDetector

@export var player_stats: PlayerStats = null
@export var air_movement_charges: AirMovementCharges = null

var direction: DirectionDetector.DIRECTION = DirectionDetector.DIRECTION.RIGHT

func _ready() -> void:
	direction_detector.direction_changed.connect(self._update_direction)
	
	gsm.start()

func _update_direction(new_direction: DirectionDetector.DIRECTION):
	self.direction = new_direction
	self.sprite_2d.flip_h = true if new_direction == DirectionDetector.DIRECTION.LEFT else false
