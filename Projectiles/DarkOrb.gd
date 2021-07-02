extends KinematicBody2D

export var speed = 200
export var damage = 20

var velocity = Vector2.ZERO


func spawn(pos, angle):
	position = pos
	$Sprite.rotation = angle
	velocity = Vector2(-speed, 0).rotated(angle)


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		self.queue_free()


func _on_PlayerDetector_body_entered(body):
	EventBus.emit_signal("player_attacked", damage)


func _on_Lifespan_timeout():
	self.queue_free()
