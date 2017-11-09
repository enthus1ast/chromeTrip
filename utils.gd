extends Node

var version = 0.1 # general version of this game
const HIGHSCORE_PATH = "user://highscore.dat" # where the highscore is safed on the filesystem.
const HIGHSCORE_PW = "code0"
func pad2(st):
	# pads the string with one 0
	if st.length() < 2:
		return "0" + st
	else:
		return st

func computeColor(st):
  # computes "classic" rgb colors from string
  var commulated=0;
  for ch in st:
    commulated = commulated + ch.to_ascii()[0]
  var communist = commulated%235 + 20
  var co = Color( 
    pad2(("%x" % [communist])) +
    pad2(("%x" % [int(pow(int(communist),2)) % 255])) +
    pad2(("%x" % [int(pow(int(communist),3)) % 255])) #+ 
  )
  return co

func createFile(path):
	# Create the file if its not here
	var file = File.new()
	if file.file_exists(path):
		return
	else:
		file.open( path, file.WRITE)
		file.close()

func putHighscore(score, team): 
	# puts a line into the crypted highscore file.
	createFile(HIGHSCORE_PATH)
	var file = File.new()
#	file.open_encrypted_with_pass( HIGHSCORE_PATH, file.READ_WRITE, HIGHSCORE_PW )
	file.open( HIGHSCORE_PATH, file.READ_WRITE) #, "code0" )
	var tup = {}
	tup["score"] = score
	tup["team"] = team
	tup["date"] = OS.get_datetime(true)
	var line = to_json(tup)
#	print("Line:", line)
	file.seek_end()
	file.store_line(line)
	file.close()

func cmp(elemA, elemB):
	if elemA.score > elemB.score:
		return true
	else:
		return false
		
func sortHighscore(highscoreArray):
	highscoreArray.sort_custom(self, "cmp")
	return highscoreArray

func getTeam():
	## returns an array with playernames
	var result = []
	var players = get_tree().get_root().get_node("Control").players
	for idx in players:
		result.append(players[idx].name)
	return result

func getScore():
	## returns the current score
	return get_tree().get_root().get_node("Control/game").finalScore

func getHighscore(cnt):
	# returns the sorted highscore items
	createFile(HIGHSCORE_PATH)
	var file = File.new()
	file.open_encrypted_with_pass( HIGHSCORE_PATH, file.READ, HIGHSCORE_PW )
	file.open( HIGHSCORE_PATH, file.READ ) #, "code0" )
	var line = ""
	var obj
	var result = []
	# Read jsonl file
	while(not file.eof_reached()):
		line = file.get_line()
		if validate_json(line) == "":
			obj = parse_json(line)
			result.append(obj)
	file.close()
	sortHighscore(result)
	result.resize(cnt) # only the first n elements
	return result
			
func _ready():
	pass
#	putHighscore(5000, ["Foo1", "Baa"])
#	putHighscore(1100, ["Foo2", "Baa"])
#	putHighscore(1120, ["Foo3", "Baa"])
#	print( getHighscore(20) )
#  func save(content):
#
#
#  func load():
#      var file = File.new()
#      file.open("user://save_game.dat", file.READ)
#      var content = file.get_as_text()
#      file.close()
#      return content
