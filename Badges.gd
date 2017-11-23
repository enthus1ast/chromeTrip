extends Node2D

onready var game = get_tree().get_root().get_node("Control/game")
signal breed_complete 

func _ready():
	pass
	
func breed():
	get_node("AnimationPlayer").play("breed")

func _on_AnimationPlayer_animation_finished( name ):
	pass # replace with function body
	print ("BREED complete in badges")
	emit_signal("breed_complete", self) # null to fake tween completed
