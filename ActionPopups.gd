extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var player = get_node("AnimationPlayer")
onready var label = get_node("RichTextLabel1")
onready var label2 = get_node("RichTextLabel2")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	showStage(10)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func showStage(val):
	## shows big x2 
	label.bbcode_text = "[color=red][b]STAGE[/b][/color]"
	label2.bbcode_text = str(val)
#	player.play("stage")
	