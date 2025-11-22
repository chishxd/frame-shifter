extends Node2D


# State tracking variables
var is_active = false
var is_drawing = false
var mouse_start = Vector2.ZERO
var mouse_current = Vector2.ZERO
var is_placing = false
var capture_origin = Vector2.ZERO
var centering_offset = Vector2.ZERO
var rotation_index = 0 #0 is 0deg, 1 is 90, 2 is 180 and 3 is 270

@onready var time_tint = $"../TimeTint"
@onready var tile_map = $"../TileMapLayer"
@onready var frame_scene = preload("res://scenes/capture_frame.tscn")
@onready var ghost_scene = preload("res://scenes/ghost_tile.tscn")
#MUSICA
@onready var sfx_freeze = $SFX_Freeze
@onready var sfx_unfreeze = $SFX_Unfreeze
@onready var sfx_capture = $SFX_Capture
@onready var sfx_paste = $SFX_Paste




func _input(event):
	
	if event is InputEventKey and event.pressed and event.keycode ==  KEY_ESCAPE:
		if is_active:
			cancel_selection()
			return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		toggle_freeze()
		
	if is_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if is_placing:
					if can_place_frame():
						paste_tiles()
					else :
						print("Can't Place Here!`")
				else:
					is_drawing = true
					mouse_start = get_global_mouse_position()
			else:
				if is_drawing:
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
		sfx_freeze.play()
	else:
		print("TIME RESUMED")
		#is_drawing = false
		time_tint.color = Color(1, 1, 1, 1)
		sfx_unfreeze.play()
		cancel_selection()
		
func _draw() -> void:
	if is_active and is_drawing:
		var rect = Rect2(mouse_start, mouse_current - mouse_start)
		
		draw_rect(rect, Color.CYAN, false, 2.0)

func scan_for_tiles():
	rotation_index = 0
	for child in get_children():
		if child.has_method("setup_frame"):
			child.queue_free()
		
	var box = Rect2(mouse_start, mouse_current - mouse_start).abs()
	var start_grid = tile_map.local_to_map(box.position)
	var end_grid = tile_map.local_to_map(box.end)
	
	var width_in_tiles = (end_grid.x - start_grid.x) + 1
	var heigh_in_tiles = (end_grid.y - start_grid.y) + 1
	var grid_dims = Vector2(width_in_tiles, heigh_in_tiles)
	
	var found_smth = false
	
	# SPAWN FRAME
	var current_frame = frame_scene.instantiate()
	add_child(current_frame)
	
	current_frame.setup_frame(grid_dims, 18)
	
	for x in range(start_grid.x, end_grid.x + 1):
		for y in range(start_grid.y, end_grid.y + 1):
			var cell_pos = Vector2i(x, y)
			var source_id = tile_map.get_cell_source_id(cell_pos)
			
			if source_id != -1:
				found_smth = true
				var atlas_coords = tile_map.get_cell_atlas_coords(cell_pos)
				
				var ghost = ghost_scene.instantiate()
				current_frame.add_ghost(ghost)
				
				var local_x = (x - start_grid.x) * 18
				var local_y = (y - start_grid.y) * 18
				ghost.position = Vector2(local_x, local_y)
				
				ghost.texture = tile_map.tile_set.get_source(source_id).texture
				
				var tile_size = 18
				var region = Rect2(atlas_coords * tile_size, Vector2(tile_size,tile_size))
				ghost.region_enabled = true
				ghost.region_rect = region
				
				ghost.set_meta("source_id", source_id)
				ghost.set_meta("atlas_coords", atlas_coords)
	if found_smth:
		print("CAPTURE SUCCESSFUL!")
		sfx_capture.play()
		is_placing = true
	else:
		current_frame.queue_free()
		
func paste_tiles():
	print("Pasting Tiles...")
	
	for frame in get_children():
		if frame.has_method("setup_frame"):
			for ghost in frame.tile_holder.get_children():
				
				var global_pos = ghost.global_position
				var map_pos = tile_map.local_to_map(global_pos)
				var source_id = ghost.get_meta("source_id")
				var atlas_coords = ghost.get_meta("atlas_coords")
				
				tile_map.set_cell(map_pos, source_id, atlas_coords, rotation_index)
		
			frame.queue_free()
	
	sfx_paste.play()
	is_placing = false
	toggle_freeze()
		

func _process(delta):
	if is_placing:
		for child in get_children():
			# Move frame
			if child.has_method("setup_frame"):
				child.global_position = get_global_mouse_position()
		
				#Rotation Stuff
				if Input.is_action_just_pressed("rotate_left"):
					rotate_frame(-1)
				if Input.is_action_just_pressed("rotate_right"):
					rotate_frame(1)
				
				# Check Validity
				if can_place_frame():
					child.set_valid(true)
				else:
					child.set_valid(false)

func rotate_frame(direction):
	rotation_index = (rotation_index + direction) % 4
	
	if rotation_index < 0 : rotation_index = 3
	
	for frame in get_children():
		if frame.has_method("setup_frame"):
			frame.rotation_degrees = rotation_index * 90

func cancel_selection():
	for child in get_children():
		if child.has_method("setup_frame"):
			child.queue_free()
	
	is_placing = false
	is_drawing = false
	rotation_index = 0
	
	queue_redraw()
	print("SELECTION CANCELED")

func can_place_frame():
	for frame in get_children():
		if frame.has_method("setup_frame"):
			for ghost in frame.tile_holder.get_children():
				var offset = Vector2(9,9)
				var rotated_offset = offset.rotated(frame.rotation)
				var center_pos = ghost.global_position + rotated_offset
				var target_map_pos = tile_map.local_to_map(center_pos)
				
				var existing_tile_id = tile_map.get_cell_source_id(target_map_pos)
				
				#Cuz Air returns -1 source ID
				if existing_tile_id != -1:
					return false
	return true
