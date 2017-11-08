extends Node2D


onready var disabledSprites = get_node("Sprites")
onready var childrenArray = disabledSprites.get_children()
onready var parentNode = get_node("Node2D")
var texture
var count = 8
var speed = 300
var isInitial = true
var time = 0


func _ready():
	texture = childrenArray[0].get_texture()
	set_process(true)
	pass
	
func genPos():
	var posX
	var posY
	if isInitial:
		posX = rand_range(1200,4000)
		
	else:
#		isInitial = false
		posX = rand_range(1200,4000)
	posY = rand_range(480,600)
	return Vector2(posX,posY)
	
func genSpeed(_posY):
	var speedY = _posY
	return speedY
	
func genScale(_posY):
	var tmp = _posY/300
	var myscale = Vector2(tmp,tmp)
	return myscale

func newSprite():

	var sprite = Sprite.new()
	sprite.texture = texture
	sprite.region_enabled=true;
	sprite.set_region_rect(disabledSprites.get_node("Sprite"+str(int(rand_range(1,disabledSprites.get_child_count())))).get_region_rect())
	parentNode.add_child(sprite)
	sprite.position = genPos()
	sprite.z = sprite.position.y
	sprite.scale= genScale(sprite.position.y)

func _process(delta):
	time += delta
	if count > parentNode.get_child_count() and time > 1:
		time = 0
		newSprite()
		
	for object in parentNode.get_children():
		object.position.x -= delta * genSpeed(object.position.y)
		if object.position.x<-100:
			object.queue_free()
	