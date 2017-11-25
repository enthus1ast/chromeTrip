extends Control

signal mute
signal musicVolume
signal effectVolume

onready var mute = get_node("Panel/GridContainer/VMute")
onready var effects = get_node("Panel/GridContainer/VEffects")
onready var music = get_node("Panel/GridContainer/VMusic")
onready var fullscreen = get_node("Panel/GridContainer/VFullscreen")
var first = true

func _ready():
	## Load settings from config file
	mute.pressed = utils.config.get_value("audio", "mute")
	effects.value = utils.config.get_value("audio", "effects")
	music.value = utils.config.get_value("audio", "music")
	if music.value<=-24:
		utils.toggleMuteChannel("Music",true)
	else:
		utils.toggleMuteChannel("Music",false)
	fullscreen.pressed = utils.config.get_value("general", "fullscreen")
	
func _on_VMute_toggled( pressed ):
	print(pressed)
	utils.config.set_value("audio", "mute", pressed)
	utils.config.save(utils.CONFIG_PATH)
	utils.muteMaster(pressed)
	emit_signal("mute", pressed)
	
func _on_VEffects_value_changed( value ):
	print(value)
	utils.config.set_value("audio", "effects", value)
	utils.config.save(utils.CONFIG_PATH)
	utils.setLoudness("Effects", value)
	if not first:
		get_node("Panel/GridContainer/KEffects/AudioStreamPlayer").play()
	else: first = false
#	emit_signal("effectVolume", value)

func _on_VMusic_value_changed( value ):
	print(value)
	utils.config.set_value("audio", "music", value)
	utils.config.save(utils.CONFIG_PATH)
	utils.setLoudness("Music", value)
	if music.value<=-24:
		utils.toggleMuteChannel("Music",true)
	else:
		utils.toggleMuteChannel("Music",false)
#	emit_signal("musicVolume", value)

func _on_Back_pressed():
	self.hide()
	
func _on_VFullscreen_toggled( pressed ):
	utils.config.set_value("general", "fullscreen", pressed)
	utils.config.save(utils.CONFIG_PATH)	
	OS.set_window_fullscreen(pressed)
