extends CanvasLayer

@onready var tilemap = $/root/PuzzleStart/PuzzleBaseLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_save_pressed() -> void:
	for tile in tilemap:
		print(tile)
	'''# Writing to the file at /home/daniel/.local/share/godot/app_userdata/Summer Hex Puzzles
	var file = FileAccess.open("user://save.txt", FileAccess.WRITE)
	if file:
		file.store_string("SAVED!!!")
		file.close()
	else:
		print("Error: ", FileAccess.get_open_error())'''

func _on_load_pressed() -> void:
	# Reading from the file at /home/daniel/.local/share/godot/app_userdata/Summer Hex Puzzles
	if FileAccess.file_exists("user://save.txt"):
		var file = FileAccess.open("user://save.txt", FileAccess.READ)
		var content = file.get_as_text()
		print(content)
		file.close()

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("uid://c4kk82bvm81ni")
