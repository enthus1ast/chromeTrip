extends Control

signal restartGame
signal resetKeys # to reset the pressed keys

sync func rpcSetPause(val):
#	emit_signal("resetKeys")
	get_tree().get_nodes_in_group("currentPlayer")[0].resetKeys()
	get_tree().set_pause(val)
	
func setPause(val):
	rpc("rpcSetPause",val)

func showMenu():
	setPause(true)
	self.visible = true

func hideMenu():
	self.visible = false
	setPause(false)

func _ready():
	set_process_input(true)
	pass

func _on_ButtonResume_pressed():
	hideMenu()

func _on_ButtonRestart_pressed():
	setPause(false)
	emit_signal("restartGame")

func _on_ButtonMenu_pressed():
	setPause(false)
	get_tree().change_scene("res://lobby.tscn")

func _on_ButtonQuit_pressed():
	setPause(false)
	get_tree().quit()

func _on_Settings_pressed():
	get_tree().get_root().get_node("Control/menu/Settings").show()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if self.visible:
			self.hideMenu()
		else:
			self.showMenu()