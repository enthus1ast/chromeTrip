extends RigidBody2D

# Default Character Properties (Should be overwritten)
var acceleration = 10000
var top_move_speed_org = 200
var top_move_speed = top_move_speed_org
var top_jump_speed = 800

# Grounded?
var grounded = false 
# Movement Vars
var directional_force = Vector2()
const DIRECTION = {
    ZERO = Vector2(0, 0),
    LEFT = Vector2(-1, 0),
    RIGHT = Vector2(1, 0),
    UP = Vector2(0, -1),
    DOWN = Vector2(0, 1)
}

#var FOWARD_MOTION = Vector2(0, 0)

#define the slave vars. slave var did not worked for me
sync var slave_pos = Vector2()
sync var slave_motion = Vector2()
sync var slave_can_jump = true
sync var alive = true

onready var animPlayer = get_node("Sprite/AnimationPlayer")
 
# Jumping
var can_jump = true
var jump_time = 0
const TOP_JUMP_TIME = 0.1 # in seconds

var keys = [false,false,false,false] # right, left, up, down 

func _ready():
	var root = get_tree().get_root().get_node("Control")
	print(root.players)
	set_process_input(true)
	rpc("playAnimation","trexAnimRun")

func _integrate_forces(state):
	var final_force = Vector2()
	if is_network_master():

		directional_force = DIRECTION.ZERO  # +FOWARD_MOTION
		apply_force(state)
		final_force = state.get_linear_velocity() + (directional_force * acceleration)
	 
		if(final_force.x > top_move_speed):
			final_force.x = top_move_speed
		elif(final_force.x < -top_move_speed):
			final_force.x = -top_move_speed
	
		if(final_force.y > top_jump_speed):
			final_force.y = top_jump_speed
		elif(final_force.y < -top_jump_speed):
			final_force.y = -top_jump_speed
		
		# set the slave motion values
		rset("slave_motion",final_force)
		rset("slave_pos",position)
	else:
		position = slave_pos
		final_force = slave_motion
		slave_can_jump = can_jump
		
	state.set_linear_velocity(final_force)
	
# Apply force
func apply_force(state):

    # Move Right
	if keys[0]:
		directional_force += DIRECTION.RIGHT

		
	# Move Left
	if keys[1]:
		directional_force += DIRECTION.LEFT
     
    # Jump
	if keys[2]:
		if jump_time < TOP_JUMP_TIME and can_jump:
			directional_force += DIRECTION.UP
			jump_time += state.get_step()
			rset("slave_can_jump",can_jump)
		
		
    # While on the ground
	if(grounded):
		can_jump = true
		rset("slave_can_jump",can_jump)
		jump_time = 0
 
func _on_groundcollision_body_entered( body ):
	if body.get_name()=="groundCollision":
		grounded = true

func _on_groundcollision_body_exited( body ):
#	if body.get_name()!="ground":
	grounded = false

sync func playAnimation(_string):
	get_node("Sprite/AnimationPlayer").play(_string)
	
sync func animSpeed(_speed):
	get_node("Sprite/AnimationPlayer").set_speed_scale(_speed)

func _input(event):
	if is_network_master() and alive:
		#if keyboard input
		if event.get_class()=="InputEventKey":
			
			# left or right keypressevent
			if event.is_action_pressed("ui_right"):
				keys[0]=true
				rpc("animSpeed",1.5)
#				rpc("playAnimation","trexAnimRun")
			elif event.is_action_pressed("ui_left"):
				rpc("animSpeed",0.5)
				keys[1]=true
#				rpc("playAnimation","trexAnimRun")
			
			# left or right keyreleaseevent
			if event.is_action_released("ui_right"):
				rpc("animSpeed",1)
				keys[0]=false
#				rpc("playAnimation","trexAnim")
			elif event.is_action_released("ui_left"):
				rpc("animSpeed",1)
				keys[1]=false
#				rpc("playAnimation","trexAnim")
			
			#jumping keyevents
			if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_select"):
				keys[2]=true
			if event.is_action_released("ui_up") or event.is_action_released("ui_select"):
				keys[2]=false
				can_jump = false # Prevents the player from jumping more than once while in air
#				rset("slave_can_jump",can_jump)
	elif is_network_master() and !alive: # not alive
		keys[2] = false # reset jumping
		can_jump = false

remote func killed(_node,_id):
	print(_node,_id, " hasbeen killed")
#	_node.alive = false
	get_parent().get_node(str(_id)).alive = false
	get_parent().get_node(str(_id)).can_jump = false
	get_parent().get_node(str(_id)).get_node("Sprite/AnimationPlayer").play("trexAnimKilled")

remote func reanimate(_node,_id):
	print(_node,_id, " hasbeen reanimated")
#	_node.alive = false
	get_parent().get_node(str(_id)).alive = true
	get_parent().get_node(str(_id)).can_jump = true
	get_parent().get_node(str(_id)).get_node("Sprite/AnimationPlayer").play("trexAnim")
	
	
func _on_player_body_shape_entered( body_id, body, body_shape, local_shape ):
	if(body.has_node("obstacleShape")):
#		alive = false
		if get_tree().is_network_server():
			# server noticed collision 
			# kills playerFoo
			# tell all that playerFoo is killed 
			killed(self,get_name())
			rpc("killed",self, get_name())
		else:
			# client noticed collision
			# and kills itself
			rpc_id(1,"killed",self,get_name())
	pass # replace with function body
