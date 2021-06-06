extends Actor

const MOVACCEL = 32

var _double_jump_possible = false

onready var _double_jump_timer = $Timers/DoubleJumpTimer
onready var _wall_jump_timer = $Timers/WallJumpTimer
onready var _wall_touch_timer = $Timers/WallTouchTimer
onready var _invulnerability_timer = $Timers/InvulnerabilityTimer

func run_animation():
	if !is_alive:
		return
	if Input.is_action_just_pressed('lmb') && !is_attacking:
		$AnimatedSprite.play('attack')
		is_attacking = true
		return
	if is_attacking:
		return
		
	if is_on_floor() && abs(motion.x) > 1:
		$AnimatedSprite.play('walk')
	else:
		$AnimatedSprite.play('idle')
	
	if facing_right:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

func handle_input(motion_vector):
	if !is_alive:
		return motion_vector
	if Input.is_action_pressed('move_left'):
		motion_vector.x -= MOVACCEL
		facing_right = false
	#		$AnimatedSprite.play('idle')
	elif Input.is_action_pressed('move_right'):
		motion_vector.x += MOVACCEL
		facing_right = true
	else:
		motion_vector.x = lerp(motion_vector.x, 0, .24);
		
	if Input.is_action_just_pressed('jump'):
		if (is_on_floor()):
			motion_vector.y -= jump_accel
			_double_jump_possible = true
			_double_jump_timer.start()
		elif !_wall_touch_timer.is_stopped() && _wall_jump_timer.is_stopped():
			motion_vector.y -= jump_accel * 1.2 
			_wall_jump_timer.start()
		elif _double_jump_possible && _double_jump_timer.is_stopped():
			motion_vector.y -= jump_accel * 1.4
			_double_jump_possible = false
		
	if is_on_wall():
		motion_vector.y = clamp(motion_vector.y, -max_fall_speed/2, max_fall_speed/2)
		_wall_touch_timer.start()
	return motion_vector

func _physics_process(delta):
	motion = handle_input(motion)
	motion.x = clamp(motion.x, -max_mov_speed, max_mov_speed)
	motion.y = clamp(motion.y, -jump_accel, max_fall_speed)
	motion = move_and_slide(motion, UP)
	run_animation()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'attack':
		is_attacking = false 

func _on_EnemyDetector_area_entered(area):
	if !_invulnerability_timer.is_stopped():
		return
	_invulnerability_timer.start()
	$AnimationPlayer.play('Damaged')
	$AnimationPlayer.queue('Invulnerable')
	take_damage(40)

func _on_Player_death():
	$AnimatedSprite.rotate(PI / 2)
	$AnimatedSprite.stop()
