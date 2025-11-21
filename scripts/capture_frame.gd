extends Node2D

@onready var background = $Background
@onready var border = $Border
@onready var tile_holder = $TileHolder

func setup_frame(grid_size: Vector2, tile_pixel_size: int):
	var total_width = grid_size.x * tile_pixel_size
	var total_height = grid_size.y * tile_pixel_size
	var size = Vector2(total_width, total_height)
	
	background.size = size
	background.position = -(size/2)
	
	border.size = size
	border.position = -(size/2)
	
	tile_holder.position = -(size/2)
	
func add_ghost(ghost):
	tile_holder.add_child(ghost)
