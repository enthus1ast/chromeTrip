extends Node2D

var rumbleEnd = false
var isRumbling = false

##process vars
var cnt = 0
var displace = 0
var hitDisplace = 0
var quakeDisplace = 0
var isQuaking = false

onready var animPlayer = get_node("AnimationPlayer")
onready var cam = get_node("Camera2D")

func killedRumble():
	if !isQuaking:
		cnt += 10
		displace = 400

func bigHit():
	cnt += 10
	hitDisplace = 250

func quake(): #medium quake
	isQuaking = true
	cnt += 650
	quakeDisplace = 180
	
func jumpRumble():
	cnt += 10
	displace = 60
	
func landRumble(_velocity):
	cnt += 12
	displace = 100
	
func _ready():
	pass

func _process(delta):
	var addForce
	if cnt > 0:
		addForce = Vector2(0,0)
		cnt -= 1
		var off = Vector2(rand_range(-displace, displace), rand_range(-displace, displace))
		if isQuaking:
			addForce = Vector2(rand_range(-quakeDisplace, quakeDisplace), rand_range(-quakeDisplace, quakeDisplace))
		cam.offset = (addForce+off) * delta
	else:
		addForce = Vector2(0,0)
		isQuaking = false
		cam.offset = Vector2(0,0)
