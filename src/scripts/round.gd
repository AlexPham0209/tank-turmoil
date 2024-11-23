class_name Level
extends Node

@onready var players = $Players
@onready var spawn : Marker2D = $Spawn
var player : PackedScene = preload("res://src/scenes/player.tscn")

func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	await get_tree().create_timer(2.0).timeout
	MultiplayerManager.player_connected.connect(add_player)
	MultiplayerManager.player_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id, MultiplayerManager.players[id])
	
	add_player(multiplayer.get_unique_id(), MultiplayerManager.player_info)
	
func player_killed():
	print(players.get_children().size())
	if players.get_children().size() <= 1:
		GameManager.increase_wins.rpc(players.get_children()[0].id)
		print(GameManager.scores)

func add_player(id : int, player_info : PlayerInfo) -> void:
	var instance : Player = player.instantiate()
	instance.name = str(id)
	instance.id = id
	instance.username = player_info.name
	instance.global_position = spawn.global_position
	instance.tree_exited.connect(player_killed)
	
	players.add_child(instance, true)

func remove_player(id : int) -> void:
	var instance : Player = players.get_node_or_null(str(id))
	
	if instance:
		instance.queue_free()
