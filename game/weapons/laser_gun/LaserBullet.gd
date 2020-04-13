extends Area


var harm = 0.2
var speed = 30
var lifetime = 2.0


func _ready() -> void:
    # warning-ignore:return_value_discarded
    connect('body_entered', self, '_on_body_entered')


func _process(delta: float) -> void:
    translate(Vector3.FORWARD * speed * delta)
    lifetime -= delta
    if lifetime < 0:
        queue_free()


func _on_body_entered(other: PhysicsBody) -> void:
    if other.has_method('damage'):
        other.damage(harm)
    queue_free()

func set_material(mat: Material):
    $Mesh.material_override = mat
