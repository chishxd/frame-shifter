extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/StartBtn.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitBtn.pressed.connect(_on_quit_pressed)
	

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
