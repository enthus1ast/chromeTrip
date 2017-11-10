extends RigidBody2D
# Default Character Properties (Should be overwritten)
var acceleration = 10000
var top_move_speed_org = 200
var top_move_speed = top_move_speed_org
var top_jump_speed = 800
var jumpSound = load("res://sounds/jump.ogg")
var killedSound = load("res://sounds/killed.ogg")
var soundPlayer = AudioStreamPlayer.new()
var readyToPlay = false # this gets set to true when the player has loaded the playscene
var killprotectTimer = Timer.new()
var isKillProtected = false

onready var playerColShape = get_node("playerShape")
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

sync var slave_pos = Transform2D()
sync var slave_motion = Vector2()
#sync var slave_can_jump = true
sync var alive = true
var reviving = false

var cameraNode
onready var game = get_tree().get_root().get_node("Control/game")
onready var animPlayer = get_node("Sprite/AnimationPlayer")
onready var powerUpPlayer = get_node("Sprite/AnimationPlayerPowerUps")
onready var particleAnimPlayer = get_node("particleSystems/particleAnimPlayer")
 
# Jumping
var can_jump = true
var jump_time = 0
const TOP_JUMP_TIME = 0.1 # in seconds

var keys = [false,false,false,false] # right, left, up, down 

func _ready():
	cameraNode = game.get_node("cameraNode")
	add_child ( killprotectTimer )
	killprotectTimer.wait_time = 3
	killprotectTimer.connect("timeout",self,"_killprotectTimeout")
	soundPlayer.connect("finished",self,"_sound_finished")
	var root = get_tree().get_root().get_node("Control")
	set_process_input(true)
	add_child(soundPlayer)
	rpc("playAnimation","trexAnimRun")

func rpcPowerUps(_id,_string):
	get_parent().get_node(str(_id)).powerUpPlayer.play(_string)
	
sync func rpcKillProtectRequest(_id):
	get_parent().get_node(str(_id)).isKillProtected = false
	get_parent().get_node(str(_id)).powerUpPlayer.stop()
#	get_parent().get_node(str(_id)).powerUpPlayer.wait_time = 3
	get_parent().get_node(str(_id)).rpcPowerUps(_id,"default")
	print(_id,"is no longer protected!")

func _killprotectTimeout():
	rpc("rpcKillProtectRequest",get_name())
	
func _integrate_forces(state):
	var final_force = Vector2()
	if is_network_master():
		if !alive:
			pass
		if reviving:
			reviving = false
			state.set_transform( slave_pos )
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
		rset("slave_motion",final_force)
		rset("slave_pos",state.get_transform())
	else:
		state.set_transform(slave_pos)
		final_force = slave_motion
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
    # While on the ground
	if(grounded):
		can_jump = true
		jump_time = 0
		
func _on_groundSensor_body_entered( body ):
	if body.has_node("playerShape"):
		if body.get_name()!=get_name():
			grounded = true
	elif body.get_name()=="groundCollision":
		grounded = true
		if alive:
			cameraNode.landRumble(linear_velocity.y)

func _on_groundSensor_body_exited( body ):
	if body.has_node("playerShape"):
		if body.get_name()!=get_name():
			grounded = false
	elif body.get_name()=="groundCollision":
		grounded = false

sync func playAnimation(_string):
	animPlayer.play(_string)
	
sync func animSpeed(_speed):
	get_node("Sprite/AnimationPlayer").set_speed_scale(_speed)
	
sync func rpcJumpParticles(_id):
	get_parent().get_node(_id).particleAnimPlayer.play("particleJump")

func _input(event):
	if is_network_master() and alive:
		#if keyboard input
		if event.get_class()=="InputEventKey":
			# left or right keypressevent
			if event.is_action_pressed("ui_right"):
				keys[0]=true
				rpc("animSpeed",1.5)
			elif event.is_action_pressed("ui_left"):
				rpc("animSpeed",0.5)
				keys[1]=true
			
			# left or right keyreleaseevent
			if event.is_action_released("ui_right"):
				rpc("animSpeed",1)
				keys[0]=false
			elif event.is_action_released("ui_left"):
				rpc("animSpeed",1)
				keys[1] = false

			# Duck and Cover!
			if event.is_action_pressed("ui_down"):
				keys[3] = true
				rpc("playAnimation","trexAnimDuck")
			elif event.is_action_released("ui_down"):
				rpc("playAnimation","trexAnimRun")
				keys[3] = false
			
			#jumping keyevents
			if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_select"):
				keys[2]=true
				if (grounded or can_jump) and alive:
					rpc("rpcJumpParticles",get_name())
					cameraNode.jumpRumble()
					if !soundPlayer.is_playing():
						if soundPlayer.get_stream() != jumpSound:
							soundPlayer.set_stream(jumpSound)
						soundPlayer.play(0.0)
			if event.is_action_released("ui_up") or event.is_action_released("ui_select"):
				keys[2]=false
				can_jump = false # Prevents the player from jumping more than once while in air
#				rset("slave_can_jump",can_jump)
	elif is_network_master() and !alive: # not alive
		keys = [false,false,false,false]
		can_jump = false
		
func _sound_finished():
	soundPlayer.stop()
	
sync func killed(_id):
	if !isKillProtected:
		get_parent().get_node(str(_id)).get_node("playerShape").disabled=true
		get_parent().get_node(str(_id)).alive = false
		get_parent().get_node(str(_id)).can_jump = false
		get_parent().get_node(str(_id)).get_node("Sprite/AnimationPlayer").play("trexAnimKilled")
		print(_id, " hasbeen killed")

sync func RPCreanimate(_id, atPosition):
	get_parent().get_node(str(_id)).powerUpPlayer.play("killProtected")
	get_parent().get_node(str(_id)).isKillProtected = true
	get_parent().get_node(str(_id)).killprotectTimer.start()
	var transMatrix = Transform2D(Vector2(),Vector2(), atPosition)
	print(_id,transMatrix, " hasbeen reanimated")
	get_parent().get_node(str(_id)).get_node("playerShape").disabled=false
	get_parent().get_node(str(_id)).get_node("playerShape").update()
	get_parent().get_node(str(_id)).can_jump = false
	get_parent().get_node(str(_id)).get_node("Sprite/AnimationPlayer").play("trexAnimRun")
	get_parent().get_node(str(_id)).slave_pos = transMatrix
	if is_network_master():
		playerColShape.disabled=false
		isKillProtected = true
		alive = true
		can_jump = false
		grounded = false
		position = atPosition
		slave_pos = transMatrix
		slave_motion = Vector2(0,0)
	get_parent().get_node(str(_id)).alive = true
	get_parent().get_node(str(_id)).reviving = true

func reanimate(atPosition):
	rpc("RPCreanimate", get_name(), atPosition)

func allPlayersKilled():
	for player in get_tree().get_nodes_in_group("players"):
		if player.alive: return false
	return true
	
sync func showGameOverScreen():
	get_parent().get_parent().allDead = true
	utils.putHighscore( utils.getScore(), utils.getTeam() )
	get_tree().get_root().get_node("Control/game/GameOverScreen").set_visible(true)
	
func _on_player_body_shape_entered( body_id, body, body_shape, local_shape ):
	if(body.has_node("obstacleShape") or body.has_node("enemyShape")) and alive and !isKillProtected:
		soundPlayer.stream = killedSound
		soundPlayer.play(0.0)
		if get_tree().is_network_server():
			rpc("killed", get_name())
			cameraNode.killedRumble()
			if allPlayersKilled():
				rpc("showGameOverScreen")

func _on_player_body_shape_exited( body_id, body, body_shape, local_shape ):
	pass # replace with function body