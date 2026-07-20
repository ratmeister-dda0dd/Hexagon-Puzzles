extends CanvasLayer

@onready var tilemap = $/root/PuzzleStart/PuzzleBaseLayer

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func saveJSON(filepath: String):
	var tiles := []
	
	for cell in tilemap.get_used_cells():
		var source_id = tilemap.get_cell_source_id(cell)
		
		if source_id == -1:
			continue
		
		var atlas_coords = tilemap.get_cell_atlas_coords(cell) #hypothetically unneeded due to IntNodes, but its a very small file already & makes runtime faster
		#var alternative = tilemap.get_cell_alternative_tile(cell) #these may be useful later but for now I don't need alts
		var source = tilemap.tile_set.get_source(source_id)
		var tile_data = source.get_tile_data(atlas_coords, 0)
		var IntNodes = null
		if tile_data:
			IntNodes = tile_data.get_custom_data("IntNodes") #also unneeded due to atlas_coords, but makes the json more readable
		tiles.append({
			"mapX": cell.x,
			"mapY": cell.y,
			#"source_id": source_id,
			"atlasX": atlas_coords.x,
			"atlasY": atlas_coords.y,
			#"alternative": alternative,
			"IntNodes": IntNodes
		})
	
	var json_data = JSON.stringify(tiles, "\t")
	#print(json_data)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE) 
	if file:
		file.store_string(json_data)
		file.close()

func _on_save_pressed():
	$TopLeft/Buttons.visible = false
	$TopLeft/SaveLoadBG/LoadCont.visible = false
	$TopLeft/SaveLoadBG.visible = true
	$TopLeft/SaveLoadBG/SaveCont.visible = true

func _on_save_slot_1_pressed() -> void:
	saveJSON("user://SaveData/slot1.json")
func _on_save_slot_2_pressed() -> void:
	saveJSON("user://SaveData/slot2.json")
func _on_save_slot_3_pressed() -> void:
	saveJSON("user://SaveData/slot3.json")
func _on_save_slot_4_pressed() -> void:
	saveJSON("user://SaveData/slot4.json")
func _on_save_slot_5_pressed() -> void:
	saveJSON("user://SaveData/slot5.json")


func loadJSON(filepath: String):
	# Reading from the file at /home/daniel/.local/share/godot/app_userdata/
	tilemap.clear()
	if FileAccess.file_exists(filepath):
		var file = FileAccess.open(filepath, FileAccess.READ)
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_ARRAY:
				for tile in data_received:
					tilemap.set_cell(Vector2i(tile["mapX"], tile["mapY"]), 0, Vector2i(tile["atlasX"], tile["atlasY"]))
			else:
				print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
		file.close()

func _on_load_pressed() -> void:
	$TopLeft/Buttons.visible = false
	$TopLeft/SaveLoadBG/SaveCont.visible = false
	$TopLeft/SaveLoadBG.visible = true
	$TopLeft/SaveLoadBG/LoadCont.visible = true

func _on_load_slot_1_pressed() -> void:
	loadJSON("user://SaveData/slot1.json")
func _on_load_slot_2_pressed() -> void:
	loadJSON("user://SaveData/slot2.json")
func _on_load_slot_3_pressed() -> void:
	loadJSON("user://SaveData/slot3.json")
func _on_load_slot_4_pressed() -> void:
	loadJSON("user://SaveData/slot4.json")
func _on_load_slot_5_pressed() -> void:
	loadJSON("user://SaveData/slot5.json")


func _on_back_pressed() -> void:
	$TopLeft/Buttons.visible = true
	$TopLeft/SaveLoadBG.visible = false

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("uid://c4kk82bvm81ni")



func menuOpening(userChoice: int):
	var oneSubmenu = $TopRight/NumberButtons/OneButtons/OneSubButtons
	var twoSubmenu = $TopRight/NumberButtons/TwoButtons/TwoSubButtons
	var threeSubmenu = $TopRight/NumberButtons/ThreeButtons/ThreeSubButtons
	var fourSubmenu = $TopRight/NumberButtons/FourButtons/FourSubButtons
	var fiveSubmenu = $TopRight/NumberButtons/FiveButtons/FiveSubButtons
	var otherSubmenu = $TopRight/NumberButtons/OtherButtons/OtherSubButtons
	if userChoice == 1 and oneSubmenu.visible == false:
		oneSubmenu.visible = true
	else:
		oneSubmenu.visible = false
	if userChoice == 2 and twoSubmenu.visible == false:
		twoSubmenu.visible = true
	else:
		twoSubmenu.visible = false
	if userChoice == 3 and threeSubmenu.visible == false:
		threeSubmenu.visible = true
	else:
		threeSubmenu.visible = false
	if userChoice == 4 and fourSubmenu.visible == false:
		fourSubmenu.visible = true
	else:
		fourSubmenu.visible = false
	if userChoice == 5 and fiveSubmenu.visible == false:
		fiveSubmenu.visible = true
	else:
		fiveSubmenu.visible = false
	if userChoice == 6 and otherSubmenu.visible == false:
		otherSubmenu.visible = true
	else:
		otherSubmenu.visible = false
		
func _on_menu_button_pressed() -> void:
	if $TopRight/NumberButtons.visible:
		menuOpening(0)
		$TopRight/NumberButtons.visible = false
	else:
		$TopRight/NumberButtons.visible = true

func _on_button_1_pressed() -> void:
	menuOpening(1)
func _on_button_2_pressed() -> void:
	menuOpening(2)
func _on_button_3_pressed() -> void:
	menuOpening(3)
func _on_button_4_pressed() -> void:
	menuOpening(4)
func _on_button_5_pressed() -> void:
	menuOpening(5)
func _on_button_other_pressed() -> void:
	menuOpening(6)
