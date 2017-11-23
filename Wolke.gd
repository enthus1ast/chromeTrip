extends Node2D

export var wideness = 1
var speed = 0

func _ready():
	speed = wideness * 10
	scale = Vector2(wideness, wideness)
	if rand_range(0,2) > 1:
		get_node("Sprite").flip_h = true

func _process(delta):
	position = position - (Vector2( speed * delta, 0 ) )

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	queue_free()
#	print("cloud deleted")