extends Control

onready var animationPlayer = get_node("AnimationPlayer")
onready var node2D = get_node("Node2D")
onready var label1 = get_node("Node2D/RichTextLabel1")
#onready var label2 = get_node("RichTextLabel2")

func _ready():
	animationPlayer.connect("animation_finished",self,"_animation_finished")
	pass
	
func _animation_finished(_string):
	set_visible(false)

func showPointsAt(_val,_pos):
	set_visible(true)
#	animationPlayer.play("actionPopupStage")
	## shows big x2
	node2D.position=_pos +Vector2(0,20)
	label1.bbcode_text = str(_val) + " Points"
#	player.play("stage")
	