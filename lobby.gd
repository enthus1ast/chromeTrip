extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const SERVER_PORT = 7000
var eNet
onready var ipInput = get_node("networkPanel/connect/ip")
onready var lobby = get_node("lobby")
onready var chatInput = lobby.get_node("Container/chatInput/chatInput")
#onready var playerList = lobby.get_node("Container/body/playerList")
onready var PlayerListElement = preload("res://playerListElement.tscn")
onready var Player = preload("res://player.tscn")
onready var Game = preload("res://game.tscn")
var game
var players = {}
var player_name
var currentPlayer = {
	"id":null,
	"name":"",
	"ready":null,
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

func _ready():
	eNet = NetworkedMultiplayerENet.new()
	ipInput.set_text("127.0.0.1")
#	chatInput.set_max_chars(100)
	
#	playerList.set_item_text()
	
#	server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
#	set_process(true)
	set_process_input(true)


func _player_connected(playerId):
	print("player has connected")

#Client sending to host
func _connected_ok():
	
	player_name = get_node("networkPanel/host/name").get_text()
	if player_name == "":
		player_name ="unnamed"
	currentPlayer.name = player_name
	rpc_id(1, "user_ready", get_tree().get_network_unique_id(), player_name)
	print("_connected_ok")
	lobby.set_visible(true)
	isConnecting = false

#server responding to Clients connect ok
remote func user_ready(id, player_name):
	print(id,player_name," ready")
	# Only the server can run this!
	if(get_tree().is_network_server()):
		rpc_id(id, "register_in_lobby")
		players[id] = player_name

remote func register_in_lobby():
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	get_node("lobby/Container/info/name").set_text("name: "+player_name)
	get_node("lobby/Container/info/ip").set_text("ip: "+str(IP.get_local_addresses()[1]))
#	register_new_player(get_tree().get_network_unique_id(), player_name)

# Register yourself directly ingame
remote func register_in_game():
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	register_new_player(get_tree().get_network_unique_id(), player_name)

remote func register_new_player(id, name):
	players[id] = name
# This runs only once from server
	if get_tree().is_network_server():
		# Send info about server to new player
		rpc("updateList",players)
		# Send the new player info about the other players
		for peer_id in players:
#			if peer_id!=1:
			rpc_id(id, "register_new_player", peer_id, players[peer_id])
#			rpc_id(id,"updateList",players)
			updateList(players)
	# Add new player to your player list

#	startGame()
	#	spawnPlayers() 
	
#	rpc("startGame")
	
func startGame():
	if get_tree().is_network_server():
		for p in players:
#			if p!=1:
			print(p,"=spawn by client")
#			rpc_id(p, "spawnPlayers")
#			spawnPlayers()
	print(players)

	
remote func spawnPlayers():
	
	get_node("networkPanel").set_visible(false)
	get_node("networkPanel/DialogWaiting").set_visible(false)
	if(has_node("game")):
		pass
	else:
		game = Game.instance()
		add_child(game)

	print(players)
	
	if get_tree().is_network_server():
		currentPlayer = Player.instance()
		currentPlayer.get_node("Label").set_text(player_name)
		game.get_node("players").add_child(currentPlayer)
		currentPlayer.set_network_master(1)
		currentPlayer.set_name(str(1))
	
	for p in players:# Create player instance
		var player = Player.instance()
		player.get_node("Label").set_text(player_name)
		# Set Player ID as node name - Unique for each player!
		player.set_name(str(p))
		
		# Set spawn position for the player (on a spawn point from the map)		
		# If the new player is you
		if (p == get_tree().get_network_unique_id()):
			# Set as master on yourself
			player.set_network_master(p)
#			player.add_child(camera_scene.instance()) # Add camera to your player
			
		else:
			
			# Add player name
			player.get_node("Label").set_text(str(players[p]))
		
		# Add the player (or you) to the world!
		game.get_node("players").add_child(player)
		
################## disconnected unregister
	
func _player_disconnected(_id):
	print("_player_disconnected")
	# If I am server, send a signal to inform that an player disconnected
	unregister_player(_id)
	rpc("unregister_player", _id)

remote func unregister_player(_id):
	# If the game is running
	if(has_node("game")):
		# Remove player from game
		if(has_node("game/players/" + str(_id))):
			get_node("game/players/" + str(_id)).queue_free()
		players.erase(_id)
	else:
		# Remove from lobby
		removeItemFromList(_id)
#		rpc("removeItemFromList",_id)
		players.erase(_id)
#		rpc("updateList",players)
		updateList(players)
#		get_node("game/players/" + str(id)).queue_free()
		emit_signal("refresh_lobby")

func _connected_fail():
	isConnecting = false
	get_tree().set_network_peer(null)
	eNet.close_connection()
	print("connection failed")
	emit_signal("connection_fail")
	
func _server_disconnected():
	lobby.set_visible(false)
	eNet.close_connection()
	eNet = NetworkedMultiplayerENet.new()
	get_tree().set_network_peer(null)
	players={}
	clearList()
	print("server closed")
#	quit_game()
#	emit_signal("server_ended")
	
	
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
	for peer_id in _list:
		addNewListItem(peer_id,_list[peer_id])

func addNewListItem(_id,_name):
	if !lobby.get_node("Container/body/RichTextLabel/VBoxContainer").has_node(str(_id)):
		var listItem = PlayerListElement.instance()
		listItem.get_node("id").set_text(str(_id))
		listItem.get_node("name").set_text(_name)
		var ready = listItem.get_node("readyCheckbox").pressed
		listItem.set_name(str(_id))
		lobby.get_node("Container/body/RichTextLabel/VBoxContainer").add_child(listItem)
		print(lobby.get_node("Container/body/RichTextLabel/VBoxContainer").get_children())
	
func _on_host_pressed():
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
	player_name = get_node("networkPanel/host/name").get_text()
	if player_name == "":
		player_name ="unnamed"
	lobby.set_visible(true)
	lobby.get_node("Container/info/ip").set_text("Ip: "+ str(IP.get_local_addresses()[1]))
	lobby.get_node("Container/info/name").set_text("name: "+player_name)
	players[get_tree().get_network_unique_id()]=player_name
	updateList(players)
	

func _on_connect_pressed():
	if !isConnecting:
		isConnecting = true
		var ip = ipInput.get_text()
		eNet.create_client(ip, SERVER_PORT)
		get_tree().set_network_peer(eNet)
	else:
		print("I am already trying to connect.")
	
func _on_sp_pressed():
#	game = load("res://game.tscn").instance()
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
	register_new_player(1,player_name)
	
func _on_cancel_pressed():
	get_node("Panel/DialogWaiting").set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	pass

func _on_leaveLobbyButton_pressed():
	lobby.set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	eNet = NetworkedMultiplayerENet.new()
	players={}
	clearList()
#	updateList(players)

func _on_chatInput_focus_entered():
#	get_node("lobby/Container/chatInput/chatInput").set_text("")
	pass
	
func _on_chatInput_focus_exited():
	pass

func _on_sendButton_pressed():
	rpc("sendMessage",player_name,chatInput.get_text())
	sendMessage(player_name,chatInput.get_text())

remote func sendMessage(_player,_value):

#	var value = chatInput.get_text()
	if _value.length() > 0:
		var message = Label.new()
		var scrollContainer = get_node("lobby/Container/chat/ScrollContainer") 
		message.set_text(_player+": "+_value)
		scrollContainer.get_node("VBoxContainer").add_child(message)
		print(scrollContainer.get_node("VBoxContainer").get_rect())
	#	get_node("lobby/Container/chat/ScrollContainer").get_item_and_children_rect().size.y
		scrollContainer.set_v_scroll(scrollContainer.get_item_and_children_rect().size.y)
		scrollContainer.update()
		chatInput.set_text("")

func _input(event):
	if event.is_action_pressed("ui_enter") and chatInput.has_focus():
		rpc("sendMessage",player_name,chatInput.get_text())
		sendMessage(player_name,chatInput.get_text())

