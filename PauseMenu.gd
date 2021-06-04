extends Control

func toggle_pause_menu():
	var next_state = not get_tree().paused
	get_tree().paused = next_state
	self.visible = next_state

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()

func _on_Button_pressed():
	toggle_pause_menu()
