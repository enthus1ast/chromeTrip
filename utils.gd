extends Node

var version = 0.1 # general version of this game

func pad2(st):
	if st.length() < 2:
		return "0" + st
	else:
		return st

func computeColor(st):
  # computes "classic" rgb colors from string
  print(st)
  var commulated=0;
  for ch in st:
    commulated = commulated + ch.to_ascii()[0]
  var communist = commulated%235 + 20

  var co = Color( 
    pad2(("%x" % [communist])) +
    pad2(("%x" % [int(pow(int(communist),2)) % 255])) +
    pad2(("%x" % [int(pow(int(communist),3)) % 255])) #+ 
#	"FF"
  )

  
  print( ("%x" % [communist]).pad_zeros(2) )
  print( ("%x" % [int(pow(int(communist),2)) % 255]).pad_zeros(2) )
  print( ("%x" % [int(pow(int(communist),3)) % 255]).pad_zeros(2) )

  print ( 
    ("%x:" % [communist]).pad_zeros(2) +
    ("%x:" % [int(pow(int(communist),2)) % 255]).pad_zeros(2) +
    ("%x:" % [int(pow(int(communist),3)) % 255]).pad_zeros(2)
  )  


  print(co.to_html())
  print(co)

  return co
