extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

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
	if not collider.alive: true
	# get all killed players.
	for player in get_tree().get_nodes_in_group("players"):
		print(player)
		if ! player.alive:
			print("reanimating player:", position + Vector2(0, -400))
			player.reanimate(position + Vector2(0, -400))
#			player.position = position + Vector2(0, -250)
#			emit_signal("player_reanimate", player, player.get_name(), position + Vector2(0, -250))
		
#			player.slave_pos = position + Vector2(0, -250)
#			player.alive = true
#			player.can_jump = true
#			player.get_node("Sprite/AnimationPlayer").play("trexAnimRun")
			
			#
			#rset("slave_motion",final_force)
			#rset("slave_pos",position)			
			
	
	# get position of respawn point
	# places all killed players to resp point 
	# unkill them

func _on_Area2D_body_entered( body ):
	pass # replace with function body
	if get_tree().is_network_server():
		print(body, " body entered respawn point")
		doRespawn(body)


func _on_Area2D_body_shape_entered( body_id, body, body_shape, area_shape ):
	pass # replace with function body
	print(body, "body_shape entered respawn point")
