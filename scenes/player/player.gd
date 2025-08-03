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

	# We always flip the X value of the scale when a new direction is set.
	# Note: Experimentation proved this method call is functionally equivalent to setting the self.scale.x directly.
	#       It seemed easier to understand to use the apply_scale method.
	self.apply_scale(Vector2(-1, 1))
