extends Control

var total_points_counter: Label

# Called when the nˆode enters the scene tree for the first time.
func _ready() -> void:
	# Add more icons as needed

	adjust_background_and_bottom_panel_mouse_filter()

	setup_icon("GameIcon", "Match-3: Earn points")
	setup_icon("MarketIcon", "Biomarket: Trade points for chests")
	print("MarketIcon setup completed")

	# Add this line to check if the MarketIcon is actually present and clickable
	var market_icon = get_node_or_null("MarketIcon")
	if market_icon:
		market_icon.connect("gui_input", Callable(self, "_on_market_icon_input"))
		print("Direct gui_input connection added to MarketIcon")
	else:
		print("Error: MarketIcon node not found")

	print("Scene tree structure:")
	print_scene_tree(self, 0)
	
	var giveaway_button = get_node_or_null("GiveawayButton")
	if giveaway_button:
		giveaway_button.connect("pressed", Callable(self, "load_giveaway_timing"))
		print("GiveawayButton connected successfully")
	else:
		print("Error: GiveawayButton not found")

	total_points_counter = $HUDIcon/Algae/TotalPointsCounter
	if total_points_counter:
		print("TotalPointsCounter found at path: ", total_points_counter.get_path())
		update_points_display()
	else:
		print("Error: TotalPointsCounter not found in the HUDIcon/Algae")
	print_all_mouse_filters()
	# We can remove this part since we're using TotalPointsCounter now
	# points_label = Label.new()
	# points_label.text = "Total Points: " + str(Global.get_total_points())
	# points_label.set_position(Vector2(10, 10))  # Adjust position as needed
	# add_child(points_label)

	print_mouse_filter_status()

	check_icon_visibility("MarketIcon")
	check_icon_visibility("GameIcon")

	print_z_index_status()

	print_icon_properties("GameIcon")
	print_icon_properties("MarketIcon")

	check_icon_in_viewport("MarketIcon")

	print_icon_transform("MarketIcon")

	add_debug_rect("MarketIcon")

	print_all_mouse_filters()

func setup_icon(icon_name: String, tooltip_text: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		icon.tooltip_text = tooltip_text
		icon.mouse_filter = Control.MOUSE_FILTER_STOP  # This should already be set, but let's make sure
		icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		icon.set_process_input(true)
		icon.connect("gui_input", Callable(self, "_on_icon_input").bind(icon_name))
		icon.set_z_index(3)  # Increase z-index even more to ensure it's above everything
		icon.visible = true
		icon.modulate.a = 1.0  # Ensure full opacity
		icon.set_process_input(true)
		icon.set_process_unhandled_input(true)
		print(icon_name, " connected successfully, mouse_filter: ", icon.mouse_filter)
		print(icon_name, " rect: ", icon.get_global_rect())
		print(icon_name, " z_index: ", icon.z_index)
	else:
		print("Error: ", icon_name, " node not found")

func _on_icon_input(event, icon_name: String):
	print("Icon input received for: ", icon_name, ", Event type: ", event.get_class())
	if event is InputEventMouseButton:
		print("Mouse button event: ", event.button_index, ", Pressed: ", event.pressed)
		print("Global mouse position: ", get_global_mouse_position())
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(icon_name, " clicked!")
		match icon_name:
			"GameIcon":
				load_game()
			"MarketIcon":
				print("Attempting to load biomarket")
				load_biomarket()
			_:
				print("Unhandled icon name: ", icon_name)

func load_game():
	Global.reset_cumulative_points()
	Global.load_level(1)  # Start from level 1

func load_biomarket():
	var biomarket_path = "res://Scenes/biomarket_inside.tscn"
	print("Checking biomarket path: ", biomarket_path)
	if ResourceLoader.exists(biomarket_path):
		print("Biomarket scene found, loading...")
		get_tree().change_scene_to_file(biomarket_path)
	else:
		print("Error: biomarket_inside.tscn not found at ", biomarket_path)
		# List directory contents for debugging
		var dir = DirAccess.open("res://Scenes")
		if dir:
			print("Contents of res://Scenes:")
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				print("  ", file_name)
				file_name = dir.get_next()
		else:
			print("Unable to access res://Scenes directory")

# Modify this function to ensure it's called when the scene becomes active
func _enter_tree():
	update_points_display()
	update_resource_counters()

# Modify this function to print debug information
func update_points_display():
	var total_points = Global.get_total_points()
	
	if total_points_counter:
		total_points_counter.text = str(total_points)
		print("Updated TotalPointsCounter. Total points: ", total_points)
	else:
		print("Error: TotalPointsCounter is null")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_click_pos = get_global_mouse_position()
		print("Unhandled click at global position: ", global_click_pos)
		var market_icon = get_node_or_null("MarketIcon")
		if market_icon:
			var icon_rect = market_icon.get_global_rect()
			print("MarketIcon rect: ", icon_rect)
			print("Click inside MarketIcon: ", icon_rect.has_point(global_click_pos))
			print("Distance to MarketIcon top-left: ", global_click_pos.distance_to(icon_rect.position))
			if icon_rect.has_point(global_click_pos):
				print("Click was within MarketIcon bounds")
				_on_icon_input(event, "MarketIcon")
			else:
				print("Click was outside MarketIcon bounds")
		else:
			print("MarketIcon not found")

func print_scene_tree(node: Node, indent: int = 0):
	print("  ".repeat(indent) + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)

func adjust_background_and_bottom_panel_mouse_filter():
	var nodes_to_adjust = ["Background", "BottomPanel"]
	for node_name in nodes_to_adjust:
		var node = get_node_or_null(node_name)
		if node:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Change this to IGNORE
			print(node_name, " mouse_filter set to MOUSE_FILTER_IGNORE")
		else:
			print(node_name, " not found")

func print_mouse_filter_status():
	var nodes_to_check = ["BottomPanel", "MarketIcon", "GameIcon"]
	for node_name in nodes_to_check:
		var node = get_node_or_null(node_name)
		if node:
			print(node_name, " mouse_filter: ", node.mouse_filter)
		else:
			print(node_name, " not found")

func check_icon_visibility(icon_name: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		var icon_rect = icon.get_global_rect()
		print(icon_name, " global rect: ", icon_rect)
		for child in get_children():
			if child != icon and child is Control:
				var child_rect = child.get_global_rect()
				if child_rect.intersects(icon_rect):
					print(icon_name, " is intersecting with ", child.name)
					if child.mouse_filter != Control.MOUSE_FILTER_IGNORE:
						print("Warning: ", child.name, " may be blocking ", icon_name)
	else:
		print("Error: ", icon_name, " not found")

func print_z_index_status():
	var nodes_to_check = ["Background", "BottomPanel", "MarketIcon", "GameIcon"]
	for node_name in nodes_to_check:
		var node = get_node_or_null(node_name)
		if node:
			print(node_name, " z_index: ", node.z_index)
		else:
			print(node_name, " not found")

func print_icon_properties(icon_name: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		print(icon_name, " visible: ", icon.visible)
		print(icon_name, " modulate: ", icon.modulate)
		print(icon_name, " position: ", icon.position)
		print(icon_name, " size: ", icon.size)
	else:
		print("Error: ", icon_name, " not found")

func check_icon_in_viewport(icon_name: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		var viewport_rect = get_viewport_rect()
		var icon_rect = icon.get_global_rect()
		if viewport_rect.intersects(icon_rect):
			print(icon_name, " is within the viewport")
		else:
			print(icon_name, " is outside the viewport")
			print("Viewport size: ", viewport_rect.size)
			print("Icon position: ", icon_rect.position)
	else:
		print("Error: ", icon_name, " not found")
		
func update_resource_counters():
	var silica_counter = $HUDIcon/Silica/SilicaPointsCounter
	var metal_counter = $HUDIcon/Metal/MetalPointsCounter
	var crystal_counter = $HUDIcon/Crystal/CrystalPointsCounter

	if silica_counter:
		silica_counter.text = str(Global.get_resource_count("Silica"))
	if metal_counter:
		metal_counter.text = str(Global.get_resource_count("Metal"))
	if crystal_counter:
		crystal_counter.text = str(Global.get_resource_count("Crystal"))

func print_icon_transform(icon_name: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		print(icon_name, " global position: ", icon.get_global_position())
		print(icon_name, " global rect: ", icon.get_global_rect())
		var parent = icon.get_parent()
		while parent:
			if parent is Control:
				print(parent.name, " global position: ", parent.get_global_position())
				print(parent.name, " global rect: ", parent.get_global_rect())
			else:
				print(parent.name, " (not a Control node)")
			parent = parent.get_parent()
	else:
		print("Error: ", icon_name, " not found")

func add_debug_rect(icon_name: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		var debug_rect = ColorRect.new()
		debug_rect.size = icon.size
		debug_rect.position = icon.position
		debug_rect.color = Color(1, 0, 0, 0.5)  # Semi-transparent red
		debug_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		debug_rect.connect("gui_input", Callable(self, "_on_debug_rect_input").bind(icon_name))
		add_child(debug_rect)
		print("Added clickable debug rect for ", icon_name)
	else:
		print("Error: ", icon_name, " not found")
		
func load_giveaway_timing():
	var giveaway_timing_path = "res://Scenes/GiveAwayTiming.tscn"
	if ResourceLoader.exists(giveaway_timing_path):
		print("Loading GiveawayTiming scene")
		get_tree().change_scene_to_file(giveaway_timing_path)
	else:
		print("Error: GiveAwayTiming.tscn not found at ", giveaway_timing_path)

func _on_market_icon_input(event):
	print("Direct input received on MarketIcon: ", event.get_class())
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("MarketIcon clicked directly!")
		load_biomarket()

func print_all_mouse_filters():
	var nodes_to_check = ["Background", "BottomPanel", "MarketIcon", "GameIcon", "CharacterIcon", "HUDIcon"]
	for node_name in nodes_to_check:
		var node = get_node_or_null(node_name)
		if node:
			print(node_name, " mouse_filter: ", node.mouse_filter)
		else:
			print(node_name, " not found")

func _on_debug_rect_input(event, icon_name: String):
	print("Debug rect input for ", icon_name, ": ", event.get_class())
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Debug rect clicked for ", icon_name)
		_on_icon_input(event, icon_name)


func _on_start_button_pressed() -> void:
	var game_window_path = "res://Scenes/game_window.tscn"
	if ResourceLoader.exists(game_window_path):
		print("Loading game scene")
		get_tree().change_scene_to_file(game_window_path)
	else:
		print("Error: game_window.tscn not found at ", game_window_path)


func _on_giveaway_button_pressed() -> void:
	load_giveaway_timing()
