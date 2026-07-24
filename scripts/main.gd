extends Node2D

const CHICKEN_SCENE = preload("res://scenes/chicken.tscn")

@onready var chicken_spawns = $ChickenSpawns
@onready var chicken_container = $Chickens
@onready var base_marker: Marker2D = $BaseMarker

func _ready() -> void:
	for wave in range(10):
		for angle in range(0, 361, 10):
			var radius: float = 100
			var chicken_position: Vector2 = Vector2(
				base_marker.position.x + radius * cos(deg_to_rad(angle)),
				base_marker.position.y + radius * sin(deg_to_rad(angle))
			) 
			spawn_chicken(chicken_position)
			await delay(0.1)
		await delay(1)

func _process(delta: float) -> void:
	pass
	
func spawn_chicken(position: Vector2) -> void:
	var chicken: Chicken = CHICKEN_SCENE.instantiate()
	chicken.position = position
	chicken.set_move_target(base_marker.position)
	
	chicken_container.add_child(chicken)

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
