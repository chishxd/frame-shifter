extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("win_game")

func win_game():
	print("YOU WIN")
	get_tree().paused = true
	
	var dialog = AcceptDialog.new()
	dialog.title = "LEVEL COMPLETE"
	dialog.dialog_text = "You are now a frameshifter!\nThanks for playing <3"
	dialog.confirmed.connect(func(): get_tree().quit())
	
	add_child(dialog)
	dialog.popup_centered()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
