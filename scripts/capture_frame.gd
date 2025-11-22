extends Node2D

@onready var background = $Background
@onready var border = $Border
@onready var mask = $Mask
@onready var tile_holder = $Mask/TileHolder


func setup_frame(grid_size: Vector2, tile_pixel_size: int):
	var total_width = grid_size.x * tile_pixel_size
	var total_height = grid_size.y * tile_pixel_size
	var size = Vector2(total_width, total_height)
	
	var offset = -(size/2)
	
	background.size = size
	background.position = offset
	
	border.size = size
	border.position = offset
	
	mask.size = size
	mask.position = offset
	
	tile_holder.position = Vector2.ZERO
	
func add_ghost(ghost):
	tile_holder.add_child(ghost)

func set_valid(is_valid: bool):
	if is_valid:
		border.modulate = Color(0, 1, 1)
		background.modulate = Color(0,0,0,0.5)
		tile_holder.modulate = Color(1, 1, 1)
	else:
		border.modulate = Color(1, 0, 0)
		background.modulate = Color(0.5, 0,0 ,0.5)
		tile_holder.modulate = Color(1, 0.5, 0.5)
