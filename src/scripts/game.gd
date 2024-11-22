extends Node2D

@onready var level : Node2D = $Level
@onready var ui : Control = $UI

func _ready() -> void:
	MultiplayerManager.server_disconnected.connect(on_server_disconnected)
	MultiplayerManager.change_level.connect(change_level)

func change_level(scene : PackedScene):
	add_level.rpc_id(1, scene)

@rpc("authority", "call_local", "reliable")
func add_level(scene : PackedScene):
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
	# Add new level.
	level.add_child(scene.instantiate())

func _on_text_edit_text_submitted(new_text: String) -> void:
	MultiplayerManager.player_info.name = new_text

func _on_host_pressed() -> void:
	MultiplayerManager.create_game()
	start_game()

func _on_join_pressed() -> void:
	if MultiplayerManager.join_game() != OK:
		print("Server not found")
		return
		
	start_game()

func start_game():
	ui.hide()
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://src/scenes/lobby.tscn"))

func on_server_disconnected() -> void:
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
		
	ui.show()
