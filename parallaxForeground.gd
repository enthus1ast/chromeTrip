extends Node2D

onready var disabledSprites = get_node("Sprites")
onready var childrenArray = disabledSprites.get_children()
onready var parentNode = get_node("Node2D")
onready var control = get_tree().get_root().get_node("Control")

var game
var texture
var count = 20
var isInitial = true
var time = 0
var backgroundGame = false

func _ready():
	if control.has_node("game"):
		game = control.get_node("game")
	elif game==null:
		game = control.get_node("backgroundGame")
		backgroundGame = true
	texture = childrenArray[0].get_texture()
	set_process(true)
	
func genPos():
	var posX
	var posY
	if isInitial:
		posX = rand_range(1200,2000)
	else:
		posX = rand_range(1200,2000)
	posY = rand_range(480,700)
	return Vector2(posX,posY)
	
func genSpeed(_posY):
	var speedY = _posY*game.fakeSpeed/300
	return speedY
	
func genScale(_posY):
	var tmp = _posY/300
	var myscale = Vector2(tmp,tmp)
	return myscale

func doNewSprite():
	if backgroundGame or get_tree().is_network_server():
		var choice
		var flipped = false
		if rand_range(0,2) > 1:
			flipped = true
		choice = int(rand_range(1,disabledSprites.get_child_count()))
		var pos = genPos()		
		if backgroundGame: 
			newSprite(choice, flipped, pos)
		elif get_tree().is_network_server():
			rpc("newSprite", choice, flipped, pos)

sync func newSprite(choice, flipped, pos):
	var sprite = Sprite.new()
	sprite.texture = texture
	sprite.region_enabled=true;
	sprite.set_region_rect(disabledSprites.get_node("Sprite"+str(choice)).get_region_rect())
	parentNode.add_child(sprite)
	sprite.position = pos
	sprite.z = sprite.position.y
	sprite.scale= genScale(sprite.position.y)
	sprite.flip_h = flipped

func _process(delta):
	time += delta
	if count > parentNode.get_child_count() and time > 1:
		time = 0
		doNewSprite()
	for object in parentNode.get_children():
		object.position.x -= delta * genSpeed(object.position.y)
		if object.position.x<-100 and !object.is_queued_for_deletion():
			object.queue_free()
	