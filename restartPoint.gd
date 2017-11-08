extends Node2D


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func doRespawn(collider):
	## - informs everybody that the restart
	##   point was reached.
	## - safes the random seed
	## - position all killed bodies nearby
	##   the respawn point
	print("respawn point reached")
#	if collider
	if not collider.alive: return true
	# get all killed players.
	for player in get_tree().get_nodes_in_group("players"):
		print(player)
		if ! player.alive:
			print("reanimating player:", position + Vector2(0, -400))
			player.reanimate(position + Vector2(0, -400))
	
	# get position of respawn point
	# places all killed players to resp point 
	# unkill them

func _on_Area2D_body_entered( body ):
	pass # replace with function body


func _on_Area2D_body_shape_entered( body_id, body, body_shape, area_shape ):
	if get_tree().is_network_server() and body.get_parent().get_name()=="players":
		print( body_id, body.get_name(), body_shape, area_shape, "body_shape entered respawn point")
		doRespawn(body)
	


func _on_VisibilityNotifier2D_screen_exited():
	get_parent().call_deferred("remove_child",self)
	queue_free()
	pass # replace with function body
