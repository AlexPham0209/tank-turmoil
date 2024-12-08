extends Control

var message_box : PackedScene = preload("res://src/scenes/message.tscn")
@onready var messages : VBoxContainer = $ScrollContainer/VBoxContainer

signal update_chat(is_open : bool)

func _ready() -> void:
	visible = false

@rpc("any_peer", "call_local")
func add_message(id : int, message : String) -> void:
	var instance = message_box.instantiate()
	instance.text = "%s: %s" % [MultiplayerManager.players[id].name, message]
	messages.add_child(instance)

func _on_line_edit_text_submitted(new_text: String) -> void:
	add_message.rpc(multiplayer.get_unique_id(), new_text)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("chat"):
		visible = !visible
		update_chat.emit(visible)
