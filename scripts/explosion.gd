extends Area2D
class_name Explosion

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _draw():
	draw_circle(Vector2.ZERO, collision_shape.shape.radius, Color(1, 0, 0, 0.3))
	
func get_chickens_in_blast_radius() -> Array:
	var chickens = []
	for body in self.get_overlapping_bodies():
		if body is Chicken:
			chickens.append(body)
			
	return chickens
	
func display_effect() -> void:
	particles.emitting = true
	
func get_effect_duration() -> float:
	return particles.lifetime
