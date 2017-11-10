extends Control

onready var animationPlayer = get_node("AnimationPlayer")
onready var label1 = get_node("Node2D/RichTextLabel1")
#onready var label2 = get_node("RichTextLabel2")

func _ready():
	
	animationPlayer.connect("animation_finished",self,"_animation_finished")
	pass
	
func _animation_finished(_string):
	set_visible(false)

func showStage(val):
	set_visible(true)
	animationPlayer.play("actionPopupStage")
	## shows big x2 
	label1.bbcode_text = "STAGE " #"[color=red][b]STAGE[/b][/color]"
	label1.bbcode_text += str(val)
#	player.play("stage")
	