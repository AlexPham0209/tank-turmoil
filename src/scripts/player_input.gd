class_name PlayerInput
extends Node2D

@export var direction : Vector2 = Vector2.ZERO
@export var mouse_position : Vector2 = Vector2.ZERO
var can_shoot : bool = false

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().name.to_int())

func _ready() -> void:
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()

@rpc("any_peer", "call_local")
func shoot() -> void:
	can_shoot = true
