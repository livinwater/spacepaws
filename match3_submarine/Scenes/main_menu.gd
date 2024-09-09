extends Control

@export var game_scene: PackedScene

func _ready():
	$StartButton.connect("pressed", _on_start_button_pressed)
	$ConnectWallet.connect("pressed", _on_connect_wallet_pressed)
	SolanaService.wallet.connect("on_login_finish", _on_login_finish)

func _on_start_button_pressed():
	load_game()

func _on_connect_wallet_pressed():
	var login_success = await SolanaService.wallet.try_login()
	print("Login attempt result: ", login_success)

func _on_login_finish(success: bool):
	if success:
		print("Wallet connected successfully")
		load_game()
	else:
		print("Wallet connection failed")

func load_game():
	var game_window_path = "res://Scenes/game_window.tscn"
	if ResourceLoader.exists(game_window_path):
		print("Loading game scene")
		get_tree().change_scene_to_file(game_window_path)
	else:
		print("Error: GameWindow scene not found at ", game_window_path)
