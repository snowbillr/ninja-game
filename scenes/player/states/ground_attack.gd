class_name GroundAttack
extends GSMState

var player: Player = null
var combo_attack: ComboAttack = null
var queue_next_attack := false

func _ready():
	self.player = self.gsm.actor

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
	if (self.queue_next_attack):
		if Input.is_action_pressed("up") and combo_attack.next_up_attack != null:
			self.gsm.transition(self.name, {"combo_attack": combo_attack.next_up_attack})
		elif Input.is_action_pressed("down") and combo_attack.next_down_attack != null:
			self.gsm.transition(self.name, {"combo_attack": combo_attack.next_down_attack})
		elif combo_attack.next_attack != null:
			self.gsm.transition(self.name, {"combo_attack": combo_attack.next_attack})
	else:
		self.gsm.transition("ground")
