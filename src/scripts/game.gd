extends Node2D

@onready var level : Node2D = $Level
@onready var ui : Control = $UI
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	MultiplayerManager.server_disconnected.connect(lost_connection)
	MultiplayerManager.connection_failed.connect(lost_connection)
	MultiplayerManager.change_level.connect(change_level)
	
	if OS.has_feature("dedicated_server"):
		print("dedicated")
		MultiplayerManager.create_game()
		start_game()

func change_level(scene : PackedScene):
	#transition.rpc()
	add_level.rpc_id(1, scene)

@rpc("any_peer", "call_local")
func transition() -> void:
	animation_player.play("fade")
	animation_player.play_backwards("fade")

@rpc("any_peer", "call_local")
func add_level(scene : PackedScene):
	print(multiplayer.get_unique_id())
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
	# Add new level.
	level.add_child(scene.instantiate())

func _on_text_edit_text_submitted(new_text: String) -> void:
	MultiplayerManager.player_info.name = new_text

func _on_host_pressed() -> void:
	if MultiplayerManager.create_game():
		print("Game already created")
		return
	
	start_game()

func _on_join_pressed() -> void:
	if MultiplayerManager.player_info.name == "":
		return
	
	if MultiplayerManager.join_game() != OK:
		print("Server not found")
		return
		
	start_game()

func start_game():
	ui.hide()
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://src/scenes/lobby.tscn"))

func lost_connection() -> void:
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	animation_player.play_backwards("fade")

	ui.show()


func _on_text_edit_text_changed(new_text: String) -> void:
	MultiplayerManager.player_info.name = new_text
