extends Node2D
signal restartGame

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_enter") and visible:
		emit_signal("restartGame")

func _on_Button_mouse_entered():
	get_node("ButRestart/ImgRestart").modulate = "d84848"
	
func _on_Button_pressed():
	emit_signal("restartGame")

func _on_Button_mouse_exited():
	get_node("ButRestart/ImgRestart").modulate = "ffffff"

func _on_GameOverScreen_visibility_changed():
	print("visibility_changed")
	if self.visible == true: # TODO?
		get_node("AnimationPlayer").play("s")

func _on_GameOverScreen_hide():
	pass # replace with function body
