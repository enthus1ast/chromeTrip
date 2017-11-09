extends Node2D

onready var game = get_tree().get_root().get_node("Control/game")

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # replace with function body


func _on_heartArea_body_entered( body ):
	if body.is_in_group("players"):
		rpc("rpcScoreAdd",1000)
		pass

sync func rpcScoreAdd(_value):
	get_tree().get_root().get_node("Control/game").score = game.score + _value