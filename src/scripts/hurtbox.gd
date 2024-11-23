class_name Hurtbox
extends Area2D

signal take_damage(amount : int)
signal stop_invincibility

@export var invincibility_time : float = 1.0
@onready var timer : Timer = $Timer

func _ready() -> void:
	timer.wait_time = invincibility_time

func _physics_process(delta: float) -> void:
	if not monitorable or not monitoring:
		return
			
	var hitboxes = get_overlapping_areas().filter(func(child): return child is Hitbox)
	if timer.is_stopped() and hitboxes.size() > 0:
		for hitbox in hitboxes:
			take_damage.emit(hitbox.damage) 
		timer.start()

func _on_timer_timeout() -> void:
	stop_invincibility.emit()
