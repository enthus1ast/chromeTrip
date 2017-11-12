extends StaticBody2D

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


func _on_Disabler_body_entered( body ):
	pass # replace with function body
	
	if body.is_in_group("players"):
		print("player fell into loch: ", body.name)
		body.set_collision_mask_bit(0, false) ## ground
		body.set_collision_layer_bit(0, false) ## ground
		body.disableInputs()
	
func _on_Killer_body_entered( body ):
	pass # replace with function body
	if body.is_in_group("players"):
		body.kill()
	
func _on_Disabler_body_exited( body ):
	pass # replace with function body
#	body.set_collision_mask_bit(0, true) ## ground
#	body.set_collision_layer_bit(0, true) ## ground	
