extends Control

@export var game_scene: PackedScene
@export var wallet_adapter: WalletAdapterUI

func _ready():
	print("Main menu _ready function called")
	print("Wallet adapter reference:", wallet_adapter)
	
	if SolanaService.wallet:
		print("SolanaService.wallet found")
		SolanaService.wallet.connect("on_login_finish", load_game)
		SolanaService.wallet.connect("on_login_begin", pop_adaptor)
	else:
		print("Error: SolanaService.wallet is null")

	if wallet_adapter:
		print("wallet_adapter found")
		wallet_adapter.connect("on_provider_selected", handle_provider_selected)
		wallet_adapter.connect("on_adapter_cancel", close_adaptor)
		wallet_adapter.visible = false
		print("Wallet adapter initial visibility:", wallet_adapter.visible)
	else:
		print("Error: wallet_adapter is null")




func pop_adaptor():
	print("pop adaptor started")
	if wallet_adapter:
		wallet_adapter.visible = true
		print("Wallet adapter visibility set to true")
		if SolanaService.wallet and SolanaService.wallet.wallet_adapter:
			var available_wallets = SolanaService.wallet.wallet_adapter.get_available_wallets()
			print("Available wallets:", available_wallets)
			wallet_adapter.setup(available_wallets)
		else:
			print("Error: SolanaService.wallet or wallet_adapter is null")
	else:
		print("Error: wallet_adapter is null")
	print("pop_adaptor completed")  # Add this line
		
func handle_provider_selected(id:int):
	print("handle provider initialised")
	SolanaService.wallet.login_adapter(id)
	
func close_adaptor():
	wallet_adapter.visible = false

	
func _on_start_button_pressed():
	# Uncomment the next line if you want to reset points for each new game
	# Global.total_points = 0
	SolanaService.wallet.try_login()

func _on_connect_wallet_pressed():
	print("Continue button pressed")
	#var login_success = await SolanaService.wallet.try_login()
	SolanaService.wallet.try_login()

	#if login_success:
		#print("Wallet connected successfully")
		#if SolanaService.wallet.get_pubkey():
			#var full_address = SolanaService.wallet.get_pubkey().to_string()
			#Global.set_wallet_address(full_address)
			#print("Wallet address set: ", full_address)
			#
			## Load assets after successful wallet connection
			#print("Starting to load assets...")
			#await SolanaService.asset_manager.load_assets()
			#print("Assets loaded. Total assets: ", SolanaService.asset_manager.owned_assets.size())
			#
			## You can add more detailed asset information here if needed
			#for asset in SolanaService.asset_manager.owned_assets:
				#print("Asset: ", asset.get_name())
		#else:
			#print("Error: Unable to get wallet public key")
	#else:
		#print("Wallet connection failed")

#func _on_login_finish(success: bool):
	#if success:
		#print("Wallet connected successfully")
		#if SolanaService.wallet.get_pubkey():
			#var full_address = SolanaService.wallet.get_pubkey().to_string()
			#Global.set_wallet_address(full_address)
			#print("Wallet address set: ", full_address)
		#else:
			#print("Error: Unable to get wallet public key")
		##load_game()
	#else:
		#print("Wallet connection failed")

func load_game(success:bool):
	if success:
		print("Loading game hub scene")
		get_tree().change_scene_to_packed(game_scene)
