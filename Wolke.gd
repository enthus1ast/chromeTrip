extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var wideness = 1
var speed = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	speed = wideness * 10
	scale = Vector2(wideness, wideness)
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass
	position = position - (Vector2( speed * delta, 0 ) )
