extends Node2D

const CHICKEN_SCENE = preload("res://scenes/chicken.tscn")
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

@onready var chicken_spawns = $ChickenSpawns
@onready var chicken_container = $Chickens
@onready var base_marker: Marker2D = $BaseMarker
@onready var effects_container = $Effects

func _ready() -> void:
	for wave in range(10):
		for angle in range(0, 361, 10):
			var radius: float = 300
			var chicken_position: Vector2 = Vector2(
				base_marker.position.x + radius * cos(deg_to_rad(angle)),
				base_marker.position.y + radius * sin(deg_to_rad(angle))
			) 
			spawn_chicken(chicken_position)
			await delay(0.1)
		await delay(1)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_action"):
		var explosion: Explosion = EXPLOSION_SCENE.instantiate()
		explosion.position = get_global_mouse_position()
		await delay(5)
		
		effects_container.add_child(explosion)
		explosion.display_effect()
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		for chicken in explosion.get_chickens_in_blast_radius() as Array[Chicken]:
			chicken.queue_free()
		
		await delay(explosion.get_effect_duration())
		explosion.queue_free()
	
func spawn_chicken(position: Vector2) -> void:
	var chicken: Chicken = CHICKEN_SCENE.instantiate()
	chicken.position = position
	chicken.set_move_target(base_marker.position)
	
	chicken_container.add_child(chicken)

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
