extends Node2D

onready var FlashMessage = preload("res://assets/flashMessage/FlashMessage.tscn")
onready var control = get_tree().get_root().get_node("Control")
onready var spriteNode = get_node("spriteNode")
onready var game = control.get_node("game")
onready var hud = game.get_node("hud")
var isCollected = false
var basePoints = 1000
var foodValue = 50
var selectedCollectable

var targetTopRight = Vector2(1042,0)
var targetBottomLeft = Vector2(1,820)
var collectedPosTween = Tween.new()
var flashMessage

func _tween_complete(_object, _key ):
	queue_free()

func _ready():
	var animSprite =spriteNode.get_node(selectedCollectable+"Area").get_node("AnimatedSprite")
	animSprite.set_frame(round(rand_range(0,animSprite.get_sprite_frames().get_frame_count("default")))) 
	for child in spriteNode.get_children():
		if typeof(child)==typeof(Area2D):
			child.pause_mode=1
	flashMessage = FlashMessage.instance()
	hud.add_child(flashMessage)
	add_child(collectedPosTween)
	collectedPosTween.connect("tween_completed",self,"_tween_complete")
	set_process(true)

func choice(_name):
	selectedCollectable = _name
	get_node("spriteNode").get_node(_name+"Area").pause_mode=0
	get_node("spriteNode").get_node(_name+"Area").set_visible(true)
	get_node("spriteNode").get_node(_name+"Area").get_node("collectableShape").disabled=false

func _process(delta):
	position.x -= delta*game.fakeSpeed
 
func _on_meatArea_body_entered( body ):
	if body.is_in_group("players") and !isCollected:
		rpc("rpcEatFood",body,control.players[int(body.get_name())].name)
		print(control.players[int(body.get_name())].name)
		pass

sync func rpcEatFood(_playerNode,_playerName):
	
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
	if body.is_in_group("players") and !isCollected:
		rpc("rpcScoreAdd",calcPointsFromHeight(position.y),control.players[int(body.get_name())].name)
		pass

sync func rpcScoreAdd(_value,_player):
	flashMessage.showPointsAt(_value,"Points",position,_player)
	set_process(false)
	isCollected = true
	collectedPosTween.interpolate_property(self,"position",position,targetTopRight,.5, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	collectedPosTween.start()
	get_tree().get_root().get_node("Control/game").score = game.score + _value

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # replace with function body



