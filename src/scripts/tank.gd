class_name Player
extends CharacterBody2D

@export var username : String
@export var speed : float = 300.0

@export var id := 1

@onready var name_label : Label = $NameLabel
@onready var player_input : PlayerInput = $PlayerInput

func _ready() -> void:
	#Set which peer has control over the node
	name_label.text = username
	
func _physics_process(delta: float) -> void:
	self.velocity = player_input.direction * speed
	move_and_slide()
