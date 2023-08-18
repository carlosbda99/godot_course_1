extends Sprite
class_name PlayerTexture

var normal_attack = false
var suffix: String = "_right"
var crouch_off: bool = false
var shield_off: bool = false

onready var player = get_node("../../Player")
onready var animation = get_node("../Animation") 

func animate(direction: Vector2) -> void:
	flip_position(direction)
	
	if player.attacking or player.crouching or player.defending or player.close_wall():
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.landing:
		animation.play("landing")
		player.set_physics_process(false)
	else:
		horizontal_behavior(direction)
		
		
func flip_position(direction: Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "_right"
		player.side = -1
		player.direction = Vector2.ZERO
		player.wall_ray.cast_to = Vector2(5.5, 0)
		
	if direction.x < 0:
		flip_h = true
		suffix = "_left"
		player.side = 1
		player.direction = Vector2(-2,0)
		player.wall_ray.cast_to = Vector2(-7.5, 0)
		
		
func action_behavior() -> void:
	#if player.close_wall():
	#	animation.play("wall_slide")
	#elif player.attacking:
	if player.attacking:
		animation.play("attack" + suffix)
	elif player.crouching and crouch_off:
		animation.play("crouch")
		crouch_off = false
	elif player.defending and shield_off:
		animation.play("shield")
		shield_off = false
		
		
func horizontal_behavior(direction: Vector2) -> void:
	if direction.x != 0:
		animation.play("running")
	else:
		animation.play("idle")
		
		
func vertical_behavior(direction: Vector2) -> void:
	if direction.y > 0:
		animation.play("fall")
		player.landing = true
	elif direction.y < 0:
		animation.play("jump")
		
		
func on_animation_finished(animation_name: String):
	match animation_name:
		"landing":
			player.landing = false
		"attack_left", "attack_right":
			normal_attack = false
			player.attacking = false

	player.set_physics_process(true)
