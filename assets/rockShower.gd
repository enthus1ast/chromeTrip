extends Node2D
var Rock = preload("res://assets/rock.tscn")
var timer = Timer.new()
var count
onready var game = get_tree().get_root().get_node("Control/game")
onready var constMovementNode = game.get_node("sprites/constantMovement")

func _ready():
	timer.wait_time = 2
	timer.connect("timeout",self,"_timeout")
	add_child(timer)
	letItRain(20)
	pass
	
func letItRain(_count):
	count = _count
	timer.start()
	
func setScale(_obj):
	var sprite = _obj.get_node("Sprite")
	var collisionShape = _obj.get_node("CollisionShape2D")
	var area2D = _obj.get_node("Area2D")
	var scaleFac = rand_range(0.5,1.5)
	area2D.scale = area2D.scale * scaleFac
	sprite.scale = sprite.scale * scaleFac
	collisionShape.scale = collisionShape.scale * scaleFac
	
func _timeout():
	timer.stop()
	if count>0:
		timer.wait_time = 1
		timer.start()
		##sync this for client
		var rock = Rock.instance()
		setScale(rock)
		add_child(rock)
		rock.add_to_group("rocks")
		rock.global_translate(Vector2(rand_range(0,1024),-100))
		rock.angular_velocity = rand_range(-25,25)
#		rock.transform()
		count-=1

