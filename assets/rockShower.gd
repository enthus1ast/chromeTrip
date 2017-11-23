extends Node2D
var Rock = preload("res://assets/rock.tscn")

var timeToStart = Timer.new()
var timer = Timer.new()
var count
var timeout = 1


onready var game = get_tree().get_root().get_node("Control/game")
onready var constMovementNode = game.get_node("sprites/constantMovement")

func _ready():
	if get_tree().is_network_server():
		timer.wait_time = timeout
		timer.connect("timeout",self,"_timeout")
		timeToStart.connect("timeout",self,"_time_to_start_timeout")
		add_child(timer)
		add_child(timeToStart)
	
func letItRain(_timeTo_Start,_count):
	print(get_tree())
	if get_tree().is_network_server():
		timeToStart.wait_time = _timeTo_Start
		timeToStart.start()
		count = _count
		
		
func _timeout():
	if get_tree().is_network_server():
		timer.stop()
		if count>0:
			timer.wait_time = timeout
			timer.start()
			var scaling = rand_range(0.5,1.5)
			var pos = Vector2(rand_range(0,1024),-100)
			var ang_vel =  rand_range(-25,25)
			var named = "rock"+str(count)
			count-=1
			rpc("rpcCreateRock",pos,scaling,ang_vel,named)
		
sync func rpcCreateRock(_pos,_scale,_ang_vel,_name):
	var rock = Rock.instance()
	rock.set_name(_name)
	var collisionShape = rock.get_node("CollisionShape2D")
	collisionShape.scale = collisionShape.scale * _scale
	add_child(rock)
	rock.global_translate(_pos)
	rock.angular_velocity = _ang_vel
	rock.add_to_group("rocks")

func _time_to_start_timeout():
	print("rain!!")
	timeToStart.stop()
	timer.start()


func removeRockShowerNode():
	queue_free()
	pass

