extends RigidBody2D
# Default Character Properties (Should be overwritten)
var acceleration = 10000
var top_move_speed = 200
var top_jump_speed = 400
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
slave var slave_pos = Vector2()
slave var slave_motion = Vector2()
slave var slave_is_jumping = false

var name
var savedState
 
# Jumping
var can_jump = true
var jump_time = 0
const TOP_JUMP_TIME = 0.1 # in seconds
func _integrate_forces(state):
#	print(self.get_name())
	var final_force = Vector2()
	var pos
#	if str(get_tree().get_network_unique_id())==get_name():
	
	if is_network_master():
#		print(self.get_name())
#		savedState = state
		
		directional_force = DIRECTION.ZERO
		apply_force(state)
#		rpc("apply_force",state)
		final_force = state.get_linear_velocity() + (directional_force * acceleration)
	 
		if(final_force.x > top_move_speed):
			final_force.x = top_move_speed
		elif(final_force.x < -top_move_speed):
			final_force.x = -top_move_speed
	
		if(final_force.y > top_jump_speed):
			final_force.y = top_jump_speed
		elif(final_force.y < -top_jump_speed):
			final_force.y = -top_jump_speed
		pos = position
		rset("slave_motion",final_force)
		rset("slave_pos",pos)
		print(slave_pos)
	else:
		position = slave_pos
		print(slave_pos)
		final_force = slave_motion
	state.set_linear_velocity(final_force)
	
# Apply force
func apply_force(state):
    # Move Left
	if(Input.is_action_pressed("ui_left")):
		directional_force += DIRECTION.LEFT
		pass
     
    # Move Right
	if(Input.is_action_pressed("ui_right")):
		directional_force += DIRECTION.RIGHT
		pass
     
    # Jump
	if Input.is_action_pressed("ui_select"):
		if jump_time < TOP_JUMP_TIME and can_jump:
			directional_force += DIRECTION.UP
			jump_time += state.get_step()
	elif(Input.is_action_just_released("ui_select")):
		can_jump = false # Prevents the player from jumping more than once while in air
     
    # While on the ground
	if(grounded):
		can_jump = true
		jump_time = 0
 
func _on_groundcollision_body_entered( body ):
	if body.get_name()=="ground":
		grounded = true

func _on_groundcollision_body_exited( body ):
#	if body.get_name()!="ground":
	grounded = false

 

 