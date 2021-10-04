# Original code by ericdsw
# as part of the https://github.com/ericdsw/bullet_spawner_test demo
extends Node2D

export (Array, Image) var frames
export (float) var image_change_offset = 0.2
export (float) var max_lifetime = 10.0

onready var shared_area := get_node("SharedArea") as Area2D

onready var max_images = frames.size()

var bullets : Array = []
var bounding_box : Rect2

# ================================ Lifecycle ================================ #

func _exit_tree() -> void:
	for bullet in bullets:
		Physics2DServer.free_rid((bullet as Bullet).shape_id)
	bullets.clear()

func _physics_process(delta: float) -> void:
	
	var used_transform = Transform2D()
	var bullets_queued_for_destruction = []
	
	for i in range(0, bullets.size()):
		
		var bullet = bullets[i] as Bullet
		
		if (
			!bounding_box.has_point(bullet.current_position) or
			bullet.lifetime >= max_lifetime
		):
			bullets_queued_for_destruction.append(bullet)
			continue

		var offset : Vector2 = (
			bullet.movement_vector.normalized() * bullet.speed * delta
		)
		
		# Move the bullet and the collision
		bullet.current_position += offset
		used_transform.origin = bullet.current_position
		Physics2DServer.area_set_shape_transform(
			shared_area.get_rid(), i, used_transform
		)
		
		bullet.animation_lifetime += delta
		bullet.lifetime += delta
		bullet.movement_vector = bullet.movement_vector.rotated(bullet.movement_rotation * delta)
	
	for bullet in bullets_queued_for_destruction:
		Physics2DServer.free_rid(bullet.shape_id)
		bullets.erase(bullet)
	
	update()

func _draw() -> void:
	var offset = frames[0].get_size() / 2.0
	for i in range(0, bullets.size()):
		var bullet = bullets[i]
		if bullet.animation_lifetime >= image_change_offset:
			bullet.image_offset += 1
			bullet.animation_lifetime = 0.0
			if bullet.image_offset >= max_images:
				bullet.image_offset = 0
		draw_texture(
			frames[bullet.image_offset], 
			bullet.current_position - offset
		)

# ================================= Public ================================== #

# Bullets outside these bounds will be deleted
func set_bounding_box(box: Rect2) -> void:
	bounding_box = box

# Register a new bullet in the array with the optimization logic
func spawn_bullet(i_position: Vector2, i_movement: Vector2, speed := 200, movement_rotation := 0.0) -> void:
	
	var bullet : Bullet = Bullet.new()
	bullet.movement_vector = i_movement
	bullet.movement_rotation = movement_rotation
	bullet.speed = speed
	bullet.current_position = i_position
	
	_configure_collision_for_bullet(bullet)
	
	bullets.append(bullet)
	
# Adds the collision data to the bullet
func _configure_collision_for_bullet(bullet: Bullet) -> void:
	
	# Define the shape's position
	var used_transform := Transform2D(0, position)
	used_transform.origin = bullet.current_position
	  
	# Create the shape
	var _circle_shape = Physics2DServer.circle_shape_create()
	Physics2DServer.shape_set_data(_circle_shape, 4)

	# Add the shape to the shared area
	Physics2DServer.area_add_shape(
		shared_area.get_rid(), _circle_shape, used_transform
	)
	
	# Register the generated id to the bullet
	bullet.shape_id = _circle_shape

func delete_bullet(area_shape: int) -> void:
	var rid = Physics2DServer.area_get_shape(shared_area.get_rid(), area_shape)
	for bullet in bullets:
		if bullet.shape_id == rid:
			Physics2DServer.free_rid(bullet.shape_id)
			bullets.erase(bullet)
