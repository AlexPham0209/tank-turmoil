extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	GameManager.reset()
	
	if not multiplayer.is_server():
		return
	
	MultiplayerManager.disconnect_players() 
	MultiplayerManager.change_level.emit(load("res://src/scenes/lobby.tscn"))
