class_name Level
extends Node

@onready var players = $Players
@onready var bullets = $Bullets
@onready var spawn : Marker2D = $Spawn
var player : PackedScene = preload("res://src/scenes/player.tscn")

func _ready() -> void:
	if not multiplayer.is_server():
		return

	MultiplayerManager.player_connected.connect(add_player)
	MultiplayerManager.player_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id, MultiplayerManager.players[id])
	
	add_player(multiplayer.get_unique_id(), MultiplayerManager.player_info)
	
func player_killed(player : Player):
	await player.tree_exited
	if players.get_children().size() <= 1:
		GameManager.increase_wins.rpc(players.get_children()[0].id)
		MultiplayerManager.change_level.emit(load("res://src/scenes/scoreboard.tscn"))

func add_player(id : int, player_info : PlayerInfo) -> void:
	var instance : Player = player.instantiate()
	instance.name = str(id)
	instance.id = id
	instance.username = player_info.name
	instance.global_position = spawn.global_position
	instance.death.connect(player_killed)
	instance.bullet_path = bullets
	players.add_child(instance, true)

func remove_player(id : int) -> void:
	var instance : Player = players.get_node_or_null(str(id))
	
	if instance:
		instance.queue_free()
