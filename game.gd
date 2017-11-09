extends Control
var offsetX
var offsetY = -50

onready var Restartpoint = preload("res://restartPoint.tscn")
onready var Obstacles = preload("res://assets/obstacles.tscn")
onready var Enemys = preload("res://assets/enemys.tscn")
onready var Collectables = preload("res://assets/collectables.tscn")
onready var Wolke = preload("res://Wolke.tscn")
onready var viewportSize = get_viewport().size

var fakeSpeed=300
var players
var score = 0
var finalScore = 0
var distanceWalked = 0

var stage = 1 # each 5000 points one stage
var nextLevel = 5000

var placeholderScore
var placeholderScoreSize
var spriteWidth
var obstaclesCount = 8
var enemysCount = 8
var wolkenMaxCount = 10
var collectablesCount = 8
var allDead = false

onready var playersNode = get_node("players")
onready var cameraNode = get_node("cameraNode")
onready var spritesNode = get_node("sprites")
onready var enemysNode = spritesNode.get_node("enemys")
onready var collectablesNode = spritesNode.get_node("collectables")
onready var constMoveNode = spritesNode.get_node("constantMovement")
onready var restartPointsNode = constMoveNode.get_node("restartPoints")
onready var obstaclesNode = constMoveNode.get_node("obstacles")
onready var wolkenNode = spritesNode.get_node("wolken")
onready var groundSprites = constMoveNode.get_node("ground")
onready var groundSprite1 = groundSprites.get_node("Sprite1")
onready var groundSprite2 = groundSprites.get_node("Sprite2")
onready var actionPopup = get_node("hud/actionPopup")
onready var pointsLabel = get_node("hud/points")
onready var playersLabel = get_node("hud/players")

func everyPlayerReady():
	for player in playersNode.get_children():
		if not player.readyToPlay: 
			return false
	return true

remote func setReadyToPlay(playerid):
	# mark player ready
	# when every player ready emit "gogo" event.
#	print("playerNodeC", playersNode.get_children())
	playersNode.get_node(playerid).readyToPlay = true	
	if everyPlayerReady():
		mapGen()
		rpc("gogo")
		rpc("rpcShowActionStage",1)

func _player_disconnected(playerid):
	setReadyToPlay(str(playerid)) # test

sync func gogo():
	# server emits this to start the game when everybody 
	# has loaded and is ready.
	get_tree().set_pause(false)
	set_process(true)

sync func rpcShowActionStage(_stage):
	actionPopup.showStage(_stage)
	
func _ready():
	set_process_input(true)
	spriteWidth = groundSprite1.get_texture().get_size().x
	placeholderScore = pointsLabel.text
	placeholderScoreSize = placeholderScore.length()
	seed(0)
	if get_tree().is_network_server():
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		pass
		get_tree().set_pause(true)
		setReadyToPlay("1")
	else:
		rpc_id(1, "setReadyToPlay", str(get_tree().get_network_unique_id()))
		get_tree().set_pause(true) # server unpauses us when every player is ready
	
func mapGen():
	if get_tree().is_network_server():
		obstaclesGen()
		respawnpointGen()
		enemysGen()
		wolkenGen()
		collectablesGen()

sync func rpcRespawnpoint(pos):
#	print("created RESPAWN ")
	var restartPoint = Restartpoint.instance()
	restartPointsNode.position.x=0
	restartPointsNode.add_child(restartPoint)
	restartPoint.global_position = pos

func respawnpointGen():
	var distance = 1500
	var restartPoint = Restartpoint.instance()
	var pos = Vector2(distance , get_node("groundCollision/CollisionShape2D").position.y)
	rpc("rpcRespawnpoint", pos)
	
sync func rpcCollectable(pos):
	var collectable = Collectables.instance()
	collectable.position = pos
#	collectable.scale = scale
	collectablesNode.add_child(collectable)

func collectablesGen():
	var i = 0
	while i < collectablesCount:
#		var enemy = Enemys.instance()
		var pos = Vector2(i*400+rand_range(1024,2000)-collectablesNode.position.x,rand_range(10,330))
		rpc("rpcCollectable", pos)
		i += 1
	i = 0

	
sync func rpcEnemy(pos, scale, choice):#	
	var enemy = Enemys.instance()
	enemy.choice("enemy",choice) ##only one available
	enemy.position = pos
	enemy.scale = scale
	enemysNode.add_child(enemy)

func enemysGen():
	var i = 0
	while i < enemysCount:
#		var enemy = Enemys.instance()
		var choice = round(rand_range(1,1)) ##only one available
		var pos = Vector2(i*800+rand_range(1024,2000)-enemysNode.position.x,rand_range(10,250))
		var scaleDice = rand_range(0.3,1)
		var scale = Vector2(scaleDice,scaleDice)
		rpc("rpcEnemy", pos, scale, choice)
		i += 1
	i = 0

sync func rpcObstacles(pos, flipped, scale ,choice):
	var obstacle = Obstacles.instance()
	obstacle.choice("kaktuss",choice)
	obstacle.global_position= pos
	obstacle.scale = Vector2(scale,scale)
	if flipped:
		obstacle.get_node("kaktuss"+str(choice)).get_node("Sprite").flip_h = true
	else:
#		print("normal")
		pass
	obstaclesNode.add_child(obstacle)

func obstaclesGen():
	var i = 0
	while i < obstaclesCount:
		var pos = Vector2(i*1000+rand_range(1024,2000)-obstaclesNode.global_position.x,rand_range(350,390))
		var flipped
		var choice = round(rand_range(1,8))
		var scale = rand_range(0.8,1.2)
		if rand_range(0,2) > 1:
			flipped = true
		else:
			flipped = false
		rpc("rpcObstacles", pos, flipped, scale, choice)
		i += 1
	i = 0

sync func rpcWolken(pos, wideness):
	var wolke = Wolke.instance()
	wolke.wideness = wideness
	wolke.position=pos
	wolkenNode.add_child(wolke)
	
func wolkenGen():
	var currentCount = get_tree().get_nodes_in_group("wolken").size()
	if currentCount < wolkenMaxCount:
		var pos = Vector2(rand_range(1024,1400)-wolkenNode.position.x,rand_range(0,250))
		var wideness = rand_range(1, 4)
		rpc("rpcWolken", pos, wideness)

sync func setNewSpeed(_speed):
	fakeSpeed +=_speed
	
func _process(delta):
	constMoveNode.position.x-=fakeSpeed*delta
	enemysNode.position.x-=fakeSpeed*delta*1.5
#	collectablesNode.position.x-=fakeSpeed*delta*1.5
	if !allDead:
		distanceWalked = round(abs(constMoveNode.position.x)/10) # scoring from walked distance
		finalScore = distanceWalked + score
		if finalScore > nextLevel: # staging here
			nextLevel+= nextLevel*0.75
			stage+=1
			if get_tree().is_network_server():
				rpc("rpcShowActionStage",stage)
				rpc("setNewSpeed",10)
	pointsLabel.text=str(finalScore)
	var playersText = "" 
	playersLabel.bbcode_text = "Stage: "+str(stage)+"\n"
	for player in get_tree().get_nodes_in_group("players"):
		var playerName = get_parent().players[int(player.get_name())].name
		var line = str(int(player.alive))+ " " + playerName
		playersLabel.bbcode_text += "[color=#" + utils.computeColor(playerName).to_html() + "]"+line+"[/color]\n"
		

# two ground-tiles for seamless infinite maps
# everytime a tile hast left the screen, position.x is updating and new obstacles are generating
func _on_VisibilityNotifier2D_screen_exited():
	
	if groundSprite1.position.x<groundSprite2.position.x:
		groundSprite1.position.x = groundSprite2.position.x + spriteWidth*groundSprite1.scale.x
	else:
		groundSprites.position.x=0
		groundSprite2.position.x = groundSprite1.position.x + spriteWidth*groundSprite1.scale.x
		mapGen()
	
func endGame():
	get_parent().remove_child(self)
	queue_free()

func _on_menu_pressed():
#	pass # replace with function body
#	var controlNode = get_tree().get_root().get_node("Control")
#	get_tree().set_network_peer(null)
#	controlNode.eNet.close_connection()
#	controlNode.eNet = NetworkedMultiplayerENet.new()
#	controlNode.get_node("menu").set_visible(true)
#	endGame()
	get_node("hud/PopupMenu").showMenu()
	
func _on_GameOverScreen_restartGame():
	get_tree().get_root().get_node("Control").askForRestartGame()


func _on_PopupMenu_restartGame():
	get_tree().get_root().get_node("Control").askForRestartGame()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var popup = self.get_node("hud/PopupMenu")
		if popup.visible:
			popup.hideMenu()
		else:
			popup.showMenu()

