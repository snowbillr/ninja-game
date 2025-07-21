extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 150.0
@export var max_gravity: float = 400.0
@export var friction_coefficient: float = 0.25
@export var acceleration_coefficient: float = 0.25
@export var gravity_coefficient: float = 0.03

enum state { IDLE, RUNNING, FALLING }

var state_machine = state.IDLE

func _ready() -> void:
	state_machine = state.IDLE

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")

	match state_machine:
		state.IDLE:
			animation_player.play("idle")
			
			if x_input != 0:
				state_machine = state.RUNNING
				sprite_2d.flip_h = true if sign(x_input) == -1 else false
			elif not is_on_floor():
				state_machine = state.FALLING
			else:
				self.velocity.x = lerp(self.velocity.x, 0.0, friction_coefficient)
				
			move_and_slide()
		state.RUNNING:
			animation_player.play("run")
		
			if not is_on_floor():
				state_machine = state.FALLING
			elif x_input == 0:
				state_machine = state.IDLE
			else:
				self.velocity.x = lerp(self.velocity.x, speed * sign(x_input), 0.25)
			
			move_and_slide()
		state.FALLING:
			if is_on_floor():
				state_machine = state.IDLE
			else:
				velocity.y = lerp(self.velocity.y, max_gravity, gravity_coefficient)
				
			move_and_slide()
