extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gsm: GSM = $GSM

@export var player_stats: PlayerStats = null
