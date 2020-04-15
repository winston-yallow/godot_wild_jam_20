extends StaticBody
class_name StaticDestructible


signal destroyed

export var health := 100.0


func damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        emit_signal('destroyed')
        queue_free()
