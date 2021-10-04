extends KinematicBody2D

signal hit(bullet_id)
var direction = Vector2()
var velocity = Vector2()
export (int) var speed = 100

func _physics_process(delta):
	direction = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	direction = direction.normalized()
	var _speed = speed * 60
	if Input.is_action_pressed("ui_cancel"):
		_speed *= 0.5
	velocity = direction * _speed * delta
	var _c = move_and_slide(velocity)


func _on_Bullet_Hitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	emit_signal("hit", area_shape)
