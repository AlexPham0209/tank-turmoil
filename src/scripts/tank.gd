class_name Player
extends CharacterBody2D

@export var username : String
@export var speed : float = 300.0

@onready var name_label : Label = $NameLabel

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	
func _ready() -> void:
	#Set which peer has control over the node
	name_label.text = username
	
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	self.velocity = direction * speed
	move_and_slide()
