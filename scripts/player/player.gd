extends KinematicBody2D
class_name Player

onready var player_sprite: Sprite = get_node("Texture")
onready var wall_ray: RayCast2D = get_node("WallRay")

var direction: Vector2
var side: int = -1
var jump_count: int = 0
var landing: bool = false
var attacking: bool = false
var crouching: bool = false
var defending: bool = false
var can_track_action: bool = true
var on_wall: bool = false

export(int) var speed
export(int) var jump_force
export(int) var player_gravity
export(int) var wall_impulse_force
export(int) var wall_jump_force
export(int) var player_wall_gravity

func _physics_process(delta: float):
	horizontal_move_env()
	vertical_move_env()
	action_env()
	gravity(delta)
	
	direction = move_and_slide(direction, Vector2.UP)
	
	player_sprite.animate(direction)
	
	
func horizontal_move_env() -> void:
	if not can_track_action: return
	
	var input_direction: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
	direction.x = speed * input_direction
	
	
func vertical_move_env() -> void:
	if not can_track_action: return
	
	if position.y > 400:
		position = Vector2.ZERO
		
	if position.x < 0:
		position.x = 0
	
	if is_on_floor() or is_on_wall():
		jump_count = 0
	
	if Input.is_action_just_pressed("ui_up") and jump_count < 2:
		jump_count += 1
		if close_wall() and not is_on_floor():
			jump_count += 1
			direction.y = wall_jump_force
			direction.x += wall_impulse_force * side
		else:
			direction.y = jump_force
		
		
func action_env() -> void:
	can_track_action = not attacking and not defending and not crouching
	
	if direction.x == 0 and direction.y == 0:
		attack()
		crouch()
		defend()
	
	
func attack() -> void:
	if can_track_action and Input.is_action_just_pressed("attack"):
		attacking = true
		player_sprite.normal_attack = true
		player_sprite.animate(direction)
		
		
func crouch() -> void:
	if Input.is_action_pressed("crouch"):
		crouching = true
		player_sprite.animate(direction)
	else:
		crouching = false
		player_sprite.crouch_off = true
		
		
func defend() -> void:
	if Input.is_action_pressed("defend"):
		defending = true
		player_sprite.animate(direction)
	else:
		defending = false
		player_sprite.shield_off = true
		
		
func gravity(delta: float) -> void:
	if close_wall():
		direction.y += delta * player_wall_gravity

		if direction.y >= player_wall_gravity:
			direction.y = player_wall_gravity
	else:
		direction.y += delta * player_gravity

		if direction.y >= player_gravity:
			direction.y = player_gravity
		
		
func close_wall() -> bool:
	if wall_ray.is_colliding() and not is_on_floor():
		if not on_wall:
			direction.y = 0
			on_wall = true
		
		return true
	else:
		on_wall = false
		return false
