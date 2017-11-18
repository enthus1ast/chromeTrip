extends Node2D

var sound1=load("res://sounds/heartSound.ogg")
var sound2=load("res://sounds/meatSound.ogg")
var sounds = {
	"heart":sound1,
	"meat":sound2,
	"badge":sound1
}
onready var FlashMessage = preload("res://assets/flashMessage/FlashMessage.tscn")
onready var control = get_tree().get_root().get_node("Control")
onready var spriteNode = get_node("spriteNode")
onready var game = control.get_node("game")
onready var hud = game.get_node("hud")
var isCollected = false
var basePoints = 1000
var foodValue = 25
var selectedCollectable
var onCollectParticles
var animatedSprite
var targetTopRight = Vector2(1042,-10)
var targetBottomLeft = Vector2(1,820)
var collectedPosTween = Tween.new()
var deleteTimer = Timer.new()
onready var soundPlayer = get_node("AudioStreamPlayer") #AudioStreamPlayer.new()
var flashMessage

func _tween_complete(_object, _key ):
	deleteTimer.start()
func _breed_complete(_object):
	print("breeding complete: ", _object)
#	_object.
	queue_free()

func _ready():
#	spriteNode.add_child(soundPlayer)
	soundPlayer.stream = sounds[selectedCollectable]
	soundPlayer.stream.loop = false
	soundPlayer.volume_db = -12.0
	var animSprite =spriteNode.get_node(selectedCollectable+"Area").get_node("AnimatedSprite")
	animSprite.set_frame(round(rand_range(0,animSprite.get_sprite_frames().get_frame_count("default")))) 
	for child in spriteNode.get_children():
		if typeof(child)==typeof(Area2D):
			child.pause_mode=1
	flashMessage = FlashMessage.instance()
	hud.add_child(flashMessage)
	add_child(collectedPosTween)
	collectedPosTween.connect("tween_completed",self,"_tween_complete")
	get_node("spriteNode/badgeArea/Badges").connect("breed_complete",self,"_breed_complete") # for badges
	deleteTimer.connect("timeout",self,"_delete_timeout")
	add_child(deleteTimer)
	deleteTimer.wait_time = 5
	set_process(true)

func choice(_name):
	selectedCollectable = _name
	var spriteNode = get_node("spriteNode")
	spriteNode.get_node(_name+"Area").pause_mode=0
	spriteNode.get_node(_name+"Area").set_visible(true)
	spriteNode.get_node(_name+"Area/collectableShape").disabled=false
	
	if _name != "badge":
		animatedSprite = get_node("spriteNode/"+_name+"Area/AnimatedSprite")
		onCollectParticles = animatedSprite.get_node("onCollectParticles/Particles2D")
		onCollectParticles.texture = animatedSprite.get_sprite_frames().get_frame("default",int(rand_range(0,2)))
#	if _name == "badge":
		
func _process(delta):
	position.x -= delta*game.fakeSpeed
 
func _on_meatArea_body_entered( body ):
	if get_tree().is_network_server():
		if body.is_in_group("players") and !isCollected:
			rpc("rpcEatFood",body,body.name)
			pass

sync func rpcEatFood(_playerNode,_playerName):
	onCollectParticles.emitting=true
	if !soundPlayer.is_playing():
#		soundPlayer.play(0.0)
		soundPlayer.play()
	if _playerNode.hunger < foodValue and _playerNode.hunger>=0:
		_playerNode.hunger -= foodValue
	else:
		_playerNode.hunger = 0
	flashMessage.showPointsAt(null,"Tasty!",position,_playerName)
	set_process(false)
	isCollected = true
	collectedPosTween.interpolate_property(self,"position",position,targetBottomLeft,.6, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	collectedPosTween.start()

remote func calcPointsFromHeight(_height): #ony server shoud run this
	var points = basePoints-_height
	return round(points)

func _on_heartArea_body_entered( body ):
	if get_tree().is_network_server():
		if body.is_in_group("players") and !isCollected:
			rpc("rpcScoreAdd",calcPointsFromHeight(position.y),body.name)
			pass	

sync func rpcScoreAdd(_value,_player):
#	var collectable
	if !soundPlayer.is_playing():
			soundPlayer.play(0.0)
	onCollectParticles.emitting = true
	flashMessage.showPointsAt(_value,"Points",position,_player)
	set_process(false)
	isCollected = true
	collectedPosTween.interpolate_property(self,"position",position,targetTopRight,.5, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	collectedPosTween.start()
	get_tree().get_root().get_node("Control/game").score = game.score + _value

func _on_VisibilityNotifier2D_screen_exited():
	if !isCollected and is_inside_tree():
		deleteTimer.stop()
		queue_free()
	else:
		deleteTimer.start()
	pass # replace with function body

func _delete_timeout():
	if is_inside_tree():
		queue_free()

sync func rpcActivateBadge(_playerNode):
#	onCollectParticles.emitting=true
#	if !soundPlayer.is_playing():
##		soundPlayer.play(0.0)
#		soundPlayer.play()
#	if _playerNode.hunger < foodValue and _playerNode.hunger>=0:
#		_playerNode.hunger -= foodValue
#	else:
#		_playerNode.hunger = 0
#	flashMessage.showPointsAt(null,"Tasty!",position,_playerName)
	set_process(false)
	isCollected = true
	get_node("spriteNode/badgeArea/Badges").breed()
	if control.currentPlayer.id == int(_playerNode.get_name()):
		print("player can be a bird now: " + str(control.currentPlayer))
		utils.config.set_value("player", "beabird", true)
		utils.config.save(utils.CONFIG_PATH)
		
#	collectedPosTween.interpolate_property(self,"position",position,targetBottomLeft,.6, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
#	collectedPosTween.start()
#	deleteTimer.start()
	
func _on_badgeArea_body_entered( body ):
	pass # replace with function body
	if get_tree().is_network_server():
		if body.is_in_group("players") and !isCollected:
			rpc("rpcActivateBadge",body)
			pass	