extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	play()

func _on_GrassStepEffect_animation_finished():
	queue_free()
