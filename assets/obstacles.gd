extends Node2D

func choice(_class,_id):
	get_node(_class+str(_id)).pause_mode=0
	get_node(_class+str(_id)).set_visible(true)
	get_node(_class+str(_id)).get_node("obstacleShape").disabled=false
	
	
func _ready():
	for child in get_children():
		if typeof(child)==typeof(KinematicBody2D):
			child.pause_mode=1
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_ObstacleScreenExitNotifier_screen_exited():
	print("obstacle deleted")
	get_parent().remove_child(self)
	queue_free()
#	get_parent().call_deferred("remove_child",self)
	pass # replace with function body
