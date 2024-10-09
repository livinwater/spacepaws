extends Control

var chest_cost = 500
var resources = ["Crystal"]
#var resources = #["Silica", "Metal", "Crystal"]
var raffle_ticket_chance = 0.5  # 50% chance to get a raffle ticket

# Update these variables with your Candy Machine details
var raffle_candy_machine_id = "zHmngfvxzasDb7REBL2DwAyhmhgzYNnSKepxpqnGR5H"
#"EPDMTLPBkidL1fXamZUXG9Yp4ZSVsg4QpWdPsKuVUx32"
var raffle_collection_mint_id = "FHiQtqR7rPgGHegQeBqKxWQ7iv7TqvEsdhwhGqxqt2WL"
var raffle_mint_count = 0

@export var candy_machine_id: String
@export var collection_displayable: DisplayableNFT
@export var wallet_adapter: WalletAdapterUI


var candy_machine: Pubkey
var cm_data: CandyMachineData

func _ready():
	print("SolanaService RPC cluster: ", SolanaService.rpc_cluster)
	print("SolanaService active RPC: ", SolanaService.active_rpc)
	print("SolanaService wallet initialized: ", SolanaService.wallet != null)
	update_points_display()
	
	candy_machine = Pubkey.new_from_string(raffle_candy_machine_id)
	
	# Add a back button
	var back_button = Button.new()
	back_button.text = "Back to Hub"
	back_button.position = Vector2(50, 50)
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	add_child(back_button)
	
	# Initialize the raffle mint count
	raffle_mint_count = await get_current_raffle_mint_count()
	print("Initial raffle mint count: ", raffle_mint_count)

func update_points_display():
	var total_points_counter = $TotalPointsCounter
	if total_points_counter:
		total_points_counter.text = "Points: " + str(Global.get_total_points())
	else:
		print("Error: TotalPointsCounter not found in BioMarketInside")

func _on_back_button_pressed():
	var game_hub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(game_hub_path):
		print("Returning to GameHub scene")
		get_tree().change_scene_to_file(game_hub_path)
	else:
		print("Error: GameHub scene not found at ", game_hub_path)

func _on_chest_pressed() -> void:
	print("Chest clicked!")
	if Global.get_total_points() >= chest_cost:
		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "Open chest for 500 points?"
		dialog.get_ok_button().text = "Open"
		dialog.get_cancel_button().text = "Cancel"
		dialog.connect("confirmed", Callable(self, "_on_chest_open_confirmed"))
		add_child(dialog)
		dialog.popup_centered()
	else:
		var insufficient_points_dialog = AcceptDialog.new()
		insufficient_points_dialog.dialog_text = "Not enough points to open the chest."
		add_child(insufficient_points_dialog)
		insufficient_points_dialog.popup_centered()
		
func _on_chest_open_confirmed():
	print("Chest opening confirmed")
	Global.add_points(-chest_cost)
	update_points_display()
	   
	var max_resource_amount = 5  # Maximum amount of a single resource
	   
	var reward = ""
	var amount
	var resource
	if randf() < raffle_ticket_chance:
		print("Attempting to mint raffle ticket")
		#reward = await mint_raffle_ticket()
		reward = null
	else:
		resource = resources[randi() % resources.size()]
		amount = randi() % max_resource_amount + 1  # Random amount between 1 and max_resource_amount
		reward = str(amount) + " " + resource
		Global.add_resource(resource, amount)  # Add this line to update the global resource count
	
	print("Reward determined: ", reward)
	
	var reward_dialog = AcceptDialog.new()
	raffle_mint_count += 1
	var ticket_number = "%06d" % raffle_mint_count
	if reward == null:
		reward_dialog.dialog_text = "You received: 1 Raffle ticket " + "" + ticket_number
	else:
		reward_dialog.dialog_text = "You received: " + reward
	add_child(reward_dialog)
	reward_dialog.popup_centered()
	   
	print("Player received: ", reward)

func mint_raffle_ticket() -> String:
	print("Entering mint_raffle_ticket function")
	if !SolanaService.wallet:
		print("Error: SolanaService wallet is not initialized")
		return "Error: SolanaService not initialized"
	
	if !SolanaService.wallet.is_logged_in():
		print("Error: Wallet is not connected")
		return "Error: Wallet not connected"
	
	raffle_mint_count += 1
	var ticket_number = "%06d" % raffle_mint_count
	
	print("Fetching Candy Machine data for ID: ", raffle_candy_machine_id)
	cm_data = await SolanaService.candy_machine_manager.fetch_candy_machine(candy_machine)
	print("Candy Machine data fetched. Raw data:")
	print(JSON.stringify(cm_data, "\t"))
	
	if cm_data == null:
		print("Error: Failed to fetch Candy Machine data")
		return "Error: Failed to fetch Candy Machine data"
	
	print("Candy Machine data fetched successfully")
	print("CM Data type: ", typeof(cm_data))
	print("CM Data contents:")
	print(cm_data)
	
	var mint_account: Keypair = Keypair.new_random()
	print("Attempting to mint NFT")

	var tx_data = await SolanaService.candy_machine_manager.mint_nft(
		candy_machine,
		cm_data,
		SolanaService.wallet,
		SolanaService.wallet.get_kp(),
		TransactionManager.Commitment.FINALIZED,
		0.0,
		)

	
	print("Transaction data received: ", tx_data)
   
	if !tx_data.is_successful():
		#print("Error: Transaction failed. Details: ", tx_data.get_error_message())
		print("1 Raffle Ticket #" + ticket_number)
		return "Error: Failed to mint raffle ticket"
	
	print("Raffle ticket minted successfully")
	return "1 Raffle Ticket #" + ticket_number

func get_current_raffle_mint_count() -> int:
	print("Fetching current raffle mint count")
	var cm_data = await SolanaService.candy_machine_manager.fetch_candy_machine(Pubkey.new_from_string(raffle_candy_machine_id))
	if cm_data != null:
		print("Current raffle mint count: ", cm_data.items_redeemed)
		return cm_data.items_redeemed
	print("Failed to fetch current raffle mint count")
	return 0
