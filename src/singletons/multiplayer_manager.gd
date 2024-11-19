extends Node

const PORT : int = 9000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 4

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var peer : ENetMultiplayerPeer
var players : Dictionary = {}

var player_info : PlayerInfo

func _ready() -> void:
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)

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
	return OK
	

#When the current client connects to the server 
func on_connected_to_server() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

#If current client fails to connect to server
func on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null

#When a player connects to the current server, tje signal notifies all clients (including authority)
func on_player_connected(id : int) -> void:
	register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func register_player(player_info : PlayerInfo):
	var peer_id = multiplayer.get_remote_sender_id()
	players[peer] = player_info
	player_connected.emit(peer_id, player_info)

#When a player disconnects from the current server, it notifies all clients all clients (including authority)
func on_player_disconnected(id : int) -> void:
	players.erase(id)
	player_disconnected.emit(id)
	

	
