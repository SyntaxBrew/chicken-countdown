extends TextureRect

var t = randf() * 2

func _ready() -> void:
	self.pivot_offset = self.size / 2

func _process(delta: float) -> void:
	t += delta
	self.scale = Vector2(0.5 * cos(t) + 1.3, 0.5 * cos(t) + 1.3)
	self.rotation += (PI / 360)
