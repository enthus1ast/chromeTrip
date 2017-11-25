extends Control

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	TranslationServer.add_translation( load("res://translation/translation.de.translation"))
	TranslationServer.add_translation( load("res://translation/translation.en.translation"))
#	TranslationServer.add_translation( load("res://translation/translation.ja.translation"))
#	TranslationServer.set_locale("de")
#	print("translation:", TranslationServer.translate("QUIT"))
#	TranslationServer.set_locale("en")
#	print("translation:", TranslationServer.translate("QUIT"))	

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
	