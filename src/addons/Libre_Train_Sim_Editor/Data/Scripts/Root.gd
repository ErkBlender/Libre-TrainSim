tool
extends Node

var currentScenario
var currentTrain
var EasyMode = true
var mobile_version = false



var world ## Reference to world

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func checkAndLoadTranslationsForTrack(trackName): # Searches for translation files with trackName in res://Translations/
	print(trackName.get_file().get_basename())
	var trackTranslations = []
	var dir = Directory.new()
	dir.open("res://Translations")
	dir.list_dir_begin()
	while(true):
		var file = dir.get_next()
		if file == "":
				break
		if file.get_extension() == "translation":
			if file.get_file().begins_with(trackName):
				trackTranslations.append("res://Translations/" + file.get_file())
				print("Track Translation Found " + "res://Translations/" + file.get_file())
	for trackTranslationPath in trackTranslations:
		var trackTranslation = load(trackTranslationPath)
		print(trackTranslation.locale)
		TranslationServer.add_translation(trackTranslation)

func checkAndLoadTranslationsForTrain(trainDirPath): # Searches for translation files wich are located in the same folder as the train.tscn. Gets the full path to train.tscn as input
	print(trainDirPath)
	var trainTranslations = []
	var dir = Directory.new()
	dir.open(trainDirPath)
	dir.list_dir_begin()
	while(true):
		var file = dir.get_next()
		if file == "":
				break
		if file.get_extension() == "translation":
			trainTranslations.append(trainDirPath+"/"+file)
			print("Track Translation Found " + "res://Translations/" + file.get_file())
	for trainTranslationPath in trainTranslations:
		var tainTranslation = load(trainTranslationPath)
		print(tainTranslation.locale)
		TranslationServer.add_translation(tainTranslation)

## foundFiles has to be an dict: {"Array" : []}
func crawlDirectory(directoryPath,foundFiles,fileExtension): 
	var dir = Directory.new()
	if dir.open(directoryPath) != OK: return
	dir.list_dir_begin()
	while(true):
		var file = dir.get_next()
		if file == "": break
		if file.begins_with("."): continue
		if dir.current_is_dir():
			if directoryPath.ends_with("/"):
				crawlDirectory(directoryPath+file, foundFiles, fileExtension)
			else:
				crawlDirectory(directoryPath+"/"+file, foundFiles, fileExtension)
		else:
			if file.get_extension() == fileExtension:
				var exportString 
				if directoryPath.ends_with("/"):
					exportString = directoryPath +file
				else:
					exportString = directoryPath +"/"+file
				foundFiles["Array"].append(exportString)
	dir.list_dir_end()
	
# approaches 'ist' value to 'soll' value in one second  (=smooth transitions from current 'ist' value to 'soll' value)
func clampViaTime(soll : float, ist : float, delta : float):
	ist += (soll-ist)*delta
	return ist

func fix_frame_drop():
	if not jSettings.get_framedrop_fix():
		return
	jEssentials.call_delayed(0.7, self,  "set_fullscreen", [!jSettings.get_fullscreen()])
	jEssentials.call_delayed(0.9, self,  "set_fullscreen", [jSettings.get_fullscreen()])
	
func set_fullscreen(value : bool):
	OS.window_fullscreen = value

func set_low_resolution(value : bool):
	if value:
		if ProjectSettings.get_setting("display/window/stretch/mode") == "viewport":
			return
		ProjectSettings.set_setting("display/window/stretch/mode", "viewport")
		ProjectSettings.set_setting("display/window/stretch/aspect", "keep")
		ProjectSettings.set_setting("display/window/size/width", "1280")
		ProjectSettings.set_setting("display/window/size/height", "720")
		ProjectSettings.save()
	else:
		ProjectSettings.set_setting("display/window/stretch/mode", "disabled")
		ProjectSettings.set_setting("display/window/stretch/aspect", "ignore")
		ProjectSettings.set_setting("display/window/size/width", "800")
		ProjectSettings.set_setting("display/window/size/height", "600")
		ProjectSettings.save()
