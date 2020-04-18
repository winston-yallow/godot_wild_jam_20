extends Particles


func _ready() -> void:
    restart()

func _process(_delta: float) -> void:
    if not emitting:
        queue_free()
