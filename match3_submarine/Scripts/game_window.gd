extends Control

func _ready():
    if Global.levels.is_empty():
        var levels_loaded = Global.load_levels()
        if levels_loaded:
            start_game()
        else:
            print("Failed to load levels")
            # Handle the error (e.g., show an error message to the user)
    else:
        start_game()

func start_game():
    var grid = get_node("grid")
    if grid:
        var level_data = Global.levels[str(Global.current_level_id)]
        grid.set_level_data(level_data)
        print("Level ", Global.current_level_id, " loaded")
    else:
        print("Error: grid node not found in game_window scene")
