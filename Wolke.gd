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
	if rand_range(0,2) > 1:
		get_node("Sprite").flip_h = true


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass
	position = position - (Vector2( speed * delta, 0 ) )


func _on_VisibilityNotifier2D_screen_exited():
	pass # replace with function body
	get_parent().remove_child(self)
	queue_free()
