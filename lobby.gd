extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const SERVER_PORT = 7000
var eNet
onready var ipInput = get_node("networkPanel/connect/ip")
onready var lobby = get_node("lobby")
onready var chatInput = lobby.get_node("Container/chatInput/TextEdit")
#onready var playerList = lobby.get_node("Container/body/playerList")
onready var Player = preload("res://player.tscn")
onready var Game = preload("res://game.tscn")
var game
var players = {}
var player_name
var currentPlayer
var isConnecting = false

var isJumping = false
const SPEED = 200

signal refresh_lobby()
signal server_ended()
signal server_error()
signal connection_success()
signal connection_fail()

func _ready():
#	
	eNet = NetworkedMultiplayerENet.new()
	ipInput.set_text("127.0.0.1")
	chatInput.set_text("type Message here...")
	
#	playerList.set_item_text()
	
#	server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	set_process(true)


func _player_connected(playerId):
	print("player has connected")

#Client sending to host
func _connected_ok():
	rpc_id(1, "user_ready", get_tree().get_network_unique_id(), player_name)
	print("_connected_ok")
	isConnecting = false
#	startGame()
	
remote func user_ready(id, player_name):
	print(id,player_name," ready")
	# Only the server can run this!
	if(get_tree().is_network_server()):
		# If we are ingame, add player to session, else send to lobby	
		if(has_node("game")):
			rpc_id(id, "register_in_game")
		else:
			rpc_id(id, "register_in_game")
			print("register at lobby")

# Register yourself directly ingame
remote func register_in_game():
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	register_new_player(get_tree().get_network_unique_id(), player_name)

remote func register_new_player(id, name):
# This runs only once from server
	if get_tree().is_network_server():
		# Send info about server to new player
		rpc_id(id, "register_new_player", 1, player_name) 
		
		# Send the new player info about the other players
		for peer_id in players:
			rpc_id(id, "register_new_player", peer_id, players[peer_id]) 
		
	
	# Add new player to your player list
	players[id] = name
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
			print("FAIL")
			
#			player.add_child(camera_scene.instance()) # Add camera to your player
			
		else:
			
			# Add player name
			player.get_node("Label").set_text(str(players[p]))
		
		# Add the player (or you) to the world!
		game.get_node("players").add_child(player)
	
	
################## button pressed signals
func _on_host_pressed():
	player_name ="hihihostname"
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
#	get_node("Panel/DialogWaiting").set_visible(true)
	lobby.set_visible(true)

func _on_connect_pressed():
	if !isConnecting:
		isConnecting = true
		player_name ="hihiclientname"
		var ip = ipInput.get_text()
		eNet.create_client(ip, SERVER_PORT)
		get_tree().set_network_peer(eNet)
	else:
		print("I am already trying to connect.")
	
func _on_sp_pressed():
#	game = load("res://game.tscn").instance()
	player_name ="hihihostname"
	eNet.create_server(SERVER_PORT, 4)
	get_tree().set_network_peer(eNet)
	register_new_player(1,player_name)
	
func _on_cancel_pressed():
	get_node("Panel/DialogWaiting").set_visible(false)
	get_tree().set_network_peer(null)
	eNet.close_connection()
	pass # replace with function body
	
################## disconnected unregister
	
func _player_disconnected(id):
	print("_player_disconnected")
	# If I am server, send a signal to inform that an player disconnected
	unregister_player(id)
	rpc("unregister_player", id)

remote func unregister_player(id):
	# If the game is running
	if(has_node("game")):
		# Remove player from game
		if(has_node("game/players/" + str(id))):
			get_node("game/players/" + str(id)).queue_free()
		players.erase(id)
		print(players)
	else:
		# Remove from lobby
		players.erase(id)
		print(players)
		emit_signal("refresh_lobby")

func _connected_fail():
	isConnecting = false
	get_tree().set_network_peer(null)
	eNet.close_connection()
	print("connection failed")
	emit_signal("connection_fail")
	
func _server_disconnected():
	quit_game()
	emit_signal("server_ended")
	
#	rpc("setMove", currentPlayer,
#	game.get_node(player)
#	rset("position", currentPlayer.position)

sync func doMove(player, dir,delta):
	#print(player,dir,delta)
	if dir=="left":
#		game.get_node(player).get_node("Sprite/AnimationPlayer").play("trexAnimRun")
#		game.get_node(player).position.x-=delta*SPEED
#		game.get_node(player).apply_impulse(Vector2(0,0),Vector2(-80,0))
#		game.get_node(player).linear_velocity.x= -300
#		print(game.get_node(player).linear_velocity)
		pass
	elif dir=="right":
#		game.get_node(player).linear_velocity.x=300
#		game.get_node(player).set_linear_velocity(0,0)
#		game.get_node(player).apply_impulse(Vector2(0,0),Vector2(80,0))
#		game.get_node(player).position.x+=delta*SPEED
		pass

sync func doJump(player):
#	print(player)
#	if isJumping:
#	game.get_node(player).apply_impulse(Vector2(0,0),Vector2(0,-500))
#	game.get_node(player).set_axis_velocity(Vector2(0,-200))
#		isJumping=false
	pass

var keys = [false,false,false,false]

func _process(delta):
#	if game != null:
#		for player in game.get_node("players").get_children():
			
#			print("process control node:",player.slave_pos)
		
	if keys[0]:
		
#		rpc("doMove",currentPlayer ,"left",delta)
#		doMove(currentPlayer ,"left",delta)
		pass
	elif keys[1]:
#		doMove(currentPlayer ,"right",delta)
#		rpc("doMove",currentPlayer ,"right",delta)
		pass

remote func playAnim(player,_anim):
#	print(player.get_node("Sprite"))
	player.get_node("Sprite/AnimationPlayer").play(_anim)

func _input(event):
	if event.is_action_pressed("ui_left"):
#		rpc("playAnim",currentPlayer,"trexAnimRun")
		keys[0]=true
	elif event.is_action_released("ui_left"):
		keys[0]=false
#		rpc("playAnim",currentPlayer,"trexAnim")

	if event.is_action_pressed("ui_right"):
#		print(currentPlayer.get_node("Sprite/AnimationPlayer"))
		print("play")
#		rpc("playAnim",currentPlayer,"trexAnimRun")
		keys[1]=true
	elif event.is_action_released("ui_right"):
		keys[1]=false
#		rpc("playAnim",currentPlayer,"trexAnim")
#
#	if event.is_action_pressed("ui_up")||event.is_action_pressed("ui_accept"):
#		keys[2]=true
##		print("jump")
#		rpc("doJump",currentPlayer)
#	elif event.is_action_released("ui_up")||event.is_action_pressed("ui_accept"):
#		keys[2]=false
#
#	if event.is_action_pressed("ui_down"):
#		isJumping=true
#		keys[3]=true
#	elif event.is_action_released("ui_down"):
#		keys[3]=false
		

