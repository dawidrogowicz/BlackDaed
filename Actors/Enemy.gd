extends KinematicBody2D

const DAMAGE = 60
const MAX_HEALTH = 100
const DETECT_DISTANCE = 200

var DarkOrb = preload("res://Projectiles/DarkOrb.tscn")
var _is_alive = true

onready var _health = MAX_HEALTH setget _set_health
onready var _player_in_range = false

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


func attack():
	if !$AttackTimer.is_stopped() or !GlobalVariables.is_alive or !_player_in_range:
		return
		
	for node in get_tree().get_nodes_in_group("player"):
		var pos = get_position()
		var angle = pos.angle_to_point(node.global_position)
		var projectile = DarkOrb.instance()
		projectile.spawn(pos, angle)
		get_parent().add_child(projectile)
		$AttackTimer.start()
		return


func _on_PlayerDetector_body_entered(body):
	if _is_alive:
		EventBus.emit_signal("player_attacked", DAMAGE)


func _on_GarbageTimer_timeout():
	self.queue_free()


func _on_Area2D_body_entered(body):
	_player_in_range = true
	attack()


func _on_Area2D_body_exited(body):
	_player_in_range = false


func _on_AttackTimer_timeout():
	attack()
