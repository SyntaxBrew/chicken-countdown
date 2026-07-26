extends Area2D

@onready var collision_shape = $CollisionShape2D

@export var health: float = 100
@export var max_health: float = 100
@export var launch_duration: float = 300

signal on_damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(func(body):
		if body is Chicken:
			health = max(health - 1, 0)
			on_damage.emit()
			body.queue_free()
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_collision():
	collision_shape.disabled = true
