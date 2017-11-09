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
