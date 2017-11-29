extends RigidBody2D

export var playerName = "SET_ME_PLAYER_NAME" # the player name
export var hunger = 0 # hunger level
export sync var slave_hunger = 0 # hunger level

sync var slave_pos = Transform2D()
sync var slave_motion = Vector2()
sync var alive = true
var readyToPlay = false # this gets set to true when the player has loaded the playscene
var reviving = false

var cameraNode
var acceleration = 10000
var top_move_speed = 200
var top_jump_speed = 800
var jumpSound = load("res://sounds/jump.ogg")
var top_fly_speed = 270
var top_flyup_speed = 400
var killedSound = load("res://sounds/killed.ogg")
var killprotectTimer = Timer.new()
var isKillProtected = false
var needForFood = 2# speed of getting hungry
var inputsDisabled = false
var type = "SET_ME_TYPE"

# Movement Vars
var directional_force = Vector2()
const DIRECTION = {
    ZERO = Vector2(0, 0),
    LEFT = Vector2(-1, 0),
    RIGHT = Vector2(1, 0),
    UP = Vector2(0, -1),
    DOWN = Vector2(0, 1)
}

# Jumping
var first_jump = false
var can_jump = true
var grounded = false 
var jump_time = 0
const TOP_JUMP_TIME = 0.1 # in seconds

# Bird
var fly_time = 0
var TOP_FLY_TIME = 0.02
var flyTimer = 0.2
var can_fly = true

# Movement
var keys = [false,false,false,false] # right, left, up, down 

onready var playerColShape = get_node("playerShape")
onready var hungerInfo = get_tree().get_root().get_node("Control/game/hud/Fleisch")
onready var soundPlayer =  get_node("AudioStreamPlayer") #AudioStreamPlayer.new())
onready var game = get_tree().get_root().get_node("Control/game")
onready var animPlayer = get_node("Sprite/AnimationPlayer")
onready var powerUpPlayer = get_node("Sprite/AnimationPlayerPowerUps")
onready var particleAnimPlayer = get_node("particleSystems/particleAnimPlayer")

func resetKeys():
	keys = [false,false,false,false]

func _ready():
	if game != null:
		cameraNode = game.get_node("cameraNode")
	add_child ( killprotectTimer )
	killprotectTimer.wait_time = 3
	killprotectTimer.connect("timeout", self, "_killprotectTimeout")
	set_process_input(true)
	if type == "bird":
		gravity_scale = 8
		linear_damp = 0.5
		rpc("playAnimation", "birdFly")
	elif type == "dino":
		rpc("playAnimation", "trexAnimRun")
	if is_network_master():
		add_to_group("currentPlayer")

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

func _process(delta):#
	if is_network_master():
		rset("slave_hunger",hunger)
		hungerInfo.amount = 100-hunger
		if alive and (hunger<100 and hunger>=0):
			hunger += delta*needForFood
		elif alive and hunger>=100:
#			hunger = 0
			#death by starving
			print("killed by hunger")
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
		if global_position.x < -5 and alive:
			kill()
		if !alive:
			pass
		if reviving:
			reviving = false
			state.set_transform( slave_pos )
		directional_force = DIRECTION.ZERO  # +FOWARD_MOTION
		apply_force(state)
		final_force = state.get_linear_velocity() + (directional_force * acceleration)
		if(type == "dino"):
			if(final_force.x > top_move_speed):
				final_force.x = top_move_speed
			elif(final_force.x < -top_move_speed):
				final_force.x = -top_move_speed
			if(final_force.y > top_jump_speed):
				final_force.y = top_jump_speed
			elif(final_force.y < -top_jump_speed):
				final_force.y = -top_jump_speed
		elif (type == "bird"):
			if(final_force.x > top_fly_speed):
				final_force.x = top_fly_speed
			elif(final_force.x < -top_fly_speed):
				final_force.x = -top_fly_speed
			if(final_force.y > top_flyup_speed):
				final_force.y = top_flyup_speed
			elif(final_force.y < -top_flyup_speed):
				final_force.y = -top_flyup_speed
		rset("slave_motion",final_force)
		rset("slave_pos",state.get_transform())
	else:
		state.set_transform(slave_pos)
		final_force = slave_motion
	state.set_linear_velocity(final_force)
	
func apply_force(state):
    # Move Right
	if keys[0]:
		directional_force += DIRECTION.RIGHT
	# Move Left
	if keys[1]:
		directional_force += DIRECTION.LEFT
    # Jump
	if keys[2] and alive:
		if type == "dino":
			dinoJump(state)
		elif type == "bird":
			 birdFly(state)
			
func birdFly(state):
	if fly_time < TOP_FLY_TIME and can_fly and global_position.y>10:
		directional_force += DIRECTION.UP/100
	elif flyTimer >= 0:
		can_fly = false
		flyTimer-=state.get_step()
	else:
		flyTimer=0.2
		fly_time = 0
		can_fly=true

func dinoJump(state):
	if jump_time < TOP_JUMP_TIME and can_jump:
		if ((grounded and can_jump) or !first_jump):
			rpc("rpcJumpParticles",get_name())
			cameraNode.jumpRumble()
			if soundPlayer.stream != jumpSound:
				soundPlayer.set_stream(jumpSound)
			if not soundPlayer.playing:
				soundPlayer.play(0.0)	
		directional_force += DIRECTION.UP
		jump_time += state.get_step()
		if !first_jump:
			directional_force += DIRECTION.UP*5000
			first_jump = true
    # While on the ground
	if(grounded):
		can_jump = true
		jump_time = 0

func _on_groundSensor_body_entered( body ):
	if body.is_in_group("players") and body.get_name() != get_name():
		if type =="dino":
			grounded = true
	elif body.is_in_group("ground") or body.is_in_group("rocks"):
		if type =="dino":
			grounded = true
		if alive:
			cameraNode.landRumble(linear_velocity.y)
	elif body.is_in_group("rocks"):
		if type =="dino":
			grounded = true
		if alive:
			cameraNode.landRumble(linear_velocity.y)

func _on_groundSensor_body_exited( body ):
	if body.is_in_group("players")and type =="dino":
		grounded = false
	elif body.is_in_group("ground"):
		grounded = false
	elif  body.is_in_group("rocks"):
		grounded = false

sync func playAnimation(_string):
	animPlayer.play(_string)
	
sync func animSpeed(_speed):
	get_node("Sprite/AnimationPlayer").set_speed_scale(_speed)
	
sync func rpcJumpParticles(_id):
	get_parent().get_node(_id).particleAnimPlayer.play("particleJump")

func _input(event):
	if is_network_master() and alive and not inputsDisabled:
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
				if type=="bird":
					rpc("playAnimation","birdFly")
				elif type == "dino":
					rpc("playAnimation","trexAnimDuck")

			elif event.is_action_released("ui_down"):
				if type == "dino":
					rpc("playAnimation","trexAnimRun")
				elif type == "bird":
					rpc("playAnimation","birdFly")
				keys[3] = false
			
			#jumping keyevents
			if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_select"):
				keys[2]=true
			elif event.is_action_released("ui_up") or event.is_action_released("ui_select"):
				keys[2]=false
				can_jump = false # Prevents the player from jumping more than once while in air
#				rset("slave_can_jump",can_jump)
	elif is_network_master() and (!alive or inputsDisabled ): # not alive
		keys = [false,false,false,false]
		can_jump = false
		
sync func killed(_id):
	if !isKillProtected:
		var player = get_parent().get_node(str(_id))
		player.get_node("playerShape").disabled=true
		player.alive = false
		player.can_jump = false
		if player.type =="dino":
			player.get_node("Sprite/AnimationPlayer").play("trexAnimKilled")
		elif player.type =="bird":
			player.get_node("Sprite/AnimationPlayer").play("birdAnimKilled")
		soundPlayer.stream = killedSound
		soundPlayer.stream.loop = false
		soundPlayer.play(0.0)

sync func RPCreanimate(_id, atPosition):
	var player = get_parent().get_node(str(_id))
	var transMatrix = Transform2D(Vector2(),Vector2(), atPosition)
	player.alive = true
	player.reviving = true
	player.isKillProtected = true
	player.powerUpPlayer.play("killProtected")
	player.killprotectTimer.start()
	player.set_collision_mask_bit(3, false) ## layer for obstacles
	player.set_collision_mask_bit(4, false) ## layer for enemies
	player.get_node("playerShape").disabled=false
	player.get_node("playerShape").update()
	if player.type == "dino":
		player.can_jump = true
		player.grounded = false
		player.get_node("Sprite/AnimationPlayer").play("trexAnimRun")
	if player.type == "bird":
		player.get_node("Sprite/AnimationPlayer").play("birdFly")
	player.slave_pos = transMatrix
	player.hunger = 0
	player.slave_motion = Vector2(0,0)

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
	cameraNode.killedRumble()
	if get_tree().is_network_server():
		rpc("killed", get_name())
		if allPlayersKilled():
			rpc("showGameOverScreen")
			
func disableInputs():
	# disable all the inputs, for better kill handeling
	inputsDisabled = true
	
func _on_player_body_shape_entered( body_id, body, body_shape, local_shape ):
	if(body.has_node("obstacleShape") or body.has_node("enemyShape")) and alive and !isKillProtected:
		kill()
	
	# Kill bird if it hits the ground
	if(type == "bird" and body.is_in_group("ground")) and alive and !isKillProtected:
		kill()

func _on_player_body_shape_exited( body_id, body, body_shape, local_shape ):
	pass # replace with function body

func _on_AudioStreamPlayer_finished():
	soundPlayer.stop()
#	print("player sound finished")
	