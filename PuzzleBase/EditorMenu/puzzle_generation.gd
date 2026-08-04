extends Node2D

@onready var tilemap = $PuzzleBaseLayer
@onready var tilemapSolving = $PuzzleSolvingLayer
@onready var sideLen = $PuzzleMenu/BottomLeft/Buttons/UserSize
#@onready var disable6s = $PuzzleMenu/BottomRight/DisableSixes
#@onready var disable0s = $PuzzleMenu/BottomRight/DisableZeros
@export var tileset: TileSet
var tileDict := {}

'''
@onready var zeroTiles: Array[Array] = [[-1, -1, -1, -1, -1, -1, -1]]
@onready var oneTiles: Array[Array] = [[1, -1, -1, -1, -1, -1],  [-1, 1, -1, -1, -1, -1],  [-1, -1, 1, -1, -1, -1],  [-1, -1, -1, 1, -1, -1],  [-1, -1, -1, -1, 1, -1], [-1, -1, -1, -1, -1, 1]]
@onready var twoTiles: Array[Array] = [[1, 1, -1, -1, -1, -1],  [-1, 1, 1, -1, -1, -1],  [-1, -1, 1, 1, -1, -1],  [-1, -1, -1, 1, 1, -1],  [-1, -1, -1, -1, 1, 1], [1, -1, -1, -1, -1, 1]]
@onready var threeTiles: Array[Array] = [[1, 1, 1, -1, -1, -1],  [-1, 1, 1, 1, -1, -1],  [-1, -1, 1, 1, 1, -1],  [-1, -1, -1, 1, 1, 1],  [1, -1, -1, -1, 1, 1], [1, 1, -1, -1, -1, 1]]
@onready var fourTiles: Array[Array] = [[1, 1, 1, 1, -1, -1],  [-1, 1, 1, 1, 1, -1],  [-1, -1, 1, 1, 1, 1],  [1, -1, -1, 1, 1, 1],  [1, 1, -1, -1, 1, 1], [1, 1, 1, -1, -1, 1], [1, 1, -1, 1, 1, -1], [-1, 1, 1, -1, 1, 1], [1, -1, 1, 1, -1, 1]]
@onready var fiveTiles: Array[Array] = [[1, 1, 1, 1, 1, -1],  [-1, 1, 1, 1, 1, 1],  [1, -1, 1, 1, 1, 1],  [1, 1, -1, 1, 1, 1],  [1, 1, 1, -1, 1, 1], [1, 1, 1, 1, -1, 1]]
@onready var sixTiles: Array[Array] = [[1, 1, 1, 1, 1, 1]]
'''
@onready var zeroTiles: Array[int] =  [ 0]
@onready var oneTiles: Array[int] =   [ 1,  2,  4,  8, 16, 32]
@onready var twoTiles: Array[int] =   [ 3,  6, 12, 24, 48, 33]
@onready var threeTiles: Array[int] = [ 7, 14, 28, 56, 49, 35]
@onready var fourTiles: Array[int] =  [15, 30, 60, 57, 51, 39, 27, 54, 45]
@onready var fiveTiles: Array[int] =  [31, 62, 61, 59, 55, 47]
@onready var sixTiles: Array[int] =   [63]
#@onready var totalTiles: Array[int] = zeroTiles + oneTiles + twoTiles + threeTiles + fourTiles + fiveTiles + sixTiles

# Builds a dictonary that uses source ID or node value as a key for atlas coords.
func buildTileDict():
	# Clear's just in case & sets our layer to the int values of each hex
	tileDict.clear()
	#var layer_name = "IntNodes"
	
	# Takes each id in the tileset & saves its source & data.
	#for source_id in tileset.get_source_count():
		#print(source_id)
	var source = tileset.get_source(0) #originally source_id
		#if source is TileSetAtlasSource:
	for i in range(source.get_tiles_count()):
		var coords = source.get_tile_id(i)
		var data = source.get_tile_data(coords, 0)
		
		# Using the data we save the IntNode values to a dict as the keys to atlas coords.
		if data:
			var id = data.get_custom_data("IntNodes")
			if id != null:
				tileDict[id] = {"coords": coords} #"source_id": source_id,

func coordsContain(cell: Vector3i, value: int):
	return (cell.x == value or cell.y == value or cell.z == value) and (cell.x == -value or cell.y == -value or cell.z == -value)

# Takes an integer representation of a hex & turns it into an array of statuses.
func int2Vals(hex: int): 
	# Uses subtraction to determine the binary value of the int.
	var nodes: Array[int] # (-1 = unfilled, 0 = unknown, 1 = filled)
	var divisor = 32
	for i in range(6, 0, -1):
		if hex >= divisor:
			#print(hex, ' > ', divisor)
			hex = hex-divisor
			nodes.push_front(1)
		else:
			#print(hex, ' < ', divisor)
			nodes.push_front(-1)
		@warning_ignore("integer_division") #for some reason, godot throws a warning for this
		divisor = divisor/2
	return nodes

# Removes all hexagons outside of the bounds.
func setAllowedTiles(allowed: Array):
	var totalTiles: Array[int] = []
	if allowed[0] and !$PuzzleMenu/BottomRight/DisableZeros.button_pressed:
		totalTiles += zeroTiles
	if allowed[1]:
		totalTiles += oneTiles
	if allowed[2]:
		totalTiles += twoTiles
	if allowed[3]:
		totalTiles += threeTiles
	if allowed[4]:
		totalTiles += fourTiles
	if allowed[5]:
		totalTiles += fiveTiles
	if allowed[6] and !$PuzzleMenu/BottomRight/DisableSixes.button_pressed:
		totalTiles += sixTiles
	return totalTiles

# Will return valid Atlas Cords
func placeValidHex(cell: Vector3i, size: int, lowBound: int = 0, highBound: int = 6, restrictions: Array = [0, 0, 0, 0, 0, 0]):
	# Restricts the total tiles we look at to the ones fitting the min  max valid values
	#print(lowBound, ' ', highBound, ' ', restrictions)
	var bound: Array[bool] = [false, false, false, false, false, false, false]
	for i in range(lowBound, highBound+1):
		bound[i] = true
	var totalTiles: Array[int] = setAllowedTiles(bound)
	#print(totalTiles)
	
	# Pulls a random tile from the bounded tiles that we have.
	randomize()
	var randTile = totalTiles[randi() % totalTiles.size()]
	var randTileVals = int2Vals(randTile)
	#print(totalTiles, ' ', randTile, ' ', randTileVals)
	var searching = true
	
	# Picks a random hexagon in the dictonary.
	while searching:
		if totalTiles.size() == 0:
			return false
		randTile = totalTiles[randi() % totalTiles.size()]
		randTileVals = int2Vals(randTile)
		
		# Checks it against the restrictions, if it fails searching is set to false.
		for i in range(6):
			if restrictions[i] and restrictions[i] != randTileVals[i]:
				#print(restrictions[i], ' ', randTileVals)
				searching = false
				totalTiles.erase(randTile)
				break
		#print(totalTiles, ' to try ', randTile)#,randTileVals)
		
		# If it doesn't fail, we place the tile, then check it doesn't create a 1, -1, 1, -1 or -1, 1, -1, 1 pattern.
		if searching:
			#print(int2NodeVals(randTile))
			var tile = tileDict.get(randTile)
			var atlasCoords = tile["coords"]
			tilemap.set_cell(tilemap.cube_to_map(cell), 0, atlasCoords) #(location on map, layer, location in tileset)
			if invalidAdjacency(cell) or cornerInvalid(cell, size, randTile):
				#print(atlasCoords)
				totalTiles.erase(randTile)
				randTile = totalTiles[randi() % totalTiles.size()]
				randTileVals = int2Vals(randTile)
			else:
				searching = false
		else:
			searching = true
			
	#print(randTile, ' at cell ', cell)
	# If it doesn't we return true.
	return true

# Finds the nodes that are already filled in.
func findRestrictions(pos: int, tiledata, restrictions: Array[int] = [0,0,0,0,0,0]):
	# Uses a simple match statement. Somewhat ugly but whatever...
	var value: Array[int] = int2Vals(tiledata.get_custom_data("IntNodes"))
	match pos:
		0:
			if value[4]:
				restrictions[0] = value[4]
			if value[3]:
				restrictions[1] = value[3]
		1:
			if value[5]:
				restrictions[1] = value[5]
			if value[4]:
				restrictions[2] = value[4]
		2:
			if value[0]:
				restrictions[2] = value[0]
			if value[5]:
				restrictions[3] = value[5]
		3:
			if value[1]:
				restrictions[3] = value[1]
			if value[0]:
				restrictions[4] = value[0]
		4:
			if value[2]:
				restrictions[4] = value[2]
			if value[1]:
				restrictions[5] = value[1]
		5:
			if value[3]:
				restrictions[5] = value[3]
			if value[2]:
				restrictions[0] = value[2]
	return restrictions

# Takes the decided node & checks that it doesn't create a 0, 1, 0, 1 pattern
func invalidAdjacency(cell: Vector3i, toCheck: Array[bool] = [true, true, true, true, true, true]) -> bool:
	#print('ENTERED')
	var neighbors = tilemap.cube_neighbors(cell)
	for i in range(6):
		if toCheck[i]:
			var restrictions: Array[int] = [0, 0, 0, 0, 0, 0]
			var nxtNeighbors = tilemap.cube_neighbors(neighbors[i])
			for j in range(6):
				var vectorCoords = tilemap.cube_to_map(nxtNeighbors[j])
				var tiledata = tilemap.get_cell_tile_data(vectorCoords)
				if tiledata:
					restrictions = findRestrictions(j, tiledata, restrictions)
				#print(vectorCoords, restrictions)
			for k in range(6):
				#print(restrictions[k], restrictions[k-1], restrictions[k-2], restrictions[k-3])
				if (restrictions[k] and restrictions[k-1] and restrictions[k] != restrictions[k-1]) and (restrictions[k] == restrictions[k-2] and restrictions[k-1] == restrictions[k-3]):
					#print('EXITED VALID', restrictions)
					return true
	#print('EXITED INVALID')
	return false

func cornerInvalid(cell: Vector3i, size: int, tileVal: int):
	if coordsContain(cell, size):
		if cell == Vector3i(size, -size, 0) and (tileVal == 1 or tileVal == 2 or tileVal == 61 or tileVal == 62):
			return true
		elif cell == Vector3i(size, 0, -size) and (tileVal == 2 or tileVal == 4 or tileVal == 59 or tileVal == 61):
			return true
		elif cell == Vector3i(0, size, -size) and (tileVal == 4 or tileVal == 8 or tileVal == 55 or tileVal == 59):
			return true
		elif cell == Vector3i(-2, 2, 0) and (tileVal == 8 or tileVal == 16 or tileVal == 47 or tileVal == 55):
			return true
		elif cell == Vector3i(-2, 0, 2) and (tileVal == 16 or tileVal == 32 or tileVal == 31 or tileVal == 47):
			return true
		elif cell == Vector3i(0, -2, 2) and (tileVal == 32 or tileVal == 1 or tileVal == 62 or tileVal == 31):
			return true
	return false

func performaceTest(puzzles: int = 10000, cutoff: int = 50):
	var solutions: Array[int] = []
	
	solutions.resize(cutoff+1)
	for x in range(cutoff+1):
		solutions[x] = 0
		
	var filepath = "user://solutionsCnt.txt"
	#var filepath = "user://HughesHex.hex"
	var file = FileAccess.open(filepath, FileAccess.WRITE) 
	for map in range(puzzles):
		tilemap.clear()
		
		# Sets the spiral's size to the user's input or 2 if that's not possible.
		var customSize = 2
		if sideLen.text.is_valid_int():
			customSize = sideLen.text.to_int() - 1
			if customSize < 0:
				customSize = 2
		var spiral = tilemap.cube_spiral(Vector3i(0,0,0), customSize) #returns a list of coords needed to spiral
		#print(spiral)
		
		# Reads each coord & places the hexes.
		for cell in spiral:
			var neighbors = tilemap.cube_neighbors(cell)
			var lowBound = 0
			var highBound = 6
			var restrictions: Array[int] = [0, 0, 0, 0, 0, 0]
			#print(cell, ' has ', neighbors)
			#print(neighbors[0])
			
			# Sets restrictions & bounds.
			for i in range(6):
				var vectorCoords = tilemap.cube_to_map(neighbors[i])
				var tiledata = tilemap.get_cell_tile_data(vectorCoords)
				if tiledata:
					restrictions = findRestrictions(i, tiledata, restrictions)
			for i in restrictions:
				if i > 0:
					lowBound += 1
				if i < 0:
					highBound -= 1
			
			# Finds a hexagon that fits & places it.
			#print(lowBound, ' ', highBound, ' ', restrictions)
			if !placeValidHex(cell, customSize, lowBound, highBound, restrictions):
				$PuzzleMenu/Label.text = "Puzzle Failed"
				$PuzzleMenu/Label.visible = true
		
		var solution = solvePuzzle(spiral)
		print(map)
		if solution > cutoff:
			solution = cutoff
		solutions[solution] += 1
		if false:
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
		
	if file:
		#file.store_string(tiles + '\n')
		for val in range(cutoff+1):
			file.store_string(str(solutions[val]) + '\n')
	file.close()

func _ready() -> void:
	# Builds a dictonary that uses source ID or node value as a key for atlas coords.
	tileset = tilemap.tile_set
	buildTileDict()
	#Note that set_cell works like set_cell(cords in tilemap, id (always 0 as we only have 1 set), cords in the tileset (0,0) = 0, (0,1) = 1
	#performaceTest(10000, 1000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func _on_generate_pressed() -> void:
	# Hide the Failure label & clear the old puzzle.
	$PuzzleMenu/Label.visible = false
	
	# Sets the spiral's size to the user's input or 2 if that's not possible.
	var customSize = 2
	if sideLen.text.is_valid_int():
		customSize = sideLen.text.to_int() - 1
		if customSize < 0:
			customSize = 2
	var spiral = tilemap.cube_spiral(Vector3i(0,0,0), customSize) #returns a list of coords needed to spiral
	#print(spiral)
	
	# Reads each coord & places the hexes.
	var toSolve = true
	while toSolve:
		tilemap.clear()
		for cell in spiral:
			var neighbors = tilemap.cube_neighbors(cell)
			var lowBound = 0
			var highBound = 6
			var restrictions: Array[int] = [0, 0, 0, 0, 0, 0]
			#print(cell, ' has ', neighbors)
			#print(neighbors[0])
			
			# Sets restrictions & bounds.
			for i in range(6):
				var vectorCoords = tilemap.cube_to_map(neighbors[i])
				var tiledata = tilemap.get_cell_tile_data(vectorCoords)
				if tiledata:
					restrictions = findRestrictions(i, tiledata, restrictions)
			for i in restrictions:
				if i > 0:
					lowBound += 1
				if i < 0:
					highBound -= 1
			
			# Finds a hexagon that fits & places it.
			#print(lowBound, ' ', highBound, ' ', restrictions)
			if !placeValidHex(cell, customSize, lowBound, highBound, restrictions):
				$PuzzleMenu/Label.text = "Puzzle Failed"
				toSolve = false
				break
			
		#print("DONE")
		var solutions = solvePuzzle(spiral)
		if solutions == 1:
			#print('VALID')
			$PuzzleMenu/Label.text = str("Satisfactory Puzzle Generated")
			toSolve = false
		else:
			if !$PuzzleMenu/BottomLeft/Buttons/SatisfactoryToggle.button_pressed:
				toSolve = false
				$PuzzleMenu/Label.text = str("Puzzle Generated With ", solutions, " Solutions")
	$PuzzleMenu/Label.visible = true
	
# Solves puzzle to check validity
func solvePuzzle(hexes: Array[Vector3i], pos: int = 0, solutions: int = 0):
	#if solutions > 1:
	#	return solutions
	#print(solutions)
	
	# Checks if we finished yet & if so, adds one to our solutions (our base case).
	if pos >= hexes.size():
		#print("base case reached")
		solutions += 1
		return solutions
		
	# We see the hexagon at current position & its restrictions
	var restrictions: Array[int] = [0, 0, 0, 0, 0, 0]
	var hexPos = tilemap.cube_to_map(hexes[pos]) #regular tilemap (not solving)
	var hexVal = tilemap.get_cell_atlas_coords(hexPos)[1]
	#var tiledata = tilemap.get_cell_tile_data(hexPos)
	var neighbors = tilemapSolving.cube_neighbors(hexes[pos])
	for neighborPos in range(6):
		var vectorCoords = tilemapSolving.cube_to_map(neighbors[neighborPos])
		var neighborTiledata = tilemapSolving.get_cell_tile_data(vectorCoords)
		if neighborTiledata:
			restrictions = findRestrictions(neighborPos, neighborTiledata, restrictions)
	
	# Determines which tileset we will be useing based on the number that we draw
	#var totalTiles: Array[int]
	var tileChoices: int
	match hexVal:
		0:
			tileChoices = 1
			#totalTiles = zeroTiles
		1:
			tileChoices = 6
			#totalTiles = oneTiles
		2:
			tileChoices = 6
			#totalTiles = twoTiles
		3:
			tileChoices = 6
			#totalTiles = threeTiles
		4:
			tileChoices = 9
			#totalTiles = fourTiles
		5:
			tileChoices = 6
			#totalTiles = fiveTiles
		6:
			tileChoices = 1
			#totalTiles = sixTiles
	
	# Sets the current cell to one of the valid hex permutations
	for choice in range(tileChoices):
		var hexAtlas = Vector2i(choice, hexVal)
		#var tileset = tilemap.tile_set
		var source = tileset.get_source(0) as TileSetAtlasSource
		var tile_data = source.get_tile_data(hexAtlas, 0) # 0 = alternative tile
		
		var hexNodes = int2Vals(tile_data.get_custom_data("IntNodes"))
		
		
		#print(Vector2i(choice, hexVal))
		var fits = true
		for i in range(6):
			if restrictions[i] and restrictions[i] != hexNodes[i]:
				#print(restrictions[i], ' ', randTileVals)
				fits = false
				break
				
		if fits:
			pos += 1
			tilemapSolving.set_cell(hexPos, 0, hexAtlas) #(location on map, layer, location in tileset)
			solutions = solvePuzzle(hexes, pos, solutions)
			pos -= 1
	tilemapSolving.set_cell(hexPos) #(location on map, layer, location in tileset)
	return solutions
