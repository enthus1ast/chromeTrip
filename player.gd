extends RigidBody2D
# Default Character Properties (Should be overwritten)
var acceleration = 10000
var top_move_speed_org = 200
var top_move_speed = top_move_speed_org
var top_jump_speed = 800
var jumpSound = load("res://sounds/jump.ogg")
var killedSound = load("res://sounds/killed.ogg")
#var soundPlayer = AudioStreamPlayer.new(
onready var soundPlayer =  get_node("AudioStreamPlayer") #AudioStreamPlayer.new())
var readyToPlay = false # this gets set to true when the player has loaded the playscene
var killprotectTimer = Timer.new()
var isKillProtected = false
var needForFood = 2# speed of getting hungry
var name = "SET_ME" # the player name
var inputsDisabled = false

onready var playerColShape = get_node("playerShape")
onready var hungerInfo = get_tree().get_root().get_node("Control/game/hud/Fleisch")
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
sync var alive = true
var hunger = 0 # hunger level
sync var slave_hunger = 0 # hunger level

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
	grounded = false
	can_jump = true
	set_process_input(true)
	add_child(soundPlayer)
	rpc("playAnimation","trexAnimRun")

func rpcPowerUps(_id,_string):
	get_parent().get_node(str(_id)).powerUpPlayer.play(_string)
	
sync func rpcKillProtectRequest(_id):
	var player = get_parent().get_node(str(_id))
	player.isKillProtected = false
	player.set_collision_mask_bit(3, true) ## layer for obstacles
	player.set_collision_mask_bit(4, true) ## layer for enemy
	player.powerUpPlayer.stop()
	player.rpcPowerUps(_id,"default")

func _killprotectTimeout():
	rpc("rpcKillProtectRequest",get_name())

#func setNoCollide(val):
#	## sets the player in the no collide mode
#	## every obstacle and enemy will not collide
#	## also the sprite is blinking.	

func _process(delta):
	if is_network_master():
		rset("slave_hunger",hunger)
		hungerInfo.amount = 100-hunger
		if alive and (hunger<100 and hunger>=0):
			hunger += delta*needForFood
		elif alive and hunger>=100:
#			hunger = 0
			#death by starving
			rpc("killed", get_name())
			if allPlayersKilled():
				rpc("showGameOverScreen")
		elif alive:
			hunger = 0
			pass
	else:
		hunger=slave_hunger
		
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
	elif body.is_in_group("ground"):
		grounded = true
		if alive:
			cameraNode.landRumble(linear_velocity.y)

func _on_groundSensor_body_exited( body ):
	if body.has_node("playerShape"):
		if body.get_name()!=get_name():
			grounded = false
	elif body.is_in_group("ground"):
		grounded = false

sync func playAnimation(_string):
	animPlayer.play(_string)
	
sync func animSpeed(_speed):
	get_node("Sprite/AnimationPlayer").set_speed_scale(_speed)
	
sync func rpcJumpParticles(_id):
	get_parent().get_node(_id).particleAnimPlayer.play("particleJump")

func _input(event):
	if is_network_master() and alive and not inputsDisabled:
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
				if (grounded and can_jump and alive):
					rpc("rpcJumpParticles",get_name())
					cameraNode.jumpRumble()
#					if !soundPlayer.is_playing():
					if soundPlayer.get_stream() != jumpSound:
						soundPlayer.set_stream(jumpSound)
					soundPlayer.play(0.0)
			if event.is_action_released("ui_up") or event.is_action_released("ui_select"):
				keys[2]=false
				can_jump = false # Prevents the player from jumping more than once while in air
#				rset("slave_can_jump",can_jump)
	elif is_network_master() and (!alive or inputsDisabled ): # not alive
		keys = [false,false,false,false]
		can_jump = false
		
func _sound_finished():
	soundPlayer.stop()
	
sync func killed(_id):
	if !isKillProtected:
		var player = get_parent().get_node(str(_id))
		player.get_node("playerShape").disabled=true
		player.alive = false
		player.can_jump = false
		player.get_node("Sprite/AnimationPlayer").play("trexAnimKilled")
		soundPlayer.stream = killedSound
		soundPlayer.play(0.0)		

sync func RPCreanimate(_id, atPosition):
	var player = get_parent().get_node(str(_id))
	player.powerUpPlayer.play("killProtected")
	player.isKillProtected = true
	player.set_collision_mask_bit(3, false) ## layer for obstacles
	player.set_collision_mask_bit(4, false) ## layer for enemies
	player.killprotectTimer.start()
	var transMatrix = Transform2D(Vector2(),Vector2(), atPosition)
	player.get_node("playerShape").disabled=false
	player.get_node("playerShape").update()
	player.can_jump = false
	player.get_node("Sprite/AnimationPlayer").play("trexAnimRun")
	player.slave_pos = transMatrix
	player.hunger = 0
	if is_network_master():
		playerColShape.disabled=false
		isKillProtected = true
		alive = true
		can_jump = false
		grounded = false
		position = atPosition
		slave_pos = transMatrix
		slave_motion = Vector2(0,0)
		hunger = 0
	player.alive = true
	player.reviving = true

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

func kill():
	# kills this player	
	if get_tree().is_network_server():
		rpc("killed", get_name())
		cameraNode.killedRumble()
		if allPlayersKilled():
			rpc("showGameOverScreen")
			
func disableInputs():
	# disable all the inputs, for better kill handeling
	inputsDisabled = true
	

func _on_player_body_shape_entered( body_id, body, body_shape, local_shape ):
	if(body.has_node("obstacleShape") or body.has_node("enemyShape")) and alive and !isKillProtected:
		kill()

func _on_player_body_shape_exited( body_id, body, body_shape, local_shape ):
	pass # replace with function body