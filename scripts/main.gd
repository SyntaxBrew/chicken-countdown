extends Node2D

const CHICKEN_SCENE = preload("res://scenes/chicken.tscn")
const BUFF_CHICKEN_SCENE = preload("res://scenes/buff_chicken.tscn")
const CHICKEN_RUNNER_SCENE = preload("res://scenes/chicken_runner.tscn")
const ROCKET_SCENE = preload("res://scenes/rocket_projectile.tscn")
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const TARGET_MARKER_SCENE = preload("res://scenes/target_marker.tscn")

@onready var chicken_spawns = $ChickenSpawns
@onready var chicken_container = $Chickens
@onready var projectile_container = $Projectiles
@onready var base_marker: Marker2D = $BaseMarker
@onready var effects_container = $Effects
@onready var target_cursor = $TargetCursor

@onready var rocket_projectile_timer_label = $CanvasLayer/RocketProjectileTimer

@onready var death_overlay = $CanvasLayer/DeathOverlay
@onready var win_overlay = $CanvasLayer/WinOverlay

@onready var escape_rocket = $EscapeRocket
@onready var escape_rocket_health_label = $CanvasLayer/EscapeRocketHealthLabel
@onready var escape_rocket_launch_label = $CanvasLayer/EscapeRocketLaunchLabel
@onready var special_msg = $CanvasLayer/WinOverlay/Label3

@onready var target_sound = $TargetSound
@onready var explosion_sound = $ExplosionSound
@onready var launch_sound = $LaunchSound

@onready var game_music = $GameMusic
@onready var victory_music = $VictoryMusic
@onready var defeat_music = $DefeatMusic

@onready var kill_label = $CanvasLayer/Kills

@onready var camera = $Camera2D

var escape_rocket_countdown: float
var selected_rocket_silo
var game_over = false
var time_elapsed = 0

var kills = 0

@onready var rocket_silos: Array[RocketSilo] = [$RocketSilo, $RocketSilo2, $RocketSilo3, $RocketSilo4, $RocketSilo5, $RocketSilo6]

func toggle_rocket_selection(rocket_silo):
	if selected_rocket_silo == rocket_silo:
		disable_target_cursor()
		selected_rocket_silo = null
	else:
		enable_target_cursor()
		selected_rocket_silo = rocket_silo

func _ready() -> void:
	game_music.play()
	game_music.finished.connect(func():
		game_music.play()	
	)
	
	escape_rocket_countdown = escape_rocket.launch_duration
	escape_rocket_health_label.value = escape_rocket.health
	escape_rocket_health_label.max_value = escape_rocket.max_health
	
	escape_rocket.on_damage.connect(func():
		escape_rocket_health_label.value = escape_rocket.health
		if escape_rocket.health == 0 and not game_over:
			death_overlay.visible = true
			game_over = true
			$GameMusic.stop()
			escape_rocket.queue_free()
			defeat_music.play()
	)
	
	for silo in rocket_silos:
		silo.on_selected.connect(toggle_rocket_selection)
	
	while !game_over:
		var random_angle_mult = randi_range(0, 10)
		
		var type = randi_range(1, 3)
		for angle in range(random_angle_mult * 30, (random_angle_mult+1)*30, 2):
			var radius: float = 600
			var chicken_position: Vector2 = Vector2(
				base_marker.position.x + radius * cos(deg_to_rad(angle)),
				base_marker.position.y + radius * sin(deg_to_rad(angle))
			) 
			
			for j in range(randi_range(1, 2 + (1 if (escape_rocket_countdown / 300) <= 0.5 else 0))):
				spawn_chicken(type, chicken_position + Vector2(j, j))
				
		if (escape_rocket_countdown / 300) <= 0.1:
			await delay(1.5)
		else:
			await delay(max(6 * (escape_rocket_countdown / 300), 4))

func _process(delta: float) -> void:
	time_elapsed += delta
	
	if selected_rocket_silo != null:
		var mouse_pos = get_global_mouse_position()
		target_cursor.position = mouse_pos
		
		if Input.is_action_just_pressed("right_mouse_action"):
			selected_rocket_silo = null
			disable_target_cursor()
		elif Input.is_action_just_pressed("left_mouse_action") and selected_rocket_silo and not selected_rocket_silo.mouse_over:
			if not selected_rocket_silo.is_launching:
				selected_rocket_silo.launch(mouse_pos)
				
				var start_pos = selected_rocket_silo.position
				var target_pos = mouse_pos
				
				var target_marker = TARGET_MARKER_SCENE.instantiate()
				target_marker.position = mouse_pos
				target_marker.scale = Vector2(4, 4)
				target_marker.rotation = target_cursor.rotation
				effects_container.add_child(target_marker)
				target_sound.play(1.23)
				
				selected_rocket_silo.on_launch_finished.connect(func():
					spawn_rocket_projectile(start_pos, target_pos, func():
						target_marker.queue_free()
						
					),
					CONNECT_ONE_SHOT
				)
				
				selected_rocket_silo = null
				disable_target_cursor()
				
	
	if escape_rocket_countdown > 0:
		escape_rocket_countdown = max(escape_rocket_countdown - delta, 0)
		
	escape_rocket_launch_label.text = "%.0f" % escape_rocket_countdown
	if escape_rocket_countdown <= 0 and not game_over:
		game_over = true
		win_overlay.visible = true
		escape_rocket.disable_collision()
		launch_sound.play(0.5)
		camera.shake(30)
		$GameMusic.stop()
		victory_music.play()
		
		if escape_rocket.health == escape_rocket.max_health:
			special_msg.visible = true
	
	if escape_rocket_countdown <= 0 and game_over and escape_rocket:
		escape_rocket.position -= Vector2(0, 400) * delta
				
func enable_target_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	target_cursor.visible = true

func disable_target_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	target_cursor.visible = false
			
func spawn_chicken(type: int, pos: Vector2) -> void:
	if game_over:
		return
		
	var chicken: Chicken
	
	if type == 1:
		chicken = CHICKEN_SCENE.instantiate()
	elif type == 2:
		chicken = BUFF_CHICKEN_SCENE.instantiate()
	else:
		chicken = CHICKEN_RUNNER_SCENE.instantiate()
	 
	chicken.position = pos
	chicken.set_move_target(base_marker.position)
	
	chicken_container.add_child(chicken)
	
	
func spawn_rocket_projectile(start_pos: Vector2, target_pos: Vector2, hit_callback: Callable) -> void:
	var rocket_projectile: RocketProjectile = ROCKET_SCENE.instantiate()
	rocket_projectile.position = start_pos
	rocket_projectile.set_target_destination(target_pos)
	
	rocket_projectile.on_hit.connect(func():
		spawn_explosion(rocket_projectile.position)
		hit_callback.call()
		rocket_projectile.queue_free()
		explosion_sound.play()
		camera.shake(1.5)
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
		var dist = chicken.position.distance_to(explosion.position)
		chicken.health = max(chicken.health - 800/dist, 0)
		if chicken.health == 0:
			kills += 1
			kill_label.text = str(kills)
			chicken.queue_free()
	
	await delay(explosion.get_effect_duration())
	explosion.queue_free()

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
			
