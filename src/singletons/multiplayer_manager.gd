extends Node

const PORT : int = 9000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 4

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_failed
signal change_level(level : PackedScene)

var peer : ENetMultiplayerPeer
var players : Dictionary = {}

var player_info : PlayerInfo = PlayerInfo.new()

func _ready() -> void:
	multiplayer.allow_object_decoding = true
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	
	#if OS.has_feature("dedicated_server"):
		#create_game()
	

func join_game(address = "") -> Error:
	peer = ENetMultiplayerPeer.new()
	
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	
	var error : Error = peer.create_client(address, PORT)

	if error:
		return error
		
	multiplayer.multiplayer_peer = peer
	return OK

func create_game() -> Error:
	peer = ENetMultiplayerPeer.new()
	
	var error : Error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
		
	multiplayer.multiplayer_peer = peer
	
	if not OS.has_feature("dedicated_server"):
		player_connected.emit(1, player_info)

	return OK

#When the current client connects to the server 
func on_connected_to_server() -> void:
	print("connected")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

#If current client fails to connect to server
func on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

#When a player connects to the current server, tje signal notifies all clients (including authority)
func on_player_connected(id : int) -> void:
	register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func register_player(player_info : PlayerInfo):
	var peer_id = multiplayer.get_remote_sender_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

#When a player disconnects from the current server, it notifies all clients all clients (including authority)
func on_player_disconnected(id : int) -> void:
	players.erase(id)
	player_disconnected.emit(id)

func on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	peer = null
	players.clear()
	server_disconnected.emit()

func disconnect_from_server() -> void:
	if peer != null:
		peer.close()
