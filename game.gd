extends Control
var offsetX
var offsetY = -50



var players
var score = 0
var placeholderScore
var placeholderScoreSize
onready var playersNode = get_node("players")
#onready var camera = get_node("Camera2D")
onready var pointsLabel = get_node("CanvasLayer/points")
#
func _ready():
	placeholderScore = pointsLabel.text
	placeholderScoreSize = placeholderScore.length()
	print(placeholderScore,placeholderScoreSize)
#	offsetX = get_viewport_rect().size.x/2
#	print(get_viewport_rect().size.x)
#	camera.position.y = camera.position.y + offsetY
#	set_physics_process(true)
	set_process(true)
	pass
	
func _process(delta):
	score+=delta+0.2
	pointsLabel.text=str(round(score))
	
	
	
	
#func _physics_process(delta):
#
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