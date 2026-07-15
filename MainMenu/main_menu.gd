extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("uid://bswo25s2ifgjx")


func _on_fun_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	$MenuContainer/MainButtons.visible = false
	$MenuContainer/CreditsMenu.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_return_pressed() -> void:
	$MenuContainer/CreditsMenu.visible = false
	$MenuContainer/MainButtons.visible = true
