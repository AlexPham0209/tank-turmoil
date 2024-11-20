extends Node2D

var next_level = preload("res://src/scenes/level.tscn")
@onready var level : Node2D = $Level
@onready var ui : Control = $UI

func change_level(scene : PackedScene):
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
	MultiplayerManager.join_game()
	start_game()

func start_game():
	ui.hide()
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://src/scenes/level.tscn"))

func _on_level_spawner_spawned(node: Node) -> void:
	print(node)
