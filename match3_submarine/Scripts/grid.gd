extends Node2D

enum GameState { WAIT, MOVE}
var state

#Grid initialization
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var y_offset: int
@export var empty_spaces : PackedVector2Array
@export var piece_value: int
@onready var grid_background: TileMapLayer = get_node("../GridBackground")

var possible_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

var all_pieces = []
var current_matches = []

var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false

const BLUE_GOAL = 10
var blue_pieces_cleared = 0
var goal_counter_box: VBoxContainer

# Add these new variables near the top of the script
const MOVE_LIMIT = 15
var moves_left = MOVE_LIMIT
var move_counter_label: Label
var wallet_address_label: Label
var score_label: Label
var score_bar: TextureProgressBar
var streak = 1
var max_score = 500

# Add this variable at the top of the script
var current_game_score: int = 0

var bomb_piece = preload("res://Scenes/bomb_piece.tscn")
var PopupScene = preload("res://Scenes/WinPopup.tscn")

func _ready():
	state = GameState.MOVE
	var back_button = $BackButton
	if back_button:
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	randomize()
	all_pieces = make_2D_array()
	center_grid()  # Call this before spawning pieces
	create_grid_background()

	spawn_pieces()
	
	# Get reference to the GoalCounterBox node
	goal_counter_box = get_node("../MarginGoalCounter/PanelGoalCounter/GoalCounterBox")
	update_blue_pieces_counter()

	# Add this line to get the reference to the MoveCounterLabel
	move_counter_label = get_node("../MarginMoveCounter/PanelMoveCounter/MoveContainer/MoveCounterLabel")
	update_move_counter()
	
	# Get reference to the WalletAddressLabel
	wallet_address_label = get_node("../WalletContainer/WalletAddressLabel")
	update_wallet_address()
	
	score_label = get_node("../MarginTotalScore/PanelScoreCounter/ScoreContainer/ScoreValueLabel")
	if score_label:
		score_label.text = "0"  # Initialize the score to 0
	else:
		print("Error: ScoreLabel not found")
		
	score_bar = get_node("../MarginTotalScore/PanelScoreCounter/ScoreContainer/ScoreProgressBar")	
	if score_bar:
		score_bar.max_value = max_score
		score_bar.value = 0  # Initialize the progress bar to 0
	else:
		print("Error: ScoreProgressBar not found")

	# Check UI elements
	wallet_address_label = get_node("../WalletContainer/WalletAddressLabel")
	print("Wallet address label found: ", wallet_address_label != null)
	
	score_label = get_node("../MarginTotalScore/PanelScoreCounter/ScoreContainer/ScoreValueLabel")
	print("Score label found: ", score_label != null)
	
	score_bar = get_node("../MarginTotalScore/PanelScoreCounter/ScoreContainer/ScoreProgressBar")
	print("Score bar found: ", score_bar != null)

	# Initialize the current game score to 0
	current_game_score = 0
	update_score_display()

# New function to center the grid
func center_grid():
	var screen_size = get_viewport_rect().size
	var grid_width = width * offset
	var grid_height = height * offset
	x_start = (screen_size.x - grid_width) / 2
	y_start = screen_size.y - (screen_size.y - grid_height) / 2

func create_grid_background():
	if grid_background:
		for i in width:
			for j in height:
				if not restricted_movement(Vector2(i, j)):
					grid_background.set_cell(Vector2i(i, j), 0, Vector2i(0, 0))
	else:
		print("Error: GridBackground node not found")


func restricted_movement(place):
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true
	return false
	
# Update this function
func update_blue_pieces_counter():
	if goal_counter_box:
		var pieces_left = max(0, BLUE_GOAL - blue_pieces_cleared)  # Ensure it doesn't go negative
		goal_counter_box.get_node("CounterLabel").text = "x " + str(pieces_left)

func make_2D_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
			
# Spawn pieces and ensure no match-at-start
func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_movement(Vector2(i,j)):
				all_pieces[i][j] = create_random_piece(i, j)
# Helper function to create a random piece
func create_random_piece(column, row):
	var rand = floor(randi_range(0, possible_pieces.size() - 1))
	var piece = possible_pieces[rand].instantiate()
	var loops = 0
	while match_at(column, row, piece.color) and loops < 100:
		rand = floor(randi_range(0, possible_pieces.size() - 1))
		loops += 1
		piece = possible_pieces[rand].instantiate()
	add_child(piece)
	piece.position = grid_to_pixel(column,row + y_offset)
	piece.move(grid_to_pixel(column,row))
	return piece

# Match check function
func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color and all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color and all_pieces[i][j - 2].color == color:
				return true
	return false
		
# Conversion functions between grid and pixel
func grid_to_pixel(column, row):
	return Vector2(x_start + offset * column, y_start - offset * row)

func pixel_to_grid(pixel_x, pixel_y):
	return Vector2(round((pixel_x - x_start) / offset), round((pixel_y - y_start) / -offset))

# Check if the position is within grid bounds
func is_in_grid(grid_position):
	return grid_position.x >= 0 and grid_position.x < width and grid_position.y >= 0 and grid_position.y < height

# Handle touch input
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if controlling:
			controlling = false		
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)
			
# Swap pieces and store information for rollback
func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null and other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction)
		state = GameState.WAIT
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		
		if first_piece.is_bomb or other_piece.is_bomb:
			print("DEBUG: Bomb involved in swap")
			if first_piece.is_bomb:
				activate_bomb(column + direction.x, row + direction.y)
			if other_piece.is_bomb:
				activate_bomb(column, row)
		
		if not move_checked:
			find_matches()
			moves_left -= 1
			update_move_counter()
			check_game_over()

func check_game_over():
	if moves_left <= 0:
		Global.add_points(current_game_score)  # Add the current game score to the total
		show_game_over_screen()
	elif blue_pieces_cleared >= BLUE_GOAL:
		Global.add_points(current_game_score)  # Add the current game score to the total
		show_win_popup()
		
# Store information for swap back
func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	
# Swap back the pieces if no match is found
func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)	
	state = GameState.MOVE
	move_checked = false
	moves_left += 1  # Refund the move if it didn't result in a match
	update_move_counter()
	
# Determine which direction to swap
func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
			
# Find matches on the grid
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].is_bomb:
					check_bomb_explosion(i, j)
				else:
					check_match(i, j)
	get_parent().get_node("destroy_timer").start()

# Helper function to check for matches in a specific position
func check_match(i, j):
	if all_pieces[i][j] == null or all_pieces[i][j].is_bomb:
		return

	var current_color = all_pieces[i][j].color
	var horizontal_matches = 1
	var vertical_matches = 1
   
	# Check horizontal matches
	for k in range(1, 3):
		if i + k < width and all_pieces[i + k][j] != null and all_pieces[i + k][j].color == current_color:
			horizontal_matches += 1
		else:
			break
   
	# Check vertical matches
	for k in range(1, 3):
		if j + k < height and all_pieces[i][j + k] != null and all_pieces[i][j + k].color == current_color:
			vertical_matches += 1
		else:
			break
   
	if horizontal_matches >= 3:
		for k in range(i, i + horizontal_matches):
			if k >= 0 and k < width:
				mark_as_matched(k, j)
				add_to_array(Vector2(k, j))
		print("Horizontal match found: %d pieces" % horizontal_matches)
	elif vertical_matches >= 3:
		for k in range(j, j + vertical_matches):
			if k >= 0 and k < height:
				mark_as_matched(i, k)
				add_to_array(Vector2(i, k))
		print("Vertical match found: %d pieces" % vertical_matches)

# New function to create a bomb
func create_bomb(i, j):
	if all_pieces[i][j] != null:
		all_pieces[i][j].queue_free()
	var bomb = bomb_piece.instantiate()
	add_child(bomb)
	bomb.position = grid_to_pixel(i, j)
	all_pieces[i][j] = bomb
	bomb.matched = false
	bomb.is_bomb = true
	bomb.connect("input_event", Callable(self, "_on_bomb_clicked").bind(i, j))

func make_bomb(bomb_type, color):
	var bomb_position = Vector2.ZERO
	# Find the first matched piece to place the bomb
	for match_pos in current_matches:
		if all_pieces[match_pos.x][match_pos.y] != null and all_pieces[match_pos.x][match_pos.y].color == color:
			bomb_position = match_pos
			break
	
	print("DEBUG: Attempting to create bomb at position: ", bomb_position)
	if bomb_position.x >= 0 and bomb_position.x < width and bomb_position.y >= 0 and bomb_position.y < height:
		if all_pieces[bomb_position.x][bomb_position.y] != null and all_pieces[bomb_position.x][bomb_position.y].color == color:
			print("DEBUG: Creating bomb of type ", bomb_type, " at position: ", bomb_position)
			all_pieces[bomb_position.x][bomb_position.y].matched = false
			change_bomb(bomb_type, all_pieces[bomb_position.x][bomb_position.y])
			# Remove the piece from current_matches to prevent it from being destroyed
			var piece_index = current_matches.find(bomb_position)
			if piece_index != -1:
				current_matches.remove_at(piece_index)
			return true
	print("DEBUG: Failed to create bomb at position: ", bomb_position)
	return false

func change_bomb(bomb_type, piece):
	if bomb_type == 0:
		piece.make_adjacent_bomb()
	elif bomb_type == 1:
		piece.make_row_bomb()
	elif bomb_type == 2:
		piece.make_column_bomb()
	# Remove the piece from current_matches to prevent it from being destroyed
	var piece_index = current_matches.find(Vector2(piece.get_parent().get_index(), piece.get_index()))
	if piece_index != -1:
		current_matches.remove_at(piece_index)

func match_all_in_column(column):
	if column < 0 or column >= width:
		print("Invalid column index: ", column)
		return
	for i in range(height):
		if all_pieces[column][i] != null:
			all_pieces[column][i].matched = true

func match_all_in_row(row):
	if row < 0 or row >= height:
		print("Invalid row index: ", row)
		return
	for i in range(width):
		if all_pieces[i][row] != null:
			all_pieces[i][row].matched = true

# Add this new function to handle bomb clicks
func _on_bomb_clicked(viewport, event, shape_idx, i, j):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		explode_bomb(i, j)
		find_matches()

# Modify the check_bomb_explosion function (we won't need this anymore, but keep it for now)
func check_bomb_explosion(i, j):
	pass  # We're not using this function anymore, but keeping it to avoid errors

# Mark piece as matched and dim it
func mark_as_matched(i, j):
	if all_pieces[i][j] != null:
		all_pieces[i][j].matched = true
		all_pieces[i][j].dim()

func find_bombs():
	print("DEBUG: Entering find_bombs function")
	print("Current matches: ", current_matches)
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		print("DEBUG: Checking match at (%d, %d)" % [current_column, current_row])
		if all_pieces[current_column][current_row] != null:
			var current_color = all_pieces[current_column][current_row].color
			var col_matched = 0
			var row_matched = 0
			for j in current_matches.size():
				var this_column = current_matches[j].x
				var this_row = current_matches[j].y
				if all_pieces[this_column][this_row] != null:
					var this_color = all_pieces[this_column][this_row].color
					if this_column == current_column and this_color == current_color:
						col_matched += 1
					if this_row == current_row and this_color == current_color:
						row_matched += 1
			print("DEBUG: Matches found: col_matched = %d, row_matched = %d" % [col_matched, row_matched])
			if col_matched == 4:
				print("DEBUG: Attempting to create column bomb")
				if make_bomb(2, current_color):  # 2 for column bomb
					return
			elif row_matched == 4:
				print("DEBUG: Attempting to create row bomb")
				if make_bomb(1, current_color):  # 1 for row bomb
					return
			elif col_matched == 3 and row_matched == 3:
				print("DEBUG: Attempting to create adjacent bomb")
				if make_bomb(0, current_color):  # 0 for adjacent bomb
					return
			elif col_matched == 5 or row_matched == 5:
				print("DEBUG: Attempting to create color bomb")
				# Implement color bomb creation here
		else:
			print("DEBUG: Null piece found at (%d, %d)" % [current_column, current_row])
	print("DEBUG: Exiting find_bombs function")

# Modify the destroy_matched function
func destroy_matched():
	find_bombs()  
	var was_matched = false
	var points_earned = 0
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				if not all_pieces[i][j].is_bomb:  # Only destroy non-bomb pieces
					was_matched = true
					if all_pieces[i][j].color == "blue":
						blue_pieces_cleared += 1
						update_blue_pieces_counter()
					points_earned += all_pieces[i][j].piece_value * streak
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
				else:
					# For bombs, just reset the matched state
					print("DEBUG: Bomb found at (%d, %d), resetting matched state" % [i, j])
					all_pieces[i][j].matched = false
	
	if points_earned > 0:
		update_score(points_earned)
	
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()
	current_matches.clear()
	check_goal()

func add_to_array(value, array_to_add = current_matches):
	if !array_to_add.has(value):
		array_to_add.append(value)
		
# Modify the update_score function
func update_score(points):
	if score_label and score_bar:
		current_game_score += points
		score_label.text = str(current_game_score)
		score_bar.value = current_game_score

# Add this new function to update the score display
func update_score_display():
	if score_label and score_bar:
		score_label.text = str(current_game_score)
		score_bar.value = current_game_score

# New function to check if the goal has been reached
func check_goal():
	if blue_pieces_cleared >= BLUE_GOAL:
		Global.add_points(current_game_score)  # Add the current game score to the total
		get_parent().get_node("win_timer").start()

func show_win_popup():
	var win_screen = get_node_or_null("WinPopup")
	if not win_screen:
		var WinScreenScene = preload("res://Scenes/WinPopup.tscn")
		win_screen = WinScreenScene.instantiate()
		add_child(win_screen)
	Global.add_points(current_game_score)
	win_screen.set_score(current_game_score)
	win_screen.visible = true
	get_tree().paused = true

# Add this new function to show the game over screen
func show_game_over_screen():
	Global.add_points(current_game_score)  # Add this line to save the points even on game over
	var game_over_screen = preload("res://Scenes/GameOverScreen.tscn").instantiate()
	get_tree().root.add_child(game_over_screen)

# Add this function to resume the game when continuing
func resume_game():
	get_tree().paused = false

# Modify the collapse_columns function
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						if all_pieces[i][k].is_bomb:
							print("DEBUG: Moving bomb from (%d, %d) to (%d, %d)" % [i, k, i, j])
							# Swap bombs with empty spaces below them
							all_pieces[i][j] = all_pieces[i][k]
							all_pieces[i][k] = null
							all_pieces[i][j].move(grid_to_pixel(i, j))
							break
						else:
							print("DEBUG: Moving piece from (%d, %d) to (%d, %d)" % [i, k, i, j])
							all_pieces[i][k].move(grid_to_pixel(i, j))
							all_pieces[i][j] = all_pieces[i][k]
							all_pieces[i][k] = null
							break
	get_parent().get_node("refill_timer").start()

# Modify the refill_columns function
func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				# Check if there's a bomb above
				var bomb_above = false
				for k in range(j + 1, height):
					if all_pieces[i][k] != null and all_pieces[i][k].is_bomb:
						print("DEBUG: Moving bomb from (%d, %d) to (%d, %d) during refill" % [i, k, i, j])
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						all_pieces[i][j].move(grid_to_pixel(i, j))
						bomb_above = true
						break
				
				if not bomb_above:
					print("DEBUG: Creating new piece at (%d, %d)" % [i, j])
					all_pieces[i][j] = create_random_piece(i, j)
	after_refill()

# Modify the after_refill function
func after_refill():
	streak += 1
	var match_found = false
	var bombs_present = false
	
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].is_bomb:
					print("DEBUG: Bomb found at (%d, %d) after refill" % [i, j])
					bombs_present = true
				elif match_at(i, j, all_pieces[i][j].color):
					match_found = true
					find_matches()
					break
		if match_found:
			break
	
	if match_found:
		get_parent().get_node("destroy_timer").start()
	elif bombs_present:
		print("DEBUG: Bombs present, but not activating automatically")
		state = GameState.MOVE
		streak = 1
		move_checked = false
	else:
		state = GameState.MOVE
		streak = 1
		move_checked = false
		check_goal()

# Modify the activate_bomb function
func activate_bomb(i, j):
	var bomb = all_pieces[i][j]
	print("DEBUG: Activating bomb at (%d, %d)" % [i, j])
	if bomb.is_row_bomb:
		print("DEBUG: Activating row bomb")
		match_all_in_row(j)
	elif bomb.is_column_bomb:
		print("DEBUG: Activating column bomb")
		match_all_in_column(i)
	elif bomb.is_adjacent_bomb:
		print("DEBUG: Activating adjacent bomb")
		match_adjacent(i, j)
	bomb.queue_free()
	all_pieces[i][j] = null
	find_matches()

func update_wallet_address():
	if wallet_address_label:
		var full_address = Global.get_wallet_address()
		if full_address and full_address != "":
			var shortened_address = full_address.substr(0, 4) + "xx" + full_address.substr(-4)
			wallet_address_label.text = shortened_address
		else:
			wallet_address_label.text = "Not connected"

# Add this new function to update the move counter display
func update_move_counter():
	if move_counter_label:
		move_counter_label.text = str(moves_left)

# Add a new function to update the points display:
func update_points_display():
	if score_label and score_bar:
		var current_score = Global.get_total_points()
		score_label.text = str(current_score)
		score_bar.value = current_score

# Process function to handle state and touch input
func _process(delta):
	if state == GameState.MOVE:
		touch_input()
		
# Callback for destroy timer timeout
func _on_destroy_timer_timeout():
	destroy_matched()

# Callback for collapse timer timeout
func _on_collapse_timer_timeout():
	collapse_columns()

# Callback for refill timer timeout
func _on_refill_timer_timeout():
	refill_columns()


func _on_back_button_pressed():
	var game_hub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(game_hub_path):
		get_tree().change_scene_to_file(game_hub_path)

# Add this function to your grid.gd script
func explode_bomb(i, j):
	var points_earned = 0
	for x in range(max(0, i - 1), min(width, i + 2)):
		for y in range(max(0, j - 1), min(height, j + 2)):
			if all_pieces[x][y] != null:
				if all_pieces[x][y].color == "blue":
					blue_pieces_cleared += 1
					update_blue_pieces_counter()
				points_earned += all_pieces[x][y].piece_value * streak
				all_pieces[x][y].queue_free()
				all_pieces[x][y] = null
	
	if points_earned > 0:
		update_score(points_earned)
	
	get_parent().get_node("collapse_timer").start()

# Override _input function to handle input when the game is paused
func _input(event):
	if get_tree().paused:
		if event is InputEventMouseButton and event.pressed:
			var win_popup = get_node_or_null("WinPopup")
			if win_popup:
				win_popup._input(event)

func _unhandled_input(event):
	if get_tree().paused:
		var win_popup = get_node_or_null("WinPopup")
		if win_popup and win_popup.visible:
			win_popup._input(event)

# Add this function near the top of the script
func _on_bomb_moved(bomb_type, column, row):
	if bomb_type == "row":
		match_all_in_row(row)
	elif bomb_type == "column":
		match_all_in_column(column)
	elif bomb_type == "adjacent":
		match_adjacent(column, row)
	destroy_matched()
	get_parent().get_node("collapse_timer").start()

# Add this new function
func match_adjacent(column, row):
	for i in range(max(0, column - 1), min(width, column + 2)):
		for j in range(max(0, row - 1), min(height, row + 2)):
			if all_pieces[i][j] != null:
				all_pieces[i][j].matched = true


func _on_win_timer_timeout() -> void:
	if state == GameState.MOVE:
		Global.add_points(current_game_score)
		show_win_popup()
	else:
		# If the state isn't MOVE yet, wait a bit longer
		get_parent().get_node("win_timer").start()
