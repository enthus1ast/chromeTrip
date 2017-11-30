extends Control

func _ready():
	TranslationServer.add_translation( load("res://translation/translation.de.translation"))
	TranslationServer.add_translation( load("res://translation/translation.en.translation"))


func _on_ButtonQuit_pressed():
	get_tree().quit()

func _on_ButtonNewGame_pressed():
	pass # replace with function body
	self.hide()
	get_tree().get_root().get_node("Control/menu/networkPanel").show()
	get_tree().get_root().get_node("Control/menu/Highscore").hide()

func _on_HighScore_pressed():
	pass # replace with function body
	self.hide()
	get_tree().get_root().get_node("Control/menu/networkPanel").hide()
	get_tree().get_root().get_node("Control/menu/Highscore").show()


func _on_Settings_pressed():
	pass # replace with function body
	get_tree().get_root().get_node("Control/menu/Settings").show()
	

func _on_PopupMenu_visibility_changed():
	if visible:
		get_node("VBoxContainer/ButtonNewGame").grab_focus()
	pass # replace with function body
