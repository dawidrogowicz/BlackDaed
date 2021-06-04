extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const UP = Vector2(0, -1)
const GRAVITY = 20
const MAXFALLSPEED = 600
const MAXMOVSPEED = 200
const JUMPACCEL = 400
const MOVACCEL = 32

var motion = Vector2(0, 0)
var double_jump_possible = false
var jump_time = 0
var wall_jump_time = 0
var wall_touch_time = 0
var facing_right = true
var is_attacking = false

func run_animation():
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

func _on_animation_finished():
	if $AnimatedSprite.animation == 'attack':
		is_attacking = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.connect('animation_finished', self, '_on_animation_finished')	
	pass # Replace with function body.

func _physics_process(delta):

	motion.y += GRAVITY
	
	if Input.is_action_pressed('move_left'):
		motion.x -= MOVACCEL
		facing_right = false
#		$AnimatedSprite.play('idle')
	elif Input.is_action_pressed('move_right'):
		motion.x += MOVACCEL
		facing_right = true
	else:
		motion.x = lerp(motion.x, 0, .24);
		
	var ticks = OS.get_ticks_msec()
		
	if Input.is_action_just_pressed('jump'):
		if (is_on_floor()):
			motion.y -= JUMPACCEL
			double_jump_possible = true
			jump_time = ticks
		elif ticks - wall_touch_time < 150 && ticks - wall_jump_time > 1000:
			motion.y -= JUMPACCEL * 1.2 
			wall_jump_time = ticks
		elif double_jump_possible && (ticks - jump_time > 256):
			motion.y -= JUMPACCEL * 1.4
			double_jump_possible = false
		
	if is_on_wall():
		motion.y = clamp(motion.y, -MAXFALLSPEED/2, MAXFALLSPEED/2)
		wall_touch_time = ticks
		
	motion.x = clamp(motion.x, -MAXMOVSPEED, MAXMOVSPEED)
	motion.y = clamp(motion.y, -JUMPACCEL, MAXFALLSPEED)
	
	run_animation()	
			
	motion = move_and_slide(motion, UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
