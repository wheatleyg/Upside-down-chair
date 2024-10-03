extends Panel

@onready var tower = preload("res://Towers/red_bullet_tower.tscn")
var isDraggingTower = false
var tempTower = null

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not isDraggingTower:
			# Start dragging a new tower
			isDraggingTower = true
			tempTower = tower.instantiate()
			add_child(tempTower)
			tempTower.global_position = event.global_position
			tempTower.scale = Vector2(0.32, 0.32)

			# Disable tower's logic during dragging
			_disable_tower_functions(tempTower)

		elif not event.pressed and isDraggingTower:
			# Stop dragging and place the tower
			isDraggingTower = false
			if event.global_position.x >= 2944:
				tempTower.queue_free()
			else:
				var path = get_tree().get_root().get_node("Main/Towers")

				# Remove from current parent before adding to Towers
				tempTower.get_parent().remove_child(tempTower)
				path.add_child(tempTower)  # Now add it to the 'Towers' node

				tempTower.global_position = event.global_position

				# Re-enable tower functions after placement
				_enable_tower_functions(tempTower)

				# Check if the "Area" node exists inside tempTower
				var area_node = tempTower.get_node_or_null("Area")
				if area_node:
					# Ensure it's an Area2D before attempting to disable it
					if area_node is Area2D:
						area_node.hide()
					else:
						print("Node 'Area' is not of type Area2D")
				else:
					print("Area node not found in the tower")
				# Game.Gold -= 10
			tempTower = null

	elif event is InputEventMouseMotion and isDraggingTower:
		# Update the position of the tower while dragging
		tempTower.global_position = event.global_position

	else:
		if tempTower:
			tempTower.queue_free()
			tempTower = null

# Disable the tower's functions (physics and script processing)
func _disable_tower_functions(tower_instance):
	tower_instance.set_physics_process(false)  # Disable physics
	tower_instance.set_process(false)          # Disable regular process

	# Disable specific components if needed, like a Timer or an Area2D node
	var timer = tower_instance.get_node_or_null("Timer")
	if timer:
		timer.stop()

	var area = tower_instance.get_node_or_null("Area")
	if area and area is Area2D:  # Ensure it's an Area2D
		area.set_monitoring(false)  # Disable area detection if applicable
	else:
		print("Area node not found or not an Area2D")

# Enable the tower's functions (re-enable physics and script processing)
func _enable_tower_functions(tower_instance):
	tower_instance.set_physics_process(true)  # Enable physics
	tower_instance.set_process(true)          # Enable regular process

	# Re-enable specific components if needed, like a Timer or an Area2D node
	var timer = tower_instance.get_node_or_null("Timer")
	if timer:
		timer.start()

	var area = tower_instance.get_node_or_null("Area")
	if area and area is Area2D:  # Ensure it's an Area2D
		area.set_monitoring(true)  # Re-enable area detection if applicable
	else:
		print("Area node not found or not an Area2D")
