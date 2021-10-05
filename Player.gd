extends KinematicBody2D

export (int) var speed = 100

signal hit(bullet_id)

onready var player_sprite = $player
onready var bullet_area = $Bullet_Area
onready var graze_area = $Graze_Area
onready var graze_sprite = $graze

var direction = Vector2()
var velocity = Vector2()

var invincibility = 0

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

	position = position.round() # faked pixel snap

	if invincibility > 0:
		graze_sprite.modulate.a = 0.0
#		if not grazing.empty(): # Grazing ain't happening
#			graze_sprite.modulate.a = 0.0
		invincibility -= delta
		if int(invincibility*10) % 2 == 0:
			player_sprite.modulate.a = 0.3
		else:
			player_sprite.modulate.a = 0.5
	else:
		player_sprite.modulate.a = 1.0
#		if graze_sprite.modulate.a > 0.5:
		graze_sprite.modulate.a -= delta


func start_invincibility(seconds):
	invincibility = seconds

func _on_Bullet_Hitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	emit_signal("hit", area_shape)


func _on_Graze_Hitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	if area == bullet_area or invincibility > 0:
		return
#	graze_sprite.modulate.a = 1.0
#	$GrazeSound.stop()
#	$GrazeSound.play()

func _on_Graze_Area_area_shape_exited(area_id, area, area_shape, local_shape):
	if area == bullet_area:
		return
