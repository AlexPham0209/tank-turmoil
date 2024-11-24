extends CanvasLayer

var score : PackedScene = preload("res://src/scenes/score.tscn")

@onready var timer : Timer = $Control/Timer
@onready var scores : VBoxContainer = $Control/Scores
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	var players = GameManager.scores.keys()
	players.sort_custom(func(a, b): return GameManager.scores[a]["wins"] > GameManager.scores[b]["wins"])
	
	for player in players:
		add_score(player)
	
	timer.start()
	

func add_score(player : int) -> void:
	var player_score = GameManager.scores[player]

	var instance : Score = score.instantiate()
	instance.player = player_score["name"]
	instance.wins = player_score["wins"]
	instance.kills = player_score["kills"]
	instance.deaths = player_score["deaths"]
	
	scores.add_child(instance, true)

	
func _on_timer_timeout() -> void:
	GameManager.next_round()
