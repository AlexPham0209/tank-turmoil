extends Control

var scene : String = "res://src/scenes/level.tscn"

func _on_text_edit_text_submitted(new_text: String) -> void:
	MultiplayerManager.player_info.name = new_text
	print(MultiplayerManager.player_info.name)

func _on_host_pressed() -> void:
	var error = MultiplayerManager.create_game()
	
	if error != OK:
		return
		
	get_tree().change_scene_to_file(scene)

func _on_join_pressed() -> void:
	MultiplayerManager.join_game()
	get_tree().change_scene_to_file(scene)

func player_connected() -> void:
	get_tree().change_scene_to_file(scene)
