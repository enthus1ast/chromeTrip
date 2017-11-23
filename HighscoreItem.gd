extends HBoxContainer

func fill(rank, score, stage, team):
	get_node("Rank").text = str(rank)
	get_node("Score").text = str(score)
	get_node("Stage").text = str(stage)
	var teamline = ""
	for player in team:
		var one = utils.computeColorBB( player, player ) + " "
		teamline += one 
	get_node("Team").set_bbcode(str(teamline))

func _ready():
	pass
