extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var cam = get_node("Camera2D")

var cnt = 100
var displace = 10

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	set_process_input(true)

func bigHit():
	cnt = 3
	displace = 50

func quake():
	cnt = 100
	displace = 5

func _input(event):
	if event.is_action_pressed("ui_enter"):
		bigHit()
		
	if event.is_action_pressed("ui_up"):
		quake()

#func earthQuake(hard, howLong):



func _process(delta):
	print(cnt)
	if cnt > 0:
		cnt -= 1
		# Called every frame. Delta is time since last frame.
		# Update game logic here.
		
		var off = Vector2(rand_range(-displace, displace), rand_range(-displace, displace))
		print(off)
	#	cam.offset = cam.offset + (off * delta)
#		cam.offset = (off * delta)
		cam.offset = off 
		pass
	else:
		cam.offset = Vector2(0,0)
