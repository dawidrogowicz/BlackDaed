extends Control

func _initialize():
	var Player = get_node("/root/FirstLevel/Player")
	$ProgressBar.value = Player.max_health
	$ProgressBar.max_value = Player.max_health

func _ready():
	_initialize()
	EventBus.connect("player_health_changed", self, "_on_Player_health_changed")
	EventBus.connect("player_max_health_changed", self, "_on_Player_max_health_changed")

# Signals
func _on_Player_health_changed(health):
	$ProgressBar.value = health

func _on_Player_max_health_changed(max_health):
	$ProgressBar.max_value = max_health
