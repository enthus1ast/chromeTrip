extends Control

onready var highscoreItem = load("res://HighscoreItem.tscn")
onready var cont = get_node("ScrollContainer/VBoxContainer")
export var highscoreCount = 500

func _ready():
	# the header
	var header = highscoreItem.instance()
	header.rect_min_size.y = 30
	cont.add_child(header)
	var highscore = utils.getHighscore(highscoreCount)
	var idx = 0
	for scoreLine in highscore:	
		idx += 1
		if scoreLine == null: continue
		var line = highscoreItem.instance()
		line.fill(idx, scoreLine.score, scoreLine.stage, scoreLine.team)
		cont.add_child(line)

func _on_back_pressed():
	self.hide()
	get_tree().get_root().get_node("Control/menu/MainMenu").show()
