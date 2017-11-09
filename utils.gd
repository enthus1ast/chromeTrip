extends Node

var version = 0.1 # general version of this game

func computeColor(st):
  # computes "classic" rgb colors from string
  var commulated=0;
  for ch in st:
    commulated = commulated + ch.to_ascii()[0]
  var communist = commulated%235 + 20
  return Color( 
    ("%x" % [communist]).pad_zeros(2) +
    ("%x" % [int(pow(int(communist),2)) % 255]).pad_zeros(2) +
    ("%x" % [int(pow(int(communist),3)) % 255]).pad_zeros(2)
  )
