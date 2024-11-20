extends Marker2D

var player : PackedScene = preload("res://src/scenes/tank.tscn")

func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	MultiplayerManager.player_connected.connect(add_player)
	MultiplayerManager.player_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(multiplayer.get_unique_id(), MultiplayerManager.players[id])
	
	add_player(multiplayer.get_unique_id(), MultiplayerManager.player_info)

func add_player(id : int, player_info : PlayerInfo) -> void:
	var instance : Player = player.instantiate()
	instance.name = str(id)
	instance.username = player_info.name
	instance.global_position = self.global_position
	
	get_tree().root.add_child.call_deferred(instance)

func remove_player(id : int) -> void:
	var instance : Player = get_node_or_null(str(id))
	if player:
		player.queue_free()
