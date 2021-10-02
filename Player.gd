extends KinematicBody2D

var direction = Vector2()
var velocity = Vector2()
export (int) var speed = 100

func _physics_process(_delta):
	direction = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	direction = direction.normalized()
	var _speed = speed
	if Input.is_action_pressed("ui_cancel"):
		_speed *= 0.5
	velocity = direction * _speed
	move_and_slide(velocity)
