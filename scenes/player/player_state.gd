class_name PlayerState extends GSMState

var player: Player = null

func _ready():
	self.player = self.gsm.actor
