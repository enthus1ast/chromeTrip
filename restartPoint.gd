extends Node2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func doRespawn(collider):
	if not collider.alive: return true
	for player in get_tree().get_nodes_in_group("players"):
		print(player)
		if !player.alive:
			var newPos
			if player.type == "dino":
				newPos = Vector2(100, -400)
			elif player.type == "bird":
				newPos = Vector2(100, -300)
			print("reanimating player:", player.playerName, " ", newPos )
			player.reanimate( Vector2(100,150))

func _on_Area2D_body_shape_entered( body_id, body, body_shape, area_shape ):
	if get_tree().is_network_server() and body.get_parent().get_name()=="players":
		doRespawn(body)
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
