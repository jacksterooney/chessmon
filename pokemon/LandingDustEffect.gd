class_name LandingDustEffect
extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()

func _on_LandingDustEffect_animation_finished() -> void:
	queue_free()
