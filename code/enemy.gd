extends CharacterBody2D


var speed = 100.0
const JUMP_VELOCITY = -200.0
var direction = 1
var dead  = false
@onready var animated_sprite = $EnemyAnimations
@onready var fall = $Fall
@onready var wall = $Wall
@onready var wall_jump = $Wall_Jump
@onready var hitbox = $Hitbox
@onready var spot_enemy_1 = $SpotEnemy1
@onready var spot_enemy_2 = $SpotEnemy2
@onready var attack_area = $Attack_Area
@onready var timer = $Timer
@onready var game_manager = $"../../GameManager"
@onready var hit_cooldown = $Hit_Cooldown
@onready var health_bar = $HealthBar

var attdmg = 50
var health = 100
var hit_out = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 1
var sprite_right = false
var attacked = false
var in_area = false
func _physics_process(delta):
	update_healthbar()
	if dead == true:
		velocity.y = 400
		move_and_slide()
	elif dead == false:
		if health <= 0:
			die()
		if spot_enemy_1.is_colliding():
			velocity.x = (speed + 50) * direction 
		elif spot_enemy_2.is_colliding():
			flip()
			velocity.x = (speed + 50) * direction 
		if not is_on_floor():
			velocity.y += gravity * delta
		if (fall.is_colliding() == false) && is_on_floor():
			flip()
		if (wall.is_colliding()) && is_on_floor():
			flip()
		if (wall_jump.is_colliding()) && is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = speed * direction
		move_and_slide()
		

func flip():
	sprite_right= !sprite_right

	scale.x = abs(scale.x) * -1
	if sprite_right:
		speed = abs(speed) * -1
	else:
		speed = abs(speed)
func die():
	if hitbox != null:
		hitbox.queue_free()
	animated_sprite.play("Death")
	dead = true
	velocity.y = 400
	game_manager.add_kill()
	$Hitbox.queue_free()
	$Hitbox/Collision_Hitbox.queue_free()
func hit(damage):
	if dead == false:
		animated_sprite.play("Hit")
		hit_out = true
		health = health - damage
		print(health)
		hit_cooldown.start()
	
func _on_attack_area_body_entered(body):
	if dead == false:
		if direction == -1 or direction == 1:
			last_direction = direction
		animated_sprite.play("Idle")
		direction = 0
		timer.start()
func attack():
		animated_sprite.play("Attack")
		var overlapping_obj = attack_area.get_overlapping_areas()
		for obj in overlapping_obj:
			var parent  = obj.get_parent()
			print(parent.name)
			var damage = attdmg
			parent.hit(damage)
		timer.stop()
func _on_timer_timeout():
	if dead == false :
		if attacked == false and hit_out == false:
			attack()
			attacked = true
			timer.stop()



func _on_attack_area_body_exited(body):
	if dead == false:
		direction = last_direction
		animated_sprite.play("Run")
		attacked = false
		timer.stop()
		in_area = false

func _on_hit_cooldown_timeout():
	if dead == false:
		animated_sprite.play("Run")
		hit_out = false
	
func update_healthbar():
	health_bar.value = health
