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

var possible_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

var all_pieces = []

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
const PopupScene = preload("res://Scenes/WinPopup.tscn")

func _ready():
	print("Grid script _ready function called")
	state = GameState.MOVE
	var back_button = $BackButton
	if back_button:
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	randomize()
	all_pieces = make_2D_array()
	center_grid()  # Call this before spawning pieces
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
		if not move_checked:
			find_matches()
			moves_left -= 1
			update_move_counter()
			check_game_over()

func check_game_over():
	if moves_left <= 0:
		print("Game Over! Out of moves.")
		Global.add_points(current_game_score)  # Add the current game score to the total
		show_game_over_screen()
	elif blue_pieces_cleared >= BLUE_GOAL:
		print("Level completed! You've cleared %d blue pieces!" % blue_pieces_cleared)
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
		print("Horizontal match at (%d, %d): %d pieces" % [i, j, horizontal_matches])
	elif vertical_matches >= 3:
		for k in range(j, j + vertical_matches):
			if k >= 0 and k < height:
				mark_as_matched(i, k)
		print("Vertical match at (%d, %d): %d pieces" % [i, j, vertical_matches])

	print("Matches at (%d, %d): horizontal = %d, vertical = %d" % [i, j, horizontal_matches, vertical_matches])

# New function to create a bomb
func create_bomb(i, j):
	print("Attempting to create bomb at (%d, %d)" % [i, j])
	if all_pieces[i][j] != null:
		all_pieces[i][j].queue_free()
	var bomb = bomb_piece.instantiate()
	add_child(bomb)
	bomb.position = grid_to_pixel(i, j)
	all_pieces[i][j] = bomb
	bomb.matched = false
	bomb.is_bomb = true
	bomb.connect("input_event", Callable(self, "_on_bomb_clicked").bind(i, j))
	print("Bomb created at position (%d, %d)" % [i, j])

# Add this new function to handle bomb clicks
func _on_bomb_clicked(viewport, event, shape_idx, i, j):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Bomb clicked at (%d, %d)" % [i, j])
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
	else:
		print("Warning: Attempted to mark a null piece as matched at position (%d, %d)" % [i, j])

# Modify the destroy_matched function
func destroy_matched():
	var was_matched = false
	var points_earned = 0
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				was_matched = true
				if all_pieces[i][j].color == "blue":
					blue_pieces_cleared += 1
					update_blue_pieces_counter()
				points_earned += all_pieces[i][j].piece_value * streak
				print("Destroying piece at (%d, %d), value: %d" % [i, j, all_pieces[i][j].piece_value])
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = null
	
	if points_earned > 0:
		print("Total points earned: %d" % points_earned)
		update_score(points_earned)
	
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()
	
	check_goal()

# Modify the update_score function
func update_score(points):
	if score_label and score_bar:
		current_game_score += points
		score_label.text = str(current_game_score)
		score_bar.value = current_game_score
		print("Current game score updated: ", current_game_score)  # Debug print
	else:
		print("Error: score_label or score_bar is null")

# Add this new function to update the score display
func update_score_display():
	if score_label and score_bar:
		score_label.text = str(current_game_score)
		score_bar.value = current_game_score
	else:
		print("Error: score_label or score_bar is null")

# New function to check if the goal has been reached
func check_goal():
	if blue_pieces_cleared >= BLUE_GOAL:
		print("Level completed! You've cleared %d blue pieces!" % blue_pieces_cleared)
		Global.add_points(current_game_score)  # Add the current game score to the total
		show_win_popup()

func show_win_popup():
	print("Showing win popup")  # Debug print
	var win_popup = get_node_or_null("WinPopup")
	if not win_popup:
		win_popup = PopupScene.instantiate()
		add_child(win_popup)
	Global.add_points(current_game_score)  # Add this line to save the points
	win_popup.set_score(current_game_score)
	win_popup.popup.popup_centered()
	get_tree().paused = true

# Add this new function to show the game over screen
func show_game_over_screen():
	Global.add_points(current_game_score)  # Add this line to save the points even on game over
	var game_over_screen = preload("res://Scenes/GameOverScreen.tscn").instantiate()
	get_tree().root.add_child(game_over_screen)

# Add this function to resume the game when continuing
func resume_game():
	get_tree().paused = false

# Collapse columns after match
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()

# Refill the grid after collapsing
func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				all_pieces[i][j] = create_random_piece(i, j)
	after_refill()
				
# Check for new matches after refill
func after_refill():
	streak += 1
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and match_at(i, j, all_pieces[i][j].color):
				find_matches()
				get_parent().get_node("destroy_timer").start()
				return
	# If no new matches are found, switch state back to move
	state = GameState.MOVE
	streak = 1
	move_checked = false

func update_wallet_address():
	print("Updating wallet address")
	if wallet_address_label:
		var full_address = Global.get_wallet_address()
		print("Full address from Global: ", full_address)
		if full_address and full_address != "":
			var shortened_address = full_address.substr(0, 4) + "xx" + full_address.substr(-4)
			wallet_address_label.text = shortened_address
			print("Wallet address updated to: ", shortened_address)
		else:
			wallet_address_label.text = "Not connected"
			print("Wallet not connected")
	else:
		print("wallet_address_label not found")

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
	else:
		print("Error: score_label or score_bar is null")

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
		print("Changing to GameHub scene")  # Debug print
		get_tree().change_scene_to_file(game_hub_path)
	else:
		print("Error: GameHub scene not found at ", game_hub_path)

# Add this function to your grid.gd script
func explode_bomb(i, j):
	print("Exploding bomb at (%d, %d)" % [i, j])
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
			print("Passing input to WinPopup from grid")
			win_popup._input(event)
