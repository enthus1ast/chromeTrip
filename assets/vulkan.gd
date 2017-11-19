extends Node2D

onready var control = get_tree().get_root().get_node("Control")
onready var animPlayer = get_node("AnimationPlayer")
onready var firePlayer = get_node("fire/firePlayer")
onready var smokeSystem = get_node("risingSmoke/Particles2D")
onready var stonesSystem = get_node("stoneParticles")
onready var spriteOn = get_node("fire")
var game
var cameraNode

var isErrupting = false

var timer = Timer.new()


func errupt():
	firePlayer.play("vulkanFireFlickr")
	animPlayer.play("vulkanErruption")
	isErrupting=true
	cameraNode.quake()
	

func _ready():
	if control.has_node("game"):
		game = control.get_node("game")
		cameraNode = game.get_node("cameraNode")
		animPlayer.connect("animation_finished",self,"_anim_finished")
	elif game==null:
		game = control.get_node("backgroundGame")
	pass
	
func _anim_finished(_anim):
	isErrupting = false
	pass

func _on_VisibilityNotifier2D_screen_exited():
	get_parent().get_parent().isErrupting = false
	queue_free()
	pass # replace with function body
