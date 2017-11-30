extends RigidBody2D

var addFakeSpeed = false

sync var rock_slave_pos = Transform2D()
onready var shadowSprite = get_node("CollisionShape2D/shadow")

func _ready():
	if get_tree().is_network_server():
		set_physics_process(true)
	pass

func _on_body_entered( body ):
	if get_tree().is_network_server():
		if not body.is_in_group("players"):
			addFakeSpeed = true

func _physics_process(delta):
	if is_inside_tree() and get_tree().is_network_server():
		if addFakeSpeed:
			global_position.x-=get_parent().game.fakeSpeed*delta
			
		rset("rock_slave_pos",get_transform())
	elif !get_tree().is_network_server():
		set_transform(rock_slave_pos)
		
	elif !is_inside_tree():
		set_physics_process(false)
	if is_inside_tree():
		shadowSprite.global_position.y = 372
		shadowSprite.global_position.x = position.x
		shadowSprite.scale=Vector2(global_position.y+1000,global_position.y+2000)/5000
		
func _on_VisibilityNotifier2D_screen_exited():
	if get_tree().is_network_server(): 
		rpc("rpcRemoveRock")
	
sync func rpcRemoveRock():
	if get_tree().get_nodes_in_group("rocks").size()<=1:
		get_parent().removeRockShowerNode()
	if is_inside_tree():
		queue_free()
	
