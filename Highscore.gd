extends Control

onready var highscoreItem = load("res://HighscoreItem.tscn")
onready var cont = get_node("ScrollContainer/VBoxContainer")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var highscoreCount = 500


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	# the header
	var header = highscoreItem.instance()
#	header. = 20
#	header.set_size = Vector2(1000, 1000)
	cont.add_child(header)
	
	
	var highscore = utils.getHighscore(highscoreCount)
	print(highscore)
	var idx = 0
	for scoreLine in highscore:	
		idx += 1
		if scoreLine == null: continue
		var line = highscoreItem.instance()
		line.fill(idx, scoreLine.score, scoreLine.team)
#		print(highscore[idx])
#		print(idx)
	
		cont.add_child(line)
	
	
	
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_back_pressed():
	self.hide()
	get_tree().get_root().get_node("Control/menu/MainMenu").show()
