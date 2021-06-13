extends KinematicBody2D

const DAMAGE = 60

func _on_PlayerDetector_body_entered(body):
	EventBus.emit_signal("player_attacked", DAMAGE)
