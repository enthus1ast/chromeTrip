extends Node2D

onready var Vulkan = preload("res://assets/vulkan.tscn")
onready var Shower = preload("res://assets/rockShower.tscn")

onready var control = get_tree().get_root().get_node("Control")
onready var mountains = get_node("gebirge")
onready var vulkanNode = get_node("vulkan")

var game
var availableMountains = []
var counter = 0
var isInitial = true
var canSpawn = true
var isErrupting = false
var activeVulkan = null

var vulkanPosition = Vector2(517,300)

#storeing a prebuild mountain collection in this scene
func storeAvailableMountains():
	for sprite in mountains.get_children():
		var mountain = {}
		mountain["texture"] = sprite.texture
		mountain["global_position"] = sprite.global_position
		mountain["scale"] = sprite.scale
		mountain["centered"] = sprite.centered
		mountain["flip_h"] = sprite.flip_h
		mountain["region_enabled"] = sprite.region_enabled
		mountain["region_rect"] = sprite.region_rect
		availableMountains.append(mountain)

#create sprite from stored prebuild template
func createSprites(_offset):
	if !isInitial:
		var v = Vulkan.instance()
		activeVulkan = v
		vulkanNode.add_child(v)
		v.global_position = vulkanPosition + Vector2(_offset,0)
	for _object in availableMountains:
		var sprite = Sprite.new()
		var visibleNotifier = VisibilityNotifier2D.new()
		sprite.texture = _object.texture
		sprite.scale = _object.scale
		sprite.centered = _object.centered
		sprite.flip_h = _object.flip_h
		sprite.region_enabled = _object.region_enabled
		sprite.region_rect = _object.region_rect
		mountains.add_child(sprite)
		sprite.add_child(visibleNotifier)
		visibleNotifier.connect("screen_exited",self,"_on_VisibilityNotifier2D_screen_exited")
		sprite.global_position = _object.global_position + Vector2(_offset,0)
	isInitial = false

func _ready():
	if control.has_node("game"):
		game = control.get_node("game")
	elif game==null:
		game = control.get_node("backgroundGame")
	# store available sprites for later reuse
	storeAvailableMountains()
	createSprites(1000)
	pass

func _process(delta):
	position -= Vector2(delta * game.fakeSpeed/35,0)
	if position.x < -1000 * counter and canSpawn:
		canSpawn = false
		createSprites(1000)
		counter+=1
		canSpawn = true
	if activeVulkan!=null:
		if game.get_name()!="backgroundGame":
			if activeVulkan.global_position.x > 400 and activeVulkan.global_position.x < 600 and !isErrupting:
				isErrupting = true
				activeVulkan.errupt()
				var rockShower = Shower.instance()
				game.add_child(rockShower)
				rockShower.letItRain(20,20)
				
func _on_VisibilityNotifier2D_screen_exited():
	for sprite in mountains.get_children():
		if sprite.is_inside_tree() and sprite.global_position.x<-200:
			sprite.queue_free()
