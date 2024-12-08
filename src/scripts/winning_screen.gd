extends CanvasLayer

@onready var label : Label = $Control/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var players = GameManager.scores.keys()
	if multiplayer.get_peers().size() <= 0:
		GameManager.reset()
		MultiplayerManager.disconnect_players() 
		MultiplayerManager.change_level.emit(load("res://src/scenes/lobby.tscn"))
		return
		
	players.sort_custom(func(a, b): return GameManager.scores[a]["wins"] > GameManager.scores[b]["wins"])

	label.text = "%s Wins The Game" % GameManager.scores[players[0]]["name"]
	await get_tree().create_timer(2.0).timeout
	GameManager.reset()
	
	if not multiplayer.is_server():
		return
	
	MultiplayerManager.disconnect_players() 
	MultiplayerManager.change_level.emit(load("res://src/scenes/lobby.tscn"))
