extends Control

func _show_up():
	self.visible = true
	$AnimationPlayer.play("FadeIn")

func _restart():
	get_tree().reload_current_scene()
	
func _ready():
	EventBus.connect("player_killed", self, "_on_player_killed")

# Signals
func _on_player_killed():
	_show_up()

func _on_TitleScreenButton_pressed():
	pass # Replace with function body.

func _on_RestartButton_pressed():
	_restart()
