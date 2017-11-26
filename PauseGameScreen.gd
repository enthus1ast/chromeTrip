extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var animationPlayer = get_node("AnimationPlayer")
func setPlayerPaused(playername):
	print("FOO: ", playername)
	get_node("Label").text = playername + " " + TranslationServer.translate("PAUSED") # "PLAYERNAME"  #= playername  #+ " " + TranslationServer.translate("PAUSED")
	
	# to top
#	move_child(self, get_parent().get_child_count() )
	show()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
#	hide()
	pass



func _on_PauseGameScreen_visibility_changed():
	pass # replace with function body
	if visible:
		animationPlayer.play("blink")
	else:
		animationPlayer.stop()
