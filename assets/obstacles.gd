extends Node2D

#var FlashMessage = preload("res://assets/flashMessage.tscn")

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
#	print("obstacle deleted")
#	get_parent().remove_child(self)
#	get_parent().call_deferred("remove_child",self)
#	call_deferred("queue_free")
	queue_free()
	pass # replace with function body
