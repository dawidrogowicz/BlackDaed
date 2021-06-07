extends KinematicBody2D
class_name Actor

signal death()
signal health_changed(health)
signal max_health_changed(max_health)

const UP = Vector2(0, -1)
const GRAVITY = 20
export var max_fall_speed = 600
export var max_mov_speed = 200
export var jump_accel = 400
export var max_health = 100

var motion = Vector2.ZERO
var facing_right = true
var is_attacking = false
var is_alive = true

onready var health = max_health setget _set_health
 
func _physics_process(delta):
	motion.y += GRAVITY * delta

func die():
	is_alive = false
	emit_signal('death')

func take_damage(dmg):
	var new_health = health - dmg
	_set_health(new_health)

func _set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_health)
	if health != prev_health:
		emit_signal('health_changed', health)
		if health < 1:
			die();

func _ready():
	emit_signal('health_changed', health)
	emit_signal('max_health_changed', max_health)
