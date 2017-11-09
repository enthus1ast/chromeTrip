extends Control

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_ButtonQuit_pressed():
	get_tree().quit()

func _on_ButtonNewGame_pressed():
	pass # replace with function body
	self.hide()
	get_tree().get_root().get_node("Control/menu/networkPanel").show()
	
