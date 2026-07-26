extends CharacterBody2D
class_name Chicken

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

@export var health: float = 15
@export var max_health: float = 15
@export var damage: float = 1
@export var speed: float = 25

var move_target

func _ready() -> void:
	health_bar.value = self.health
	health_bar.max_value = self.max_health
	
	await delay(randf())
	sprite.play()

func _process(delta: float) -> void:
	health_bar.value = self.health
	health_bar.max_value = self.max_health
	
	if move_target != null:
		move_towards(move_target)
		
		if move_target.x < self.position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
func move_towards(target_pos: Vector2) -> void:
	var direction = (target_pos - self.position).normalized()
	var new_velocity = direction * speed
	
	self.velocity = new_velocity
	move_and_slide()

func set_move_target(target_pos: Vector2) -> void:
	move_target = target_pos
	
func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
