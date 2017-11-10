extends HBoxContainer

func fill(rank, score, team):
	get_node("Rank").text = str(rank)
	get_node("Score").text = str(score)
	
	var teamline = ""
	for player in team:
		var one = utils.computeColorBB( player, player ) + " "
		teamline += one 
		
	print(str(teamline))
	get_node("Team").set_bbcode(str(teamline))

func _ready():
	pass
