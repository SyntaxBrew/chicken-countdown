extends Camera2D

@export var strength = 0
@export var fade = 15

func _process(delta):
	if strength > 0:
		strength = move_toward(strength, 0, strength * delta)

		offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
	else:
		offset = Vector2.ZERO

func shake(amount: float):
	strength = max(strength, amount)
