extends StaticBody
class_name StaticDestructible


signal destroyed

const Explosion := preload('res://effects/Explosion.tscn')

export var health := 100.0


func damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        emit_signal('destroyed')
        var explosion := Explosion.instance()
        get_tree().current_scene.add_child(explosion)
        explosion.global_transform = global_transform
        queue_free()
