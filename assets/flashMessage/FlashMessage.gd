extends Control

var tweenToTop = Tween.new()

onready var animationPlayer = get_node("AnimationPlayer")
onready var node2D = get_node("Node2D")
onready var label1 = get_node("Node2D/RichTextLabel1")

func _ready():
	add_child(tweenToTop)
	animationPlayer.connect("animation_finished",self,"_animation_finished")
	tweenToTop.connect("tween_completed",self,"_tween_to_top_finished")
	pass
	
func _tween_to_top_finished(_a,_b):
	queue_free()

func _animation_finished(_string):
	pass

func showPointsAt(_val,_string,_pos,_player): ## how much points, position whre has been hit, player who hit
	set_visible(true)
	if _val == null:
		_val = ""
	node2D.position=_pos +Vector2(0,20)
	label1.bbcode_text = "[color=#"+ utils.computeColor(_player).to_html()  + "][center]" + str(_val) +_string+ "[center]"
	animationPlayer.play("flashMessageCollected")
	tweenToTop.interpolate_property(
		node2D,
		"position",
		node2D.position,
		Vector2(node2D.position.x,-50),
		1.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	tweenToTop.start()