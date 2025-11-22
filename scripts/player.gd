extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -250.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	check_hazards()
		
func check_hazards():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var hit_pos = collision.get_position() - (collision.get_normal() * 2)
			
			var cell_pos = collider.local_to_map(hit_pos)
			var tile_data = collider.get_cell_tile_data(cell_pos)
			
			if tile_data:
				var is_deadly = tile_data.get_custom_data("is_deadly")
				if is_deadly:
					die()

func die():
	print("OUCH! Restarting")
	get_tree().reload_current_scene()
