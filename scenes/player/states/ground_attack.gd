extends PlayerState


@export var attack: ComboAttack


var queue_next_attack := false

func _ready() -> void:
	super()

func _physics_process(_delta: float) -> void:
	self.player._apply_horizontal_movement()

func _enter(_args: Dictionary):
	super(_args)
	self.player.animation_tree.animation_finished.connect(self._on_animation_finished)
	
func _exit():
	self.queue_next_attack = false
	self.player.animation_tree.animation_finished.disconnect(self._on_animation_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		self.queue_next_attack = true

func _on_animation_finished(_animation_name: String):
	if (self.queue_next_attack):
		if Input.is_action_pressed("up"):
			self.gsm.transition("ground_attack_up")
		else:
			self.gsm.transition("ground_attack_2")
	else:
		self.gsm.transition("ground")
