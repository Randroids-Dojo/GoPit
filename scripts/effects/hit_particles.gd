extends GPUParticles2D
## Hit effect particles - auto-frees after emission


func _ready() -> void:
	emitting = true
	one_shot = true
	# Free after particles are done
	finished.connect(queue_free)
