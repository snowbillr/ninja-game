class_name Player extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gsm: GSM = $GSM

@export var player_stats: PlayerStats = null
@export var air_movement_charges: AirMovementCharges = null


func _ready() -> void:
	gsm.start()

func _apply_horizontal_movement() -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	if x_input != 0:
		self.velocity.x = lerp(
			self.velocity.x,
			self.player_stats.max_speed * x_input,
			self.player_stats.acceleration_coefficient)
	else:
		self.velocity.x = lerp(
			self.velocity.x,
			0.0,
			self.player_stats.friction_coefficient)
	
func _apply_gravity() -> void:
	self.velocity.y = lerp(
		self.velocity.y,
		self.player_stats.max_gravity,
		self.player_stats.gravity_coefficient
	)
