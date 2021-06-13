extends KinematicBody2D

const MOVACCEL = 32
const GRAVITY = 20

export var max_fall_speed = 600
export var max_mov_speed = 200
export var jump_accel = 400
export var max_health = 100

var _motion = Vector2.ZERO
var _facing_right = true
var _is_attacking = false
var _is_alive = true
var _double_jump_possible = false

onready var _double_jump_timer = $Timers/DoubleJumpTimer
onready var _wall_jump_timer = $Timers/WallJumpTimer
onready var _wall_touch_timer = $Timers/WallTouchTimer
onready var _invulnerability_timer = $Timers/InvulnerabilityTimer
onready var _health = max_health setget _set_health

func _set_health(new_health):
	var prev_health = _health
	_health = clamp(new_health, 0, max_health)
	if _health != prev_health:
		EventBus.emit_signal("player_health_changed", _health)
		if _health < 1:
			die();

func die():
	_is_alive = false
	_motion = Vector2.ZERO
	_motion = move_and_slide(_motion, Vector2.UP)
	$AnimatedSprite.rotate(PI / 2)
	$AnimatedSprite.stop()
	EventBus.emit_signal("player_killed")

func take_damage(dmg):
	var new_health = _health - dmg
	_set_health(new_health)

func run_animation():
	if !_is_alive:
		return
	if Input.is_action_just_pressed("lmb") && !_is_attacking:
		$AnimatedSprite.play("attack")
		_is_attacking = true
		return
	if _is_attacking:
		return
		
	if is_on_floor() && abs(_motion.x) > 1:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")
	
	if _facing_right:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

func handle_input(motion_vector):
	if !_is_alive:
		return motion_vector
	if Input.is_action_pressed("move_left"):
		motion_vector.x -= MOVACCEL
		_facing_right = false
	#		$AnimatedSprite.play("idle")
	elif Input.is_action_pressed("move_right"):
		motion_vector.x += MOVACCEL
		_facing_right = true
	else:
		motion_vector.x = lerp(motion_vector.x, 0, .24);
		
	if Input.is_action_just_pressed("jump"):
		if (is_on_floor()):
			motion_vector.y -= jump_accel
			_double_jump_possible = true
			_double_jump_timer.start()
		# Wall Jump
		elif !_wall_touch_timer.is_stopped() && _wall_jump_timer.is_stopped():
			motion_vector.y -= jump_accel * .9
			_wall_jump_timer.start()
		# Double Jump
		elif _double_jump_possible && _double_jump_timer.is_stopped():
			motion_vector.y -= jump_accel * .8
			_double_jump_possible = false
		
	if is_on_wall():
		motion_vector.y = clamp(motion_vector.y, -max_fall_speed/2, max_fall_speed/2)
		_wall_touch_timer.start()
	return motion_vector

# Lifecycles
func _ready():
	EventBus.connect("player_attacked", self, "_on_player_attacked")
	
func _physics_process(delta):
	_motion.y += GRAVITY
	_motion = handle_input(_motion)
	_motion.x = clamp(_motion.x, -max_mov_speed, max_mov_speed)
	_motion.y = clamp(_motion.y, -max_fall_speed, max_fall_speed)
	_motion = move_and_slide(_motion, Vector2.UP)
	run_animation()

# Signals
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		_is_attacking = false 

func _on_player_attacked(damage):
	if !_invulnerability_timer.is_stopped():
		return
	_invulnerability_timer.start()
	$AnimationPlayer.play("Damaged")
	$AnimationPlayer.queue("Invulnerable")
	take_damage(damage)
