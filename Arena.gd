extends Node2D

onready var bullet_spawner_area = $BulletSpawnerArea
onready var bullet_spawn_pos = $ArenaCenter/BulletSpawn
onready var bullet_spawn_dir = $ArenaCenter/BulletSpawn/Dir
onready var timer = $Timer

export var bullet_spawn_speed := 0.4 setget _timer_set
export var bullet_count := 5
export var bullet_speed := 100
export var bullet_speed_angle := 0
export var bullet_spawn_spread := PI/2

export var pattern_speed := 1.0

var boundary_rect: Rect2
var hits = 0

func _ready() -> void:
	# Here we register the boundary
	boundary_rect = Rect2(
		$BulletBounds.rect_position,
		$BulletBounds.rect_size
	)
	bullet_spawner_area.set_bounding_box(boundary_rect)
	$BulletAnimation.play("main", -1, pattern_speed)

func _timer_set(bullet_spawn_speed):
	if timer:
		timer.wait_time = bullet_spawn_speed / pattern_speed

# Spawn a bullet wave with a slightly different rotation
func _on_Timer_timeout() -> void:
	var rotation_difference = bullet_spawn_spread / (bullet_count - 1)
	var spawn_vector = bullet_spawn_pos.global_position.direction_to(bullet_spawn_dir.global_position)
	for i in range(0, bullet_count):
		var movement = spawn_vector.rotated(
			rotation_difference * i - PI/4
		)
		bullet_spawner_area.spawn_bullet(
			bullet_spawn_pos.global_position,
			movement,
			bullet_speed * pattern_speed,
			bullet_speed_angle
		)


func _on_Player_hit(bullet_id):
	bullet_spawner_area.delete_bullet(bullet_id)
	hits += 1
	$HitCount.text = "Hits: " + str(hits)
	$Player.modulate.a = 0.3
	yield(get_tree().create_timer(.1), "timeout")
	$Player.modulate.a = 0.7
	yield(get_tree().create_timer(.1), "timeout")
	$Player.modulate.a = 0.3
	yield(get_tree().create_timer(.1), "timeout")
	$Player.modulate.a = 1.0
