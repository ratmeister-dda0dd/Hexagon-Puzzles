extends CanvasLayer

@onready var tilemap = $/root/PuzzleEditor/PuzzleBaseLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var importMenu = $TopLeft/ImportPanel/ImportCont/FileDropdown
	importMenu.get_popup().max_size.y = 240
	
	var dir = DirAccess.open("user://SaveData")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if !dir.current_is_dir() and filename.ends_with(".json"):
				importMenu.add_item(filename.get_basename())
			filename = dir.get_next()
		dir.list_dir_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass


func importJSON(filename: String):
	# Reading from the file at /home/daniel/.local/share/godot/app_userdata/
	var filepath = "user://SaveData/" + filename + ".json"
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

func _on_open_import_pressed() -> void:
	$TopLeft/Buttons.visible = false
	$TopLeft/ImportPanel.visible = true
	$TopLeft/ExportPanel.visible = false

func _on_import_pressed() -> void:
	var importMenu = $TopLeft/ImportPanel/ImportCont/FileDropdown
	var filename = importMenu.get_item_text(importMenu.selected)
	importJSON(filename)

func exportHughes(filename: String) -> void:
	var filepath = "user://SaveDataHughes"

	if not DirAccess.dir_exists_absolute(filepath):
		var error = DirAccess.make_dir_recursive_absolute(filepath)
		if error != OK:
			print("Failed to create directory: ", error)
		else:
			print("Directory created!")
	else:
		print("Directory already exists.")
	
	filepath += '/' + filename + ".hex"
	var tiles = ""
	
	var size = 3
	for ring in range(size):
		var hexes = tilemap.cube_ring(Vector3i(0, 0, 0), ring)
		for cell in hexes:
			cell = tilemap.cube_to_map(cell)
			var source_id = tilemap.get_cell_source_id(cell)
			
			if source_id == -1:
				continue
			
			var atlas_coords = tilemap.get_cell_atlas_coords(cell) #hypothetically unneeded due to IntNodes, but its a very small file already & makes runtime faster
			#var source = tilemap.tile_set.get_source(source_id)
			tiles = (tiles + str(atlas_coords.y) + ' ')
	#print(tiles)
	var file = FileAccess.open(filepath, FileAccess.WRITE) 
	if file:
		file.store_string(tiles)
		file.close()

func exportJSON(filename: String) -> void:
	var filepath = "user://SaveData"

	if not DirAccess.dir_exists_absolute(filepath):
		var error = DirAccess.make_dir_recursive_absolute(filepath)
		if error != OK:
			print("Failed to create directory: ", error)
	
	filepath += '/' + filename + ".json"
	print(filepath)
	
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
	$TopLeft/ImportPanel/ImportCont/FileDropdown.add_item(filename)

func _on_open_export_pressed() -> void:
	$TopLeft/Buttons.visible = false
	$TopLeft/ImportPanel.visible = false
	$TopLeft/ExportPanel.visible = true

func _on_export_pressed() -> void:
	var filename = $TopLeft/ExportPanel/ExportCont/ExportFilename.text
	print(filename)
	if filename == "":
		pass
	else:
		exportJSON(filename)


func _on_back_pressed() -> void:
	$TopLeft/Buttons.visible = true
	$TopLeft/ImportPanel.visible = false
	$TopLeft/ExportPanel.visible = false

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
