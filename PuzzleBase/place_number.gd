extends VBoxContainer

@onready var tilemap = $/root/PuzzleStart/PuzzleBaseLayer
@onready var menuButton = $/root/PuzzleStart/PuzzleMenu/TopRight/Menu/MenuButton

signal mouse_clicked

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		mouse_clicked.emit()
		
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(5.0).timeout
	var mouse = tilemap.get_global_mouse_position()
	print(mouse)

func placeTile(atlasCoords: Vector2i = Vector2i(0,0)):
	$OneButtons/OneSubButtons.visible = false
	$TwoButtons/TwoSubButtons.visible = false
	$ThreeButtons/ThreeSubButtons.visible = false
	$FourButtons/FourSubButtons.visible = false
	$FiveButtons/FiveSubButtons.visible = false
	$OtherButtons/OtherSubButtons.visible = false
	self.visible = false
	await mouse_clicked
	var mouse = tilemap.get_global_mouse_position()
	if mouse[0] < 815 and mouse[1] > -390:
		var cell = tilemap.local_to_map(tilemap.to_local(mouse))
		tilemap.set_cell(cell, 0, atlasCoords) 


# These are built like room numbers, button 11 is more like button 1-1
func _on_button_11_pressed() -> void:
	placeTile(Vector2i(0, 1))
func _on_button_12_pressed() -> void:
	placeTile(Vector2i(1, 1))
func _on_button_13_pressed() -> void:
	placeTile(Vector2i(2, 1))
func _on_button_14_pressed() -> void:
	placeTile(Vector2i(3, 1))
func _on_button_15_pressed() -> void:
	placeTile(Vector2i(4, 1))
func _on_button_16_pressed() -> void:
	placeTile(Vector2i(5, 1))


func _on_button_21_pressed() -> void:
	placeTile(Vector2i(0, 2))
func _on_button_22_pressed() -> void:
	placeTile(Vector2i(1, 2))
func _on_button_23_pressed() -> void:
	placeTile(Vector2i(2, 2))
func _on_button_24_pressed() -> void:
	placeTile(Vector2i(3, 2))
func _on_button_25_pressed() -> void:
	placeTile(Vector2i(4, 2))
func _on_button_26_script_changed() -> void:
	placeTile(Vector2i(5, 2))


func _on_button_31_pressed() -> void:
	placeTile(Vector2i(0, 3))
func _on_button_32_pressed() -> void:
	placeTile(Vector2i(1, 3))
func _on_button_33_pressed() -> void:
	placeTile(Vector2i(2, 3))
func _on_button_34_pressed() -> void:
	placeTile(Vector2i(3, 3))
func _on_button_35_pressed() -> void:
	placeTile(Vector2i(4, 3))
func _on_button_36_pressed() -> void:
	placeTile(Vector2i(5, 3))

func _on_button_41_pressed() -> void:
	placeTile(Vector2i(0, 4))
func _on_button_42_pressed() -> void:
	placeTile(Vector2i(1, 4))
func _on_button_43_pressed() -> void:
	placeTile(Vector2i(2, 4))
func _on_button_44_pressed() -> void:
	placeTile(Vector2i(3, 4))
func _on_button_45_pressed() -> void:
	placeTile(Vector2i(4, 4))
func _on_button_46_pressed() -> void:
	placeTile(Vector2i(5, 4))
func _on_button_47_pressed() -> void:
	placeTile(Vector2i(6, 4))
func _on_button_48_pressed() -> void:
	placeTile(Vector2i(7, 4))
func _on_button_49_pressed() -> void:
	placeTile(Vector2i(8, 4))
	

func _on_button_51_pressed() -> void:
	placeTile(Vector2i(0, 5))
func _on_button_52_pressed() -> void:
	placeTile(Vector2i(1, 5))
func _on_button_53_pressed() -> void:
	placeTile(Vector2i(2, 5))
func _on_button_54_pressed() -> void:
	placeTile(Vector2i(3, 5))
func _on_button_55_pressed() -> void:
	placeTile(Vector2i(4, 5))
func _on_button_56_pressed() -> void:
	placeTile(Vector2i(5, 5))


func _on_button_01_pressed() -> void:
	placeTile(Vector2i(0, 0))
func _on_button_61_pressed() -> void:
	placeTile(Vector2i(0, 6))
func _on_button_hole_pressed() -> void:
	placeTile(Vector2i(-1, -1))
func _on_button_null_pressed() -> void:
	placeTile(Vector2i(8, 1))
