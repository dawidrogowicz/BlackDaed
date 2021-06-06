extends Control

func _on_Player_health_changed(health):
	$ProgressBar.value = health


func _on_Player_max_health_changed(max_health):
	$ProgressBar.max_value = max_health
