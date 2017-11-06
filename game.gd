extends Control
var offsetX
var offsetY = -50


onready var Obstacles = preload("res://assets/obstacles.tscn")
onready var viewportSize = get_viewport().size

var fakeSpeed=300

var players
var score = 0
var placeholderScore
var placeholderScoreSize
var spriteWidth


var obstaclesCount = 30


onready var playersNode = get_node("players")
onready var ground = get_node("ground")
onready var groundSprites = ground.get_node("Node2D")
onready var groundSprite1 = groundSprites.get_node("Sprite1")
onready var groundSprite2 = groundSprites.get_node("Sprite2")
#onready var camera = get_node("Camera2D")
onready var pointsLabel = get_node("CanvasLayer/points")
#
func _ready():
	
	
	
	spriteWidth = groundSprite1.get_texture().get_size().x
	placeholderScore = pointsLabel.text
	placeholderScoreSize = placeholderScore.length()
#	print(placeholderScore,placeholderScoreSize)
#	offsetX = get_viewport_rect().size.x/2
#	print(get_viewport_rect().size.x)
#	camera.position.y = camera.position.y + offsetY
	set_physics_process(true)
#	print("Viewportsize: ",viewportSize)
#	ground.constant_linear_velocity(-1,0)
#	set_process(true)
	mapGen()
	pass
	
	
func mapGen():
	var i = 0
	while i < obstaclesCount:
		var obstacle = Obstacles.instance()
		obstacle.choice("kaktuss",round(rand_range(1,7)))
		obstacle.position=Vector2(rand_range(400,10000),rand_range(340,400))
		var scale = rand_range(0.8,1.2)
		obstacle.scale = Vector2(scale,scale)
		groundSprites.add_child(obstacle)
		i += 1
	i = 0
	
	
	
	
func _process(delta):
	groundSprites.position.x-=fakeSpeed*delta
	
	score+=delta+0.4
	pointsLabel.text=str(round(score))
	
	
	
	
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

func _on_VisibilityNotifier2D_screen_exited():
	if groundSprite1.position.x<groundSprite2.position.x:
		groundSprite1.position.x = groundSprite2.position.x + spriteWidth*groundSprite1.scale.x
	else:
		groundSprite2.position.x = groundSprite1.position.x + spriteWidth*groundSprite1.scale.x
	mapGen()
	pass # replace with function body
