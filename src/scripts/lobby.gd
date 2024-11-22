extends Control

var name_label : PackedScene = preload("res://src/scenes/name_label.tscn")

var names : Dictionary = Dictionary()
var player_order : Array[int]

@onready var container : VBoxContainer = $Container
@onready var start_button : Button = $Start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.hide()
	
	if not multiplayer.is_server():
		return
	
	MultiplayerManager.player_connected.connect(add_player)
	MultiplayerManager.player_disconnected.connect(remove_player)
	
	for id in multiplayer.get_peers():
		add_player(id, MultiplayerManager.players[id])
	
	add_player(multiplayer.get_unique_id(), MultiplayerManager.player_info)

func add_player(id : int, player_info : PlayerInfo):
	var instance = name_label.instantiate()
	instance.text = player_info.name
	names[id] = instance
	container.add_child(instance, true)
	
	if names.size() == 1:
		show_button.rpc_id(id)

func remove_player(id : int):
	var name = names[id]
	names.erase(id)
	var order = player_order.find(id)
	player_order.erase(id)
	
	if player_order.find(id) == 0:
		show_button.rpc_id(player_order[0])
	
	name.queue_free()
	
func start_game() -> void:
	GameManager.next_round()

@rpc("any_peer", "call_local")
func show_button() -> void:
	start_button.show()

	
