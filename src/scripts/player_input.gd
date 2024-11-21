class_name PlayerInput
extends MultiplayerSynchronizer

@export var direction : Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().id)
	
func _ready() -> void:
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
func _process(delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
