extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func fill(rank, score, team):
#	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ", foo)
#	nscore.text = str(s)
#	nteam.text = str(t)
	get_node("Rank").text = str(rank)
	get_node("Score").text = str(score)
	
	var teamline = ""
	for player in team:
		var one = utils.computeColorBB( player, player ) + " "
		teamline += one 
		
	print(str(teamline))
	get_node("Team").set_bbcode(str(teamline))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
#	fill(10, ["Foo"])
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
