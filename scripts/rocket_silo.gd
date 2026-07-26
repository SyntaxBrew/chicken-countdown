extends Area2D
class_name RocketSilo

@onready var countdown_label = $Label

var is_launching: bool = false
var launch_timer: float = 0
var launch_duration: float = 3

const WHOOSH_SOUND = preload("res://assets/whoosh.mp3")
@onready var launch_sound = $AudioStreamPlayer2D

#var launch_target_pos
var mouse_over = false

signal on_launch_finished
signal on_selected

func _ready() -> void:
	self.mouse_entered.connect(func():
		mouse_over = true
	)
	
	self.mouse_exited.connect(func():
		mouse_over = false	
	)

func _process(delta: float) -> void:
	if is_launching:
		launch_timer += delta
		countdown_label.text = "%.1f" % (launch_duration - launch_timer)
		
		if launch_timer >= launch_duration:
			is_launching = false
			launch_timer = 0
			countdown_label.visible = false
			#launch_target_pos = null 
			on_launch_finished.emit()
			launch_sound.play(0.3)
			
func launch(target_pos: Vector2) -> void:
	is_launching = true
	countdown_label.visible = true
	#launch_target_pos = target_pos
	launch_timer = 0
			
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_selected.emit(self)
			
