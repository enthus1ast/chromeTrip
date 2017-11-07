extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_mouse_entered():
	get_node("ButRestart/ImgRestart").modulate = "d84848"
	print("entered")
	

func _on_Button_pressed():
	print("pressed")
	emit_signal("restartGame")


func _on_Button_mouse_exited():
	get_node("ButRestart/ImgRestart").modulate = "ffffff"
	print("exited")


func _on_GameOverScreen_visibility_changed():
	print("visibility_changed")
	pass # replace with function body


func _on_GameOverScreen_hide():
	print("hide called")
	pass # replace with function body
