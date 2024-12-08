extends Control

var message_box : PackedScene = preload("res://src/scenes/message.tscn")
@onready var messages : VBoxContainer = $ScrollContainer/VBoxContainer
@onready var line_edit : LineEdit = $LineEdit

signal update_chat(is_open : bool)

func _ready() -> void:
	GameManager.open_chat.connect(_on_open_chat)
	visible = false

@rpc("any_peer", "call_local")
func add_message(id : int, message : String) -> void:
	var instance = message_box.instantiate()
	instance.text = "%s: %s" % [MultiplayerManager.players[id].name, message]
	messages.add_child(instance)

func _on_line_edit_text_submitted(new_text: String) -> void:
	add_message.rpc(multiplayer.get_unique_id(), new_text)
	line_edit.text = ""

func _on_open_chat() -> void:
	visible = !visible
	update_chat.emit(visible)
