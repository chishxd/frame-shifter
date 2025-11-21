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
