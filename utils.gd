extends Node

var version = 0.1

func computeColor(st):
  # computes rgb froms string
  var commulated=0;
  for ch in st:
    commulated = commulated + ch.to_ascii()[0]
  var communist = commulated%235 + 20
  #  return "rgb("+communist+","+Math.pow(communist,2)%255+","+Math.pow(communist,3)%255+")"
  return Color( 
	"%x" % [communist] +
	"%x" % [int(pow(int(communist),2)) % 255] +
	"%x" % [int(pow(int(communist),3)) % 255] 
#	255
	#128, 128,128,128
#	"d69b9b"
  )
