extends KinematicBody2D

const DAMAGE = 60
const MAX_HEALTH = 100

var _is_alive = true

onready var _health = MAX_HEALTH setget _set_health


func _set_health(new_health):
	var prev_health = _health
	_health = clamp(new_health, 0, MAX_HEALTH)
	if _health != prev_health:
		if _health < 1:
			die();


func die():
	_is_alive = false
	$AnimatedSprite.rotate(PI / 2)
	$AnimatedSprite.position.y = $AnimatedSprite.position.y + 20
	$AnimatedSprite.stop()
	$DeathAudio.play()
	$GarbageTimer.start()


func take_damage(dmg):
	var new_health = _health - dmg
	_set_health(new_health)
	$AnimationPlayer.play("Damaged")


func _on_PlayerDetector_body_entered(body):
	if _is_alive:
		EventBus.emit_signal("player_attacked", DAMAGE)


func _on_GarbageTimer_timeout():
	self.queue_free()
