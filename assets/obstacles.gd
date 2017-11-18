extends Node2D

func choice(_class,_id):
	get_node(_class+str(_id)).pause_mode=0
	get_node(_class+str(_id)).set_visible(true)
	get_node(_class+str(_id)).get_node("obstacleShape").disabled=false
func _ready():
	for child in get_children():
		if typeof(child)==typeof(KinematicBody2D):
			child.pause_mode=1
	pass

func _on_ObstacleScreenExitNotifier_screen_exited():
	queue_free()
	pass
