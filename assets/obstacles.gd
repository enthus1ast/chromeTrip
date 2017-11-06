extends Node2D

func choice(_class,_id):
	get_node(_class+str(_id)).set_visible(true)
	get_node(_class+str(_id)).get_node("obstacleShape").disabled=false
	
	
func _ready():
	
	# Called every time the node is added to the scene.
	# Initialization here
	pass



#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
