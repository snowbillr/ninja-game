class_name GroundAttack
extends GSMState

var player: Player = null
var combo_attack: ComboAttack = null
var queue_next_attack := false

func _ready():
	self.player = self.gsm.actor
	
func _physics_process(_delta: float) -> void:
	self.player.velocity.x = lerp(self.player.velocity.x, 0.0, self.player.player_stats.friction_coefficient)
	self.player.velocity.y = lerp(self.player.velocity.y, 0.0, self.player.player_stats.friction_coefficient)

# args has the ComboAttack in it as "combo_attack"
func _enter(args: Dictionary):
	queue_next_attack = false
	combo_attack = args["combo_attack"]
	self.player.animation_tree.set_active(false)
	self.player.animation_player.animation_finished.connect(self._on_animation_finished)
	
	self.player.animation_player.play(self.combo_attack.attack.animation_name)

func _exit():
	self.player.animation_player.animation_finished.disconnect(self._on_animation_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		self.queue_next_attack = true
		
func _on_animation_finished(_animation_name: String):
	var next_attack = null

	if self.queue_next_attack:
		if Input.is_action_pressed("up") and combo_attack.next_up_attack != null:
			next_attack = combo_attack.next_up_attack
		elif Input.is_action_pressed("down") and combo_attack.next_down_attack != null:
			next_attack = combo_attack.next_down_attack
		elif combo_attack.next_attack != null:
			next_attack = combo_attack.next_attack

	if self.queue_next_attack && next_attack != null:
		self.gsm.transition(self.name, {"combo_attack": next_attack})
	else:
		var target_state = "ground" if self.player.is_on_floor() else "air"
		self.gsm.transition(target_state)
