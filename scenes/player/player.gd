class_name Player extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var gsm: GSM = $GSM

@export var player_stats: PlayerStats = null
@export var air_movement_charges: AirMovementCharges = null


func _ready() -> void:
	gsm.start()
