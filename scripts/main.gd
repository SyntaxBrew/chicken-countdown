extends Node2D

const CHICKEN_SCENE = preload("res://scenes/chicken.tscn")
const ROCKET_SCENE = preload("res://scenes/rocket_projectile.tscn")
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const TARGET_MARKER_SCENE = preload("res://scenes/target_marker.tscn")

@onready var chicken_spawns = $ChickenSpawns
@onready var chicken_container = $Chickens
@onready var projectile_container = $Projectiles
@onready var base_marker: Marker2D = $BaseMarker
@onready var effects_container = $Effects
@onready var target_cursor = $TargetCursor

var rocket_launch_duration: float = 1
var time_elapsed: float = 0
var is_launching: bool = false
var is_targeting: bool = false

var rocket_start_pos: Vector2
var rocket_target_pos: Vector2
var rocket_target_marker

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
	if is_targeting:
		target_cursor.position = get_global_mouse_position()
	
	if is_launching:
		time_elapsed += delta
		if time_elapsed >= rocket_launch_duration:
			is_launching = false
			spawn_rocket_projectile(rocket_start_pos, rocket_target_pos)
			rocket_start_pos = Vector2.ZERO
			rocket_target_pos = Vector2.ZERO

	if Input.is_action_just_pressed("left_mouse_action"):
		if is_targeting and not is_launching:
			is_launching = true
			time_elapsed = 0
			rocket_start_pos = Vector2(0, 0)
			rocket_target_pos = get_global_mouse_position()
			
			rocket_target_marker = TARGET_MARKER_SCENE.instantiate()
			rocket_target_marker.position = rocket_target_pos
			rocket_target_marker.scale = Vector2(4, 4)
			effects_container.add_child(rocket_target_marker)
			
			is_targeting = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			target_cursor.visible = false
			
	if Input.is_action_just_pressed("right_mouse_action"):
		if not is_launching:
			is_targeting = not is_targeting
			if is_targeting:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				target_cursor.visible = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				target_cursor.visible = false
			
			
func spawn_chicken(pos: Vector2) -> void:
	var chicken: Chicken = CHICKEN_SCENE.instantiate()
	chicken.position = pos
	chicken.set_move_target(base_marker.position)
	
	chicken_container.add_child(chicken)
	
func spawn_rocket_projectile(start_pos: Vector2, target_pos: Vector2) -> void:
	var rocket_projectile: RocketProjectile = ROCKET_SCENE.instantiate()
	rocket_projectile.position = start_pos
	rocket_projectile.set_target_destination(target_pos)
	
	rocket_projectile.on_hit.connect(func():
		spawn_explosion(rocket_projectile.position)	
		rocket_projectile.queue_free()
		rocket_target_marker.queue_free()
	)
	
	projectile_container.add_child(rocket_projectile)
	
func spawn_explosion(pos: Vector2) -> void:
	var explosion: Explosion = EXPLOSION_SCENE.instantiate()
	explosion.position = pos
	effects_container.add_child(explosion)
	explosion.display_effect()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for chicken in explosion.get_chickens_in_blast_radius() as Array[Chicken]:
		chicken.queue_free()
	
	await delay(explosion.get_effect_duration())
	explosion.queue_free()

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
