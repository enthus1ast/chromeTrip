extends Control

signal restartGame

sync func rpcSetPause(val, playername):
	get_tree().get_nodes_in_group("currentPlayer")[0].resetKeys()
	print(val, " ", playername)
	var pauseGameScreen = get_tree().get_root().get_node("Control/PauseGameScreen")
#	if not is_network_master():
	if val:
		print("would show")
		pauseGameScreen.setPlayerPaused(playername)
	else:
		pauseGameScreen.hide()
	get_tree().set_pause(val)
	
func setPause(val):
	var playername = get_tree().get_nodes_in_group("currentPlayer")[0].playerName
	rpc("rpcSetPause",val, playername)

func showMenu():
	setPause(true)
	self.visible = true

func hideMenu():
	self.visible = false
	setPause(false)

func _ready():
	set_process_input(true)

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
				