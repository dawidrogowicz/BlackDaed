extends KinematicBody2D


const MOVACCEL = 32
const GRAVITY = 20

export var max_fall_speed = 600
export var max_mov_speed = 200
export var jump_accel = 400
export var max_health = 100
export var init_damage = 60

var is_alive = true

var _motion = Vector2.ZERO
var _is_attacking = false
var _double_jump_possible = false

onready var _health = max_health setget _set_health
onready var _damage = init_damage

func _set_health(new_health):
	var prev_health = _health
	_health = clamp(new_health, 0, max_health)
	if _health != prev_health:
		EventBus.emit_signal("player_health_changed", _health)
		if _health < 1:
			die();


func die():
	is_alive = false
	GlobalVariables.is_alive = false
	_motion = Vector2.ZERO
	_motion = move_and_slide(_motion, Vector2.UP)
	$Sprite.rotate(PI / 2)
	$Audio/PlayerDeath.play()
	$SpriteAnimationPlayer.stop()
	EventBus.emit_signal("player_killed")


func take_damage(dmg):
	if !$Timers/InvulnerabilityTimer.is_stopped():
		return
	$Timers/InvulnerabilityTimer.start()
	$FXAnimationPlayer.play("damaged")
	$FXAnimationPlayer.queue("invulnerable")
	$Audio/PlayerHit.play()
	
	var new_health = _health - dmg
	_set_health(new_health)


func handle_attack():
	if !is_alive:
		return
	if Input.is_action_just_pressed("lmb") and !_is_attacking:
		_is_attacking = true
		$SpriteAnimationPlayer.play("attack")
		$Timers/SlowAttackTimeoutTimer.start()
		return


func handle_animation():
	if !is_alive or _is_attacking:
		return
		
	if is_on_floor() and abs(_motion.x) > 1:
		$SpriteAnimationPlayer.play("walk")
	else:
		$SpriteAnimationPlayer.play("idle")
		

func handle_movement(motion_vector):
	if !is_alive:
		return motion_vector
		
	if Input.is_action_pressed("move_left"):
		motion_vector.x -= MOVACCEL
		$Sprite.scale.x = 1
		
	elif Input.is_action_pressed("move_right"):
		motion_vector.x += MOVACCEL
		$Sprite.scale.x = -1
		
	else:
		motion_vector.x = lerp(motion_vector.x, 0, .24);
		
	if Input.is_action_just_pressed("jump"):
		if (is_on_floor()):
			motion_vector.y -= jump_accel
			_double_jump_possible = true
			$Timers/DoubleJumpTimer.start()
		# Wall Jump
		elif !$Timers/WallTouchTimer.is_stopped() \
			and $Timers/WallJumpTimer.is_stopped():
			motion_vector.y -= jump_accel * .9
			$Timers/WallJumpTimer.start()
		# Double Jump
		elif _double_jump_possible and $Timers/DoubleJumpTimer.is_stopped():
			motion_vector.y -= jump_accel * .8
			_double_jump_possible = false
		
	if is_on_wall():
		motion_vector.y = \
			clamp(motion_vector.y, -max_fall_speed/2, max_fall_speed/2)
		$Timers/WallTouchTimer.start()
		
	return motion_vector


func play_attack_sound():
	for hit_body in $Sprite/SlowAttackArea.get_overlapping_bodies():
		if hit_body and not hit_body.is_in_group("player"):
			$Audio/Attacks/SlowHit.play()
			return
	
	$Audio/Attacks/SlowMiss.play()


# Lifecycles
func _ready():
	GlobalVariables.is_alive = true
	EventBus.connect("player_attacked", self, "_on_player_attacked")
	
	
func _physics_process(delta):
	_motion.y += GRAVITY
	_motion = handle_movement(_motion)
	_motion.x = clamp(_motion.x, -max_mov_speed, max_mov_speed)
	_motion.y = clamp(_motion.y, -max_fall_speed, max_fall_speed)
	_motion = move_and_slide(_motion, Vector2.UP)
	handle_attack()
	handle_animation()


# Signals
func _on_player_attacked(damage):
	take_damage(damage)


func _on_SlowAttackTimeout_timeout():
	$Timers/SlowAttackTimer.start()
	$Sprite/SlowAttackArea.monitoring = true


func _on_SlowAttackTimer_timeout():
	play_attack_sound()
			
	$Sprite/SlowAttackArea.monitoring = false
	_is_attacking = false


func _on_SlowAttackArea_body_entered(body):
	if body.is_in_group("vulnerable") and body.has_method("take_damage"):
		body.take_damage(_damage)
