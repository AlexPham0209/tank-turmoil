class_name Bullet
extends Node2D

@export var speed : float = 100.0
@export var direction : Vector2 = Vector2.ZERO
@onready var timer : Timer = $Timer
@onready var hitbox : Hitbox = $Hitbox
@export var id : int = 1

func _ready() -> void:
	hitbox.id = id
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.position += direction * speed * delta
	if is_multiplayer_authority():
		timer.start()
	
func _on_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_multiplayer_authority():
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_multiplayer_authority():
		queue_free()
