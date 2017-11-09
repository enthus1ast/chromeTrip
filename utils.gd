extends Node

var version = 0.1 # general version of this game

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

#func putHighscore(score, team): 
#	# puts a line into the crypted highscore file.
#	var file = File.new()
#	file.open_encrypted_with_pass( "user://highscore.dat", file.READ_WRITE, "code0" )
#	var tup = [score, team]
#	var line = to_json(tup)
#	print("Line:", line)
#	file.store_line(line)
#	file.close()
#
#func getHighscore(cnt):
#	# returns the sorted highscore items
#	var file = File.new()
#	file.open_encrypted_with_pass( "user://highscore.dat", file.READ, "code0" )
#	while(not file.eof_reached()):
#		print(file.get_line())
#	file.close()
#
#func _ready():
#	putHighscore(1000, ["Foo", "Baa"])
#	putHighscore(1100, ["Foo", "Baa"])
#	putHighscore(1120, ["Foo", "Baa"])
#	getHighscore(1)
#  func save(content):
#
#
#  func load():
#      var file = File.new()
#      file.open("user://save_game.dat", file.READ)
#      var content = file.get_as_text()
#      file.close()
#      return content
