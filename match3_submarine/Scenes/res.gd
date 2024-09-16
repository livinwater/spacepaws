extends Control

@export var game_scene: PackedScene

func _ready():
	$StartButton.connect("pressed", Callable(self, "_on_start_button_pressed"))
	$ConnectWallet.connect("pressed", Callable(self, "_on_connect_wallet_pressed"))
	SolanaService.wallet.connect("on_login_finish", Callable(self, "_on_login_finish"))

func _on_start_button_pressed():
	# Uncomment the next line if you want to reset points for each new game
	# Global.total_points = 0
	load_game_hub()

func _on_connect_wallet_pressed():
	var login_success = await SolanaService.wallet.try_login()
	print("Login attempt result: ", login_success)

func _on_login_finish(success: bool):
	if success:
		print("Wallet connected successfully")
		if SolanaService.wallet.get_pubkey():
			var full_address = SolanaService.wallet.get_pubkey().to_string()
			Global.set_wallet_address(full_address)
			print("Wallet address set: ", full_address)
		else:
			print("Error: Unable to get wallet public key")
		load_game_hub()
	else:
		print("Wallet connection failed")

func load_game_hub():
	var game_hub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(game_hub_path):
		print("Loading game hub scene")
		get_tree().change_scene_to_file(game_hub_path)
	else:
		print("Error: GameHub scene not found at ", game_hub_path)
