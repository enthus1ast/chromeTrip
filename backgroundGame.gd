extends Control
var offsetX
var offsetY = -50

onready var Obstacles = preload("res://assets/obstacles.tscn")
onready var Enemys = preload("res://assets/enemys.tscn")
onready var Restartpoint = preload("res://restartPoint.tscn")
onready var Collectables = preload("res://assets/collectables.tscn")
onready var Wolke = preload("res://Wolke.tscn")
onready var viewportSize = get_viewport().size

var fakeSpeed=1000
var score = 0
var finalScore = 0
var distanceWalked = 0
var ground

var placeholderScore
var placeholderScoreSize
var spriteWidth
var obstaclesCount = 8
var enemysCount = 8
var wolkenMaxCount = 20

onready var cameraNode = get_node("cameraNode")
onready var spritesNode = get_node("sprites")
onready var enemysNode = spritesNode.get_node("enemys")
onready var constMoveNode = spritesNode.get_node("constantMovement")
onready var restartPointsNode = constMoveNode.get_node("restartPoints")
onready var obstaclesNode = constMoveNode.get_node("obstacles")
onready var wolkenNode = spritesNode.get_node("wolken")
onready var groundSprites = constMoveNode.get_node("ground")
onready var groundSprite1 = groundSprites.get_node("Sprite1")
onready var groundSprite2 = groundSprites.get_node("Sprite2")

func _ready():
	spriteWidth = groundSprite1.get_texture().get_size().x
	seed(0)
	
func mapGen():
	obstaclesGen()
	respawnpointGen()
	enemysGen()
	wolkenGen()

sync func rpcRespawnpoint(pos):
	var restartPoint = Restartpoint.instance()
	restartPointsNode.position.x=0
	restartPointsNode.add_child(restartPoint)
	restartPoint.global_position = pos

func respawnpointGen():
	var distance = 1500
	var restartPoint = Restartpoint.instance()
	var pos = Vector2(distance ,400)
	rpcRespawnpoint( pos)
	
sync func rpcEnemy(pos, scale, choice):#	
	var enemy = Enemys.instance()
	enemy.choice("enemy",choice) ##only one available
	enemy.position = pos
	enemy.scale = scale
	enemysNode.add_child(enemy)

func enemysGen():
	var i = 0
	while i < enemysCount:
		var choice = round(rand_range(1,1)) ##only one available
		var pos = Vector2(i*800+rand_range(1024,2000)-enemysNode.position.x,rand_range(10,325))
		var scaleDice = rand_range(0.3,1)
		var scale = Vector2(scaleDice,scaleDice)
		rpcEnemy( pos, scale, choice)
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
		pass
	obstaclesNode.add_child(obstacle)

func obstaclesGen():
	var i = 0
	while i < obstaclesCount and obstaclesNode.is_inside_tree():
		var pos = Vector2(i*1000+rand_range(1024,2000)-obstaclesNode.global_position.x,rand_range(350,390))
		var flipped
		var choice = round(rand_range(1,8))
		var scale = rand_range(0.8,1.2)
		if rand_range(0,2) > 1:
			flipped = true
		else:
			flipped = false
		rpcObstacles( pos, flipped, scale, choice)
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
		var pos = Vector2(rand_range(1200,1600)-wolkenNode.position.x,rand_range(0,250))
		var wideness = rand_range(1, 4)
		rpcWolken( pos, wideness)

sync func setNewSpeed(_speed):
	fakeSpeed +=_speed
	
func _process(delta):
	constMoveNode.position.x-=fakeSpeed*delta
	enemysNode.position.x-=fakeSpeed*delta*1.5

func _on_VisibilityNotifier2D_screen_exited():
	# two ground-tiles for seamless infinite maps
	# everytime a tile hast left the screen, position.x is updating and new obstacles are generating
	if groundSprite1.position.x<groundSprite2.position.x:
		groundSprite1.position.x = groundSprite2.position.x + spriteWidth*groundSprite1.scale.x
	else:
		groundSprites.position.x=0
		groundSprite2.position.x = groundSprite1.position.x + spriteWidth*groundSprite1.scale.x
		if is_inside_tree():
			mapGen()
	
func endGame():
	get_parent().remove_child(self)
	queue_free()

