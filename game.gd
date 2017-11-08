extends Control
var offsetX
var offsetY = -50

onready var Obstacles = preload("res://assets/obstacles.tscn")
onready var Enemys = preload("res://assets/enemys.tscn")
onready var viewportSize = get_viewport().size

var fakeSpeed=300

var players
var score = 0
var placeholderScore
var placeholderScoreSize
var spriteWidth


var obstaclesCount = 4
var enemysCount = 4

onready var playersNode = get_node("players")
onready var spritesNode = get_node("sprites")
onready var enemysNode = spritesNode.get_node("enemys")
onready var constMoveNode = spritesNode.get_node("constantMovement")
onready var obstaclesNode = constMoveNode.get_node("obstacles")
onready var groundSprites = constMoveNode.get_node("ground")
onready var groundSprite1 = groundSprites.get_node("Sprite1")
onready var groundSprite2 = groundSprites.get_node("Sprite2")
#onready var camera = get_node("Camera2D")
onready var pointsLabel = get_node("hud/points")
#
func _ready():
	spriteWidth = groundSprite1.get_texture().get_size().x
	placeholderScore = pointsLabel.text
	placeholderScoreSize = placeholderScore.length()
#	print(placeholderScore,placeholderScoreSize)
#	offsetX = get_viewport_rect().size.x/2
#	print(get_viewport_rect().size.x)
#	camera.position.y = camera.position.y + offsetY
#	print("Viewportsize: ",viewportSize)
#	ground.constant_linear_velocity(-1,0)
#	set_process(true)
	seed(0)
	mapGen()
	set_process(true)
#	 "restartGame"
	pass
	
func mapGen():
	obstaclesGen()
	enemysGen()
	pass
	
func enemysGen():
	var i = 0
	while i < enemysCount:
		var enemy = Enemys.instance()
		enemy.choice("enemy",round(rand_range(1,1))) ##only one available
		enemy.position=Vector2(i*800+rand_range(1024,2000)-enemysNode.position.x,rand_range(10,250))
		var scale = rand_range(0.3,1)
		enemy.scale = Vector2(scale,scale)
		enemysNode.add_child(enemy)
#		print(obstacle.global_position.x)
		i += 1
	i = 0
func obstaclesGen():
	var i = 0
	while i < obstaclesCount:
		var obstacle = Obstacles.instance()
		obstacle.choice("kaktuss",round(rand_range(1,7)))
		obstacle.global_position=Vector2(i*1000+rand_range(1024,2000)-obstaclesNode.global_position.x,rand_range(350,390))
		var scale = rand_range(0.8,1.2)
		obstacle.scale = Vector2(scale,scale)
		obstaclesNode.add_child(obstacle)
#		print(obstacle.global_position.x)
		i += 1
	i = 0
	
	
func _process(delta):
	constMoveNode.position.x-=fakeSpeed*delta
	enemysNode.position.x-=fakeSpeed*delta*1.5
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
	pass # replace with function body
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
#	pass # replace with function body
#	var myroot = get_tree().get_root()
#	print(get_tree())
#	print(get_tree().get_root())
#	print(get_tree().get_root().get_node("Control"))
#	print(get_tree().get_root().get_node("Control"))
	

	get_tree().get_root().get_node("Control").askForRestartGame()

	
	
#	start_game
