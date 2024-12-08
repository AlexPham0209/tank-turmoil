class_name Player
extends CharacterBody2D

signal death(player : Player)
var bullet : PackedScene = preload("res://src/scenes/bullet.tscn")

@export var username : String
@export var speed : float = 300.0

@export var id := 1

var bullet_path : Node2D

@onready var name_label : Label = $NameLabel
@onready var player_input : PlayerInput = $PlayerInput
@onready var camera : Camera2D = $Camera2D
@onready var aim : Node2D = $Aim
@onready var sprite : Sprite2D = $Sprite2D
@onready var bullet_spawn : Marker2D = $Aim/Marker2D
@onready var hurtbox : Hurtbox = $Hurtbox
@onready var health_bar : ProgressBar = $HealthBar

var is_chat_open : bool = false

enum State {
	WAIT,
	IDLE,
	RUN,
	HURT,
	DEAD
}

var current_state : State = State.IDLE
var max_health : int = 5
var max_bullets : int = 3

@export var top_left : Marker2D
@export var bottom_right : Marker2D

@export var health : float = 0 :
	set(value):
		health = clamp(value, 0, max_health)
		if health_bar != null:
			health_bar.value = int((value / max_health) * 100)
			
		if id == multiplayer.get_unique_id():
			Signals.update_health.emit(health)
		
@export var bullets : float = 0 :
	set(value):
		bullets = clamp(value, 0, max_bullets)
		if id == multiplayer.get_unique_id():
			Signals.update_ammo.emit(bullets)

func _ready() -> void:
	health = max_health
	bullets = max_bullets
	hurtbox.take_damage.connect(on_take_damage)
	
	if top_left:
		camera.limit_left = top_left.position.x
		camera.limit_top = top_left.position.y
	if bottom_right:
		camera.limit_right = bottom_right.position.x
		camera.limit_bottom = bottom_right.position.y
	
	#Set which peer has control over the node
	name_label.text = username
	if id == multiplayer.get_unique_id():
		camera.make_current()

func _physics_process(delta: float) -> void:
	if is_chat_open:
		return
	
	aim.rotation = (player_input.mouse_position - global_position).normalized().angle()
	if player_input.direction.x != 0:
		sprite.flip_h = player_input.direction.x > 0
	
	self.velocity = player_input.direction * speed
	move_and_slide()
	
	if player_input.can_shoot:
		shoot()
		
	player_input.can_shoot = false
	
func shoot() -> void:
	camera.screen_shake()
	var instance : Bullet = bullet.instantiate()
	instance.global_position = bullet_spawn.global_position
	var direction : Vector2 = (player_input.mouse_position - global_position).normalized()
	instance.rotation = direction.angle()
	instance.direction = direction
	instance.id = id
	
	if bullet_path != null:
		bullet_path.add_child(instance, true)
	
func on_take_damage(hitbox : Hitbox) -> void:
	health -= hitbox.damage
	print(health_bar.value)

	if health <= 0:
		if id == multiplayer.get_unique_id():
			GameManager.increase_kills.rpc(hitbox.id)
			GameManager.increase_deaths.rpc(id)
		
		death.emit(self)
		queue_free()

func on_update_chat_rpc(value : bool) -> void:
	on_update_chat.rpc(value)

@rpc("any_peer", "call_local")
func on_update_chat(value : bool) -> void:
	is_chat_open = value
