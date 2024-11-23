extends Node

var round : PackedScene = load("res://src/scenes/round.tscn")
var winning_screen : PackedScene = load("res://src/scenes/winning_screen.tscn")
var scores = Dictionary()

var max_rounds = 3
var rounds = 1

func _ready() -> void:
	MultiplayerManager.player_connected.connect(add_player)
	MultiplayerManager.player_disconnected.connect(remove_player)

func next_round() -> void:
	if rounds == max_rounds:
		MultiplayerManager.change_level.emit(winning_screen) 
		return
	MultiplayerManager.change_level.emit(round)
	
func add_player(id : int, player_info : PlayerInfo) -> void:
	var stats = {
		"name" : player_info.name,
		"wins" : 0,
		"kills" : 0,
		"deaths" : 0,
	}
	
	scores[id] = stats

func remove_player(id : int) -> void:
	scores.erase(id)

@rpc("any_peer", "call_local")
func increase_kills(id : int) -> void:
	scores[id]["kills"] += scores[id]["kills"] + 1

@rpc("any_peer", "call_local")
func increase_wins(id : int) -> void:
	scores[id]["wins"] += scores[id]["wins"] + 1

@rpc("any_peer", "call_local")
func increase_deaths(id : int) -> void:
	scores[id]["deaths"] += scores[id]["deaths"] + 1

@rpc("any_peer", "call_local")
func reset() -> void:
	scores = Dictionary()
	rounds = 0
	
