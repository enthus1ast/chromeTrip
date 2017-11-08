extends Control
var offsetX
var offsetY = -50

onready var Restartpoint = preload("res://restartPoint.tscn")
onready var Obstacles = preload("res://assets/obstacles.tscn")
onready var Enemys = preload("res://assets/enemys.tscn")
onready var Wolke = preload("res://Wolke.tscn")
onready var viewportSize = get_viewport().size

var fakeSpeed=300
var players
var score = 0
var placeholderScore
var placeholderScoreSize
var spriteWidth
var obstaclesCount = 8
var enemysCount = 8
var wolkenMaxCount = 10
var allDead = false

onready var playersNode = get_node("players")
onready var spritesNode = get_node("sprites")
onready var enemysNode = spritesNode.get_node("enemys")
onready var constMoveNode = spritesNode.get_node("constantMovement")
onready var restartPointsNode = constMoveNode.get_node("restartPoints")
onready var obstaclesNode = constMoveNode.get_node("obstacles")
onready var wolkenNode = spritesNode.get_node("wolken")
onready var groundSprites = constMoveNode.get_node("ground")
onready var groundSprite1 = groundSprites.get_node("Sprite1")
onready var groundSprite2 = groundSprites.get_node("Sprite2")
onready var pointsLabel = get_node("hud/points")

func everyPlayerReady():
	for player in playersNode.get_children():
		if not player.readyToPlay: 
			return false
	return true

remote func setReadyToPlay(playerid):
	# mark player ready
	# when every player ready emit "gogo" event.
	print("playerNodeC", playersNode.get_children())
	playersNode.get_node(playerid).readyToPlay = true
	if everyPlayerReady():
		mapGen()
		rpc("gogo")

sync func gogo():
	# server emits this to start the game when everybody 
	# has loaded and is ready.
	get_tree().set_pause(false)
	set_process(true)
	
func _ready():
	spriteWidth = groundSprite1.get_texture().get_size().x
	placeholderScore = pointsLabel.text
	placeholderScoreSize = placeholderScore.length()
	seed(0)
	if get_tree().is_network_server():
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

sync func rpcRespawnpoint(pos):
	print("created RESPAWN ")
	var restartPoint = Restartpoint.instance()
	restartPointsNode.position.x=0
	restartPointsNode.add_child(restartPoint)
	restartPoint.global_position = pos

func respawnpointGen():
	var distance = 1500
	var restartPoint = Restartpoint.instance()
	var pos = Vector2(distance , get_node("groundCollision/CollisionShape2D").position.y)
	rpc("rpcRespawnpoint", pos)
	
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
		print("flipped")
		obstacle.get_node("kaktuss"+str(choice)).get_node("Sprite").flip_h = true
	else:
		print("normal")
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

func _process(delta):
	constMoveNode.position.x-=fakeSpeed*delta
	enemysNode.position.x-=fakeSpeed*delta*1.5
	if !allDead:
		score = round(abs(constMoveNode.position.x)/10) # scoring from walked distance
	pointsLabel.text=str(score)
	var playersText = "" 
	for player in get_tree().get_nodes_in_group("players"):
		playersText += player.get_name() + " " + str(player.alive) + "\n"
	get_node("hud/players").text = playersText
	
#func _physics_process(delta):
#	groundSprite.position.x-=fakeSpeed*delta
#	# camera do follow the midpoint between players
#	players = playersNode.get_children()
#	if players.size()>0:
#		var midpoint
#		if players.size()==1:
#			midpoint = players[0].position
#		elif players.size()==2:
#			midpoint = (players[0].position +players[1].position)/2
#
#		elif players.size()>2:
#			midpoint = players[0].position
#			for p in range(players):
#				if p!=players.size():
#					midpoint = (midpoint + players[p+1].position)/2
#
#		camera.position.x = midpoint.x + offsetX

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
	pass # replace with function body
	var controlNode = get_tree().get_root().get_node("Control")
	get_tree().set_network_peer(null)
	controlNode.eNet.close_connection()
	controlNode.eNet = NetworkedMultiplayerENet.new()
	controlNode.get_node("menu").set_visible(true)
	endGame()
	
func _on_GameOverScreen_restartGame():
	get_tree().get_root().get_node("Control").askForRestartGame()
