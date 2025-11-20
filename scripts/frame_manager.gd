extends Node2D


# State tracking variables
var is_active = false
var is_drawing = false
var mouse_start = Vector2.ZERO
var mouse_current = Vector2.ZERO
@onready var time_tint = $"../TimeTint"
@onready var tile_map = $"../TileMapLayer"
@onready var ghost_scene = preload("res://scenes/ghost_tile.tscn")
@onready var ghost_container = $GhostContainer

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F:
		toggle_freeze()
	if is_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_drawing = true
				mouse_start = get_global_mouse_position()
			else:
				is_drawing= false
				queue_redraw()
				scan_for_tiles()
		if event is InputEventMouseMotion and is_drawing:
			mouse_current = get_global_mouse_position()
			queue_redraw()
func toggle_freeze():
	is_active = !is_active
	
	get_tree().paused = is_active
	
	if is_active:
		print("TIME FROZEN")
		time_tint.color = Color(0.4, 0.4, 0.6, 1.0)
	else:
		print("TIME RESUMED")
		is_drawing = false
		time_tint.color = Color(1, 1, 1, 1)
		queue_redraw()
		
func _draw() -> void:
	if is_active and is_drawing:
		var rect = Rect2(mouse_start, mouse_current - mouse_start)
		
		draw_rect(rect, Color.CYAN, false, 2.0)

func scan_for_tiles():
	var box = Rect2(mouse_start, mouse_current - mouse_start).abs()
	
	var start_grid = tile_map.local_to_map(box.position)
	var end_grid = tile_map.local_to_map(box.end)
	
	print("=====SCANNING======")
	print("Box Covers: ", start_grid, "to: ", end_grid)
	
	for x in range(start_grid.x, end_grid.x + 1):
		for y in range(start_grid.y, end_grid.y + 1):
			var cell_pos = Vector2i(x, y)
			
			var source_id = tile_map.get_cell_source_id(cell_pos)
			
			if source_id != -1:
				print("FOUND BLOCK AT: ", cell_pos)
	
