extends Area2D
class_name RocketProjectile

@onready var sprite: Sprite2D = $Sprite2D
@export var speed: float = 100

var start_pos: Vector2
var target_destination: Vector2
var control_pos: Vector2
var prev_pos: Vector2

var elapsed: float
var duration: float = 1

signal on_hit

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func set_target_destination(target_pos: Vector2) -> void:
	start_pos = self.position
	target_destination = target_pos
	control_pos = (target_pos - start_pos) / 2 - Vector2(0, 200)
	self.prev_pos = start_pos
	
func _physics_process(delta: float):
	if target_destination != null:
		elapsed += delta
		
		var progress = elapsed / duration
		progress = clamp(progress, 0, 1)
		
		self.position = _quadratic_bezier(start_pos, control_pos, target_destination, progress)
		var direction = (self.position - self.prev_pos).normalized()
		sprite.rotation = atan2(direction.y, direction.x) + PI/2
		
		if progress >= 0.9:
			sprite.scale *= 0.9
		
		self.prev_pos = self.position
		
		if progress >= 1:
			on_hit.emit()

		if target_destination.x < self.position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)
