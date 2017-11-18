extends Node2D

onready var game = get_tree().get_root().get_node("Control/game")
signal breed_complete 

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func breed():
	get_node("AnimationPlayer").play("breed")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass



func _on_AnimationPlayer_animation_finished( name ):
	pass # replace with function body
	print ("BREED complete in badges")
	emit_signal("breed_complete", self) # null to fake tween completed
