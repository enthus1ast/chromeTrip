extends Control

export(int, 0, 100, 1) var amount = 100 setget set_amount

onready var f1 = get_node("HBoxContainer/Fleisch1")
onready var f2 = get_node("HBoxContainer/Fleisch2")
onready var f3 = get_node("HBoxContainer/Fleisch3")
onready var f4 = get_node("HBoxContainer/Fleisch4")
onready var f5 = get_node("HBoxContainer/Fleisch5")
onready var animation = get_node("AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_amount(val): 
	if f1 == null: return
	if val < 20:
		if animation.get_current_animation() != "blink":
			animation.play("blink")
	else:
		animation.play("normal")
	if val <= 0:
		f1.hide()
		f2.hide()
		f3.hide()
		f4.hide()
		f5.hide()		
	elif val > 0 and val < 20:
		f1.show()
		f2.hide()
		f3.hide()
		f4.hide()
		f5.hide()
	elif val >= 20 and val < 40:
		f1.show()
		f2.show()
		f3.hide()
		f4.hide()
		f5.hide()
	elif val >= 40 and val < 60:
		f1.show()
		f2.show()
		f3.show()
		f4.hide()
		f5.hide()
	elif val >= 60 and val < 80:
		f1.show()
		f2.show()
		f3.show()
		f4.show()
		f5.hide()
	elif val >= 80:
		f1.show()
		f2.show()
		f3.show()
		f4.show()
		f5.show()