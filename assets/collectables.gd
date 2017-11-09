extends Node2D

onready var game = get_tree().get_root().get_node("Control/game")
var isCollected = false
var base = 1000
var target = Vector2(1042,0)
var collectedPosTween = Tween.new()

func _tween_complete(_object, _key ):
	queue_free()

func _ready():
	add_child(collectedPosTween)
	collectedPosTween.connect("tween_completed",self,"_tween_complete")
	set_process(true)

func _process(delta):
	position.x -= delta*game.fakeSpeed
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # replace with function body
 

remote func calcPointsFromHeight(_height): #ony server shoud run this
	var points = base-_height
	return round(points)

func _on_heartArea_body_entered( body ):
	if body.is_in_group("players") and !isCollected:
		rpc("rpcScoreAdd",calcPointsFromHeight(position.y))
		pass

sync func rpcScoreAdd(_value):
	set_process(false)
	isCollected = true
	collectedPosTween.interpolate_property(self,"position",position,target,.5, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	collectedPosTween.start()
	get_tree().get_root().get_node("Control/game").score = game.score + _value