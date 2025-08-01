extends PlayerState


func _ready() -> void:
	super()

func _enter(_args: Dictionary):
	super(_args)
	self.player.animation_tree.animation_finished.connect(self._on_animation_finished)

func _exit():
	self.player.animation_tree.animation_finished.disconnect(self._on_animation_finished)

func _on_animation_finished(_animation_name: String):
	self.gsm.transition("air")
