extends Control

const SERVER_PORT = 7000
const INSTANT_READY = false
const REQUIRED_PLAYERS = 2
const GAME_COUNTDOWN = 1 #time to start in lobby

onready var musicPlayer = get_node("musicPlayer")
onready var menu = get_node("menu")
onready var lobby = menu.get_node("lobby")
onready var startButton = lobby.get_node("Container/startLobbyButton")
onready var chatInput = lobby.get_node("Container/chatInput/chatInput")
onready var networkPanel = get_node("menu/networkPanel")
onready var mainMenu = get_node("menu/MainMenu")
onready var nameInput = networkPanel.get_node("name")
onready var highscore = get_node("menu/Highscore")
onready var ipInput = networkPanel.get_node("connect/ip")
onready var version = get_node("menu/Version")
onready var pingTimeout = get_node("networkHud/CanvasLayer/pingTimeout")

onready var dialogWaiting = get_node("menu/DialogWaiting")
#onready var playerList = lobby.get_node("Container/body/playerList")
onready var PlayerListElement = preload("res://playerListElement.tscn")
onready var Player = preload("res://player.tscn")
onready var Game = preload("res://game.tscn")

var countdown
var countdownActive = false
var countdownRemaining = GAME_COUNTDOWN
var allReady = false
var eNet
var game
var players = {}
var player_name
var currentPlayer = {
	"id":null,
	"name":"",
	"isReady":null,
	"node":null
}
var isConnecting = false

var isJumping = false
const SPEED = 200

signal refresh_lobby()
signal server_ended()
signal server_error()
signal connection_success()
signal connection_fail()
signal pong

func _ready():
	musicPlayer.connect("finished",self,"loopMusic")
#	OS.set_low_processor_usage_mode(true)
	eNet = NetworkedMultiplayerENet.new()
	# load params from config
	ipInput.set_text( utils.config.get_value("player", "defaultserver", ""))
	nameInput.set_text( utils.config.get_value("player", "defaultname") )
	version.set_text(version.text + str(utils.version))
#	chatInput.set_max_chars(100)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	set_process(false)
	set_process_input(true)

remote func ping(_id, _remoteUnixTime):
	## client pings the server
	var localUnixTime = OS.get_unix_time()
	rpc_id(_id, "pong", get_tree().get_network_unique_id(), _remoteUnixTime, localUnixTime)
	
remote func pong(_id, _remoteUnixTime, _localUnixTime):
	var timeout = _localUnixTime - _remoteUnixTime
	print("Received pong")
	emit_signal("pong",  _remoteUnixTime, _localUnixTime, timeout)
	
func _player_connected(playerId):
	print("player has connected")

#Client sending to host
func _connected_ok():
	currentPlayer.name = nameInput.get_text()
	if currentPlayer.name == "":
		currentPlayer.name ="unnamed"
	currentPlayer.isReady = false
	currentPlayer.id = get_tree().get_network_unique_id()
	rpc_id(1, "user_ready", currentPlayer)
	print("_connected_ok",currentPlayer.id)
	lobby.set_visible(true)
	dialogWaiting.set_visible(false)
	isConnecting = false
	get_node("networkHud/Timer").start()
	


#server responding to Clients connect ok
remote func user_ready(_player):
	if(get_tree().is_network_server()):
		players[_player.id] = {}
		players[_player.id].id = _player.id
		players[_player.id].name = _player.name
		players[_player.id].isReady = _player.isReady
		rpc_id(_player.id, "register_in_lobby")

remote func register_in_lobby():
	rpc("register_new_player", currentPlayer)
	lobby.get_node("Container/info/name").set_text("name: "+currentPlayer.name)
	lobby.get_node("Container/info/ip").set_text("ip: "+str(IP.get_local_addresses()[1]))

remote func register_new_player(_player):
	players[_player.id] = {}
	players[_player.id].id = _player.id
	players[_player.id].name = _player.name
	players[_player.id].isReady = _player.isReady
	
	if get_tree().is_network_server():
		rpc("updateList",players)
		for peer_id in players:
			rpc_id(_player.id, "register_new_player", players[peer_id])
			updateList(players)
		areAllReady()

remote func startGame():
	print("startGame was called")
	## Safe new config values
	utils.config.set_value("player", "defaultname", nameInput.get_text())
	utils.config.set_value("player", "defaultserver", ipInput.get_text())
	utils.config.save(utils.CONFIG_PATH)
	var cnt = 0
	for p in players:
		players[p].node = Player.instance()
		players[p].node.name = players[p].name
		players[p].node.get_node("Label").set_text(players[p].name)
#		players[p].node.get_node("Label").set("custom_colors/font_color" ,computeColor(players[p].name))
		players[p].node.get_node("Label").add_color_override("font_color" ,utils.computeColor(players[p].name))
		
		# Set initial position, not spawning behind each other 
		players[p].node.position = Vector2(10 + cnt, 0)
		cnt+= 5 +  players[p].node.get_node("Sprite").get_region_rect().size.x * players[p].node.get_node("Sprite").scale.x
		
#		Sprite
		players[p].node.get_node("Sprite").modulate =  utils.computeColor(players[p].name)
	
		# Set Player ID as node name - Unique for each player!
		players[p].node.set_name(str(p))
		players[p].node.set_network_master(0)
		if (players[p].id == currentPlayer.id and players[p].name == currentPlayer.name):
			players[p].node.set_network_master(players[p].id)
#		print("players:",players[p]," for ",currentPlayer.name)
	if has_node("game"):
		pass
	else:
		game = Game.instance()
		for p in players:
			game.get_node("players").add_child(players[p].node)
		add_child(game)

func _player_disconnected(_id):
	print("_player_disconnected")
	# If I am server, send a signal to inform that an player disconnected
	unregister_player(_id)
	rpc("unregister_player", _id)

remote func unregister_player(_id):
	if(has_node("game")):
		# Remove player from game
		if(has_node("game/players/" + str(_id))):
			get_node("game/players/" + str(_id)).queue_free()
		players.erase(_id)
	else:
		# Remove from lobby
		removeItemFromList(_id)
		players.erase(_id)
		updateList(players)
		emit_signal("refresh_lobby")

func _connected_fail():
	isConnecting = false
	dialogWaiting.set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	print("connection failed")
	emit_signal("connection_fail")
	
func _server_disconnected():
	lobby.set_visible(false)
	menu.set_visible(true)
	call_deferred("remove_child",game)
	game.queue_free()
	eNet.close_connection()
	eNet = NetworkedMultiplayerENet.new() #workaround
	get_tree().set_network_peer(null)
	players={}
	clearList()
	clearChat()
	print("server closed")
	
################## button pressed signals
remote func clearList():
	var children = lobby.get_node("Container/body/RichTextLabel/VBoxContainer").get_children()
	for item in children:
		if item !=lobby.get_node("Container/body/RichTextLabel/VBoxContainer").get_child(0):
			lobby.get_node("Container/body/RichTextLabel/VBoxContainer").remove_child(item)
			item.queue_free()
			
remote func removeItemFromList(_id):
	if lobby.get_node("Container/body/RichTextLabel/VBoxContainer").has_node(str(_id)):
		var item = lobby.get_node("Container/body/RichTextLabel/VBoxContainer").get_node(str(_id))
		lobby.get_node("Container/body/RichTextLabel/VBoxContainer").remove_child(item)
		item.queue_free()
	
remote func updateList(_list):
	print("updateList: ",_list)
#	clearList()
	for peer in _list:
		addNewListItem(_list[peer])

func addNewListItem(_peer):
	if !lobby.get_node("Container/body/RichTextLabel/VBoxContainer").has_node(str(_peer.id)):
		var listItem = PlayerListElement.instance()
		listItem.get_node("id").set_text(str(_peer.id))
		listItem.get_node("name").set_text(_peer.name)
		listItem.get_node("name").add_color_override("font_color" ,utils.computeColor(_peer.name))
		if currentPlayer.id!=_peer.id:
			listItem.get_node("readyCheckbox").disabled=true
			if _peer.isReady:
				listItem.get_node("readyCheckbox").pressed=true
		listItem.set_name(str(_peer.id))
		lobby.get_node("Container/body/RichTextLabel/VBoxContainer").add_child(listItem)
		listItem.get_node("readyCheckbox").connect("pressed",self,"_on_checkbox_pressed")

func areAllReady():
	if get_tree().is_network_server():
		var isReadyCount = 0
		var playerCount = players.size()
		for peer in players:
			if players[peer].isReady:
				isReadyCount+=1
		if isReadyCount == playerCount:
			print("all ready")
			allReady = true
			rpc("toggleStartButton",allReady)
		else:
			print("waiting for all to be ready")
			allReady = false
			rpc("toggleStartButton",allReady)

sync func toggleStartButton(_mode):
	if _mode:
		startButton.disabled = false
	else:
		startButton.disabled = true

remote func setChecked(_id):
	var _checkbox = lobby.get_node("Container/body/RichTextLabel/VBoxContainer").get_node(str(_id)).get_node("readyCheckbox")
	if _checkbox.pressed:
		players[_id].isReady=false
		_checkbox.pressed=false
	else:
		players[_id].isReady=true
		_checkbox.pressed=true
	areAllReady()

remote func changeReady(_id):
	if get_tree().is_network_server():
		if _id!=1:
			setChecked(_id)
		elif !players[_id].isReady:
			currentPlayer.isReady=true
			players[_id].isReady=true
		elif players[_id].isReady:
			currentPlayer.isReady=false
			players[_id].isReady=false
		for peer in players:
			if peer!=1 and players[peer].id!=_id:
				rpc_id(peer,"setChecked",_id)

func _on_checkbox_pressed():
	if get_tree().is_network_server():
		changeReady(currentPlayer.id)
		areAllReady()
	else:
		rpc_id(1,"changeReady",currentPlayer.id)

func _on_host_pressed():
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
	currentPlayer.name = nameInput.get_text()
	if currentPlayer.name == "":
		currentPlayer.name ="unnamed"
	currentPlayer.id = 1
	currentPlayer.isReady = false
	var id = get_tree().get_network_unique_id()
	lobby.set_visible(true)
	lobby.get_node("Container/info/ip").set_text("Ip: "+ str(IP.get_local_addresses()[1]))
	lobby.get_node("Container/info/name").set_text("name: "+currentPlayer.name)
	players[id] = {}
	players[id].name = currentPlayer.name
	players[id].id = id
	players[id].isReady = currentPlayer.isReady
	updateList(players)

func _on_connect_pressed():
	if !isConnecting:
		dialogWaiting.set_visible(true)
		isConnecting = true
		var hostname = ipInput.get_text()
		var ip = IP.resolve_hostname(hostname)
		
		eNet.create_client(ip, SERVER_PORT)
		get_tree().set_network_peer(eNet)
	else:
		print("I am already trying to connect.")
	
func _on_sp_pressed():
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
	currentPlayer.name = nameInput.get_text()
	if currentPlayer.name == "":
		currentPlayer.name ="unnamed"
	currentPlayer.id = 1
	currentPlayer.isReady = false
	var id = get_tree().get_network_unique_id()
	players[id] = {}
	players[id].name = currentPlayer.name
	players[id].id = id
	players[id].isReady = currentPlayer.isReady
	updateList(players)
	startGame()
	
func _on_cancel_pressed():
	dialogWaiting.set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	isConnecting = false
	eNet = NetworkedMultiplayerENet.new()
	pass

func _on_leaveLobbyButton_pressed():
	lobby.set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	eNet = NetworkedMultiplayerENet.new()
	players={}
	clearList()
	clearChat()

func _on_chatInput_focus_entered():
	pass
	
func _on_chatInput_focus_exited():
	pass

func _on_sendButton_pressed():
	rpc("sendMessage",currentPlayer.name,chatInput.get_text())
	sendMessage(currentPlayer.name,chatInput.get_text())

remote func sendMessage(_player,_value):
	if _value.length() > 0:
		var message = Label.new()
		var scrollContainer = lobby.get_node("Container/chat/ScrollContainer") 
		message.set_text(_player+": "+_value)
		message.add_color_override("font_color" ,utils.computeColor(_player))
		scrollContainer.get_node("VBoxContainer").add_child(message)
		scrollContainer.set_v_scroll(scrollContainer.get_item_and_children_rect().size.y)
		scrollContainer.update()
		chatInput.set_text("")
		
func _on_clearChat_pressed():
	clearChat()
	
func clearChat():
	var vBox = lobby.get_node("Container/chat/ScrollContainer/VBoxContainer")
	for child in vBox.get_children():
		vBox.remove_child(child)
		child.queue_free()

remote func _on_startLobbyButton_pressed():
	if get_tree().is_network_server():
		if allReady and !countdownActive:
			countdownRemaining = GAME_COUNTDOWN
			countdownActive=true
			countdown = Timer.new()
			startButton.add_child(countdown)
			countdown.connect("timeout",self,"_countdown_timeout")
			rpc("sendMessage","SERVER","Starting in "+str(countdownRemaining))
			sendMessage("SERVER","Starting in "+str(countdownRemaining))
			rpc("setStartButtonText",str(countdownRemaining))
			countdown.wait_time = 1
			countdown.start()
	else:
		rpc_id(1,"_on_startLobbyButton_pressed")
		
func _countdown_timeout():
	if get_tree().is_network_server():
		if allReady:
			if countdownRemaining > 1:
				countdownRemaining-=1
				rpc("sendMessage","SERVER","Starting in "+str(countdownRemaining))
				sendMessage("SERVER","Starting in "+str(countdownRemaining))
				rpc("setStartButtonText",str(countdownRemaining))
			elif countdownRemaining==1:
				rpc("setStartButtonText","Start")
				rpc("prepareGame")
		else:
			rpc("setStartButtonText","Start")
			rpc("sendMessage","SERVER","Aborted by user.")
			sendMessage("SERVER","Aborted by user.")
			countdown.disconnect("timeout",self,"_countdown_timeout")
			countdown.queue_free()
			countdownRemaining = GAME_COUNTDOWN
			countdownActive = false

sync func setStartButtonText(_string):
	startButton.set_text(_string)

sync func prepareGame():
	menu.set_visible(false)
	if get_tree().is_network_server():
		countdown.disconnect("timeout",self,"_countdown_timeout")
		countdown.queue_free()
		countdownRemaining = GAME_COUNTDOWN
		countdownActive = false
		startGame()
		rpc("startGame")

func _input(event):
	if event.is_action_pressed("ui_enter") and chatInput.has_focus():
		rpc("sendMessage",currentPlayer.name,chatInput.get_text())
		sendMessage(currentPlayer.name,chatInput.get_text())

func askForRestartGame():
	rpc("restartGame")

sync func restartGame():
	remove_child(game)
	game.queue_free()	
	if get_tree().is_network_server():
		startGame()
		rpc("startGame")	
	
func _on_name_text_changed( text ):
	nameInput.set("custom_colors/font_color", utils.computeColor(text))
	
func _on_back_pressed():
	networkPanel.hide()
	highscore.hide()
	mainMenu.show()


func loopMusic():
	musicPlayer.play()

func _on_Control_pong(_remoteUnixTime, _localUnixTime, _timeout):
	pass # replace with function body
	pingTimeout.text = str(_timeout)
	
func _on_Timer_timeout():
	if not get_tree().is_network_server():
		rpc_id(1, "ping", get_tree().get_network_unique_id(), OS.get_unix_time())