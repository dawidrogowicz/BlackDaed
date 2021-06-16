extends Control

var _can_pause = true

func toggle_pause_menu():
	var next_state = not get_tree().paused
	get_tree().paused = next_state
	self.visible = next_state

func _input(event):
	if _can_pause and event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()
		
func _ready():
	EventBus.connect("player_killed", self, "_on_player_killed")

# Signals
func _on_player_killed():
	_can_pause = false

func _on_ResumeButton_pressed():
	toggle_pause_menu()
