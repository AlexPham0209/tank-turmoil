class_name Level
extends Node

@onready var players = $Players
@onready var bullets = $Bullets
@onready var spawns = $Spawns

@onready var top_left : Marker2D = $Bounds/TopLeft
@onready var bottom_right : Marker2D = $Bounds/BottomRight
	
var player : PackedScene = preload("res://src/scenes/player.tscn")

func _ready() -> void:
	if not multiplayer.is_server():
		return

	MultiplayerManager.player_connected.connect(on_player_connected)
	MultiplayerManager.player_disconnected.connect(remove_player)
	
	var positions = spawns.get_children()
	for id in multiplayer.get_peers():
		var i = randi() % positions.size()
		add_player(id, MultiplayerManager.players[id], positions[i].global_position)
		positions.remove_at(i)
	
	add_player(multiplayer.get_unique_id(), MultiplayerManager.player_info, positions.pick_random().global_position)
	
func player_killed(player : Player):
	await player.tree_exited
	if players.get_children().size() <= 1:
		GameManager.increase_wins.rpc(players.get_children()[0].id)
		await get_tree().create_timer(1.0).timeout
		MultiplayerManager.change_level.emit(load("res://src/scenes/scoreboard.tscn"))
	
func on_player_connected(id : int, player_info : PlayerInfo) -> void:
	add_player(id, player_info, spawns.get_children().pick_random().global_position)
	
func add_player(id : int, player_info : PlayerInfo, position : Vector2) -> void:
	var instance : Player = player.instantiate()
	instance.name = str(id)
	instance.id = id
	instance.username = player_info.name
	instance.global_position = position
	instance.death.connect(player_killed)
	instance.bullet_path = bullets
	
	instance.top_left = top_left
	instance.bottom_right = bottom_right
	
	players.add_child(instance, true)

func remove_player(id : int) -> void:
	var instance : Player = players.get_node_or_null(str(id))
	
	if instance:
		instance.queue_free()
