extends Control

func _show_up():
	self.visible = true
	$AnimationPlayer.play('FadeIn')

func _on_Player_death():
	_show_up()
