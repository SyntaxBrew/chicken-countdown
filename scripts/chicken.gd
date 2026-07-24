extends CharacterBody2D
class_name Chicken

@export var speed: float = 4

var move_target

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if move_target != null:
		move_towards(move_target)
	
func move_towards(target_pos: Vector2) -> void:
	var direction = (target_pos - self.position).normalized()
	var new_velocity = direction * speed
	
	self.velocity = new_velocity
	move_and_slide()

func set_move_target(target_pos: Vector2) -> void:
	move_target = target_pos
