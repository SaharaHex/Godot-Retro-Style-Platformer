extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var activate_fall = $ActivateFall
@onready var activate_jump = $ActivateJump
@onready var Right_att_1 = $Right_Att1
@onready var left_att_1 = $Left_Att1
@onready var hit_delay = $Hit_Delay
@onready var reset_timer = $"Reset Timer"
@onready var quick_hit_delay = $Quick_Hit_Delay
@onready var laser_delay = $Laser_Delay
@onready var main = get_tree().get_root().get_node("MainGame")
@onready var projectile = load("res://scenes/player_laser.tscn")
@onready var player = $"."
@onready var collision = $CollisionShape2D
@onready var tp_len = $TP_Len
@onready var hit_timer = $Hit_Timer
@onready var collision_shape_2d = $CollisionShape2D
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/Hitbox_Shape

var att1dmg = 45
var att2dmg = 100
var shotdmg = 25
var direction = 0
var dead = false
var death_animation = false
var SPEED = 250.0
const JUMP_VELOCITY = -300.0
var att_animation_run = false
var tped = false
var hit_out = false
var health = 100
var last_direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var PlayerAttacking = false
@export var Attack_Type = 0

func _process(delta):
	if dead == false or PlayerAttacking == false:
		if Input.is_action_just_pressed("Melee1"):
			PlayerAttacking = true
			quick_hit_delay.start()
			Attack_Type = 1
		if Input.is_action_just_released("Melee1"):
			PlayerAttacking = false
			Attack_Type = 0
			att_animation_run = false
		if Input.is_action_just_pressed("Melee2"):
			PlayerAttacking = true
			hit_delay.start()
			Attack_Type = 2
		if Input.is_action_just_released("Melee2"):
			PlayerAttacking = false
			Attack_Type = 0
			att_animation_run = false
		if Input.is_action_just_pressed("Laser"):
			PlayerAttacking = true
			laser_delay.start()
			Attack_Type = 3
		if Input.is_action_just_released("Laser"):
			PlayerAttacking = false
			Attack_Type = 0
			att_animation_run = false
			

func attack1():
	if PlayerAttacking == true and dead == false:
		if animated_sprite.flip_h == false:
			var overlapping_obj = Right_att_1.get_overlapping_areas()
			for obj in overlapping_obj:
				var parent  = obj.get_parent()
				print(parent.name)
				var damage = att1dmg
				parent.hit(damage)
			Attack_Type = 1
		if animated_sprite.flip_h == true and dead == false:
			var overlapping_obj = left_att_1.get_overlapping_areas()
			for obj in overlapping_obj:
				var parent  = obj.get_parent()
				print(parent.name)
				var damage = att1dmg
				parent.hit(damage)
			Attack_Type = 1
func attack2():
	if PlayerAttacking == true and dead == false:
		if animated_sprite.flip_h == false:
			var overlapping_obj = Right_att_1.get_overlapping_areas()
			for obj in overlapping_obj:
				var parent  = obj.get_parent()
				print(parent.name)
				var damage = att2dmg
				parent.hit(damage)
			Attack_Type = 2
		if animated_sprite.flip_h == true and dead == false:
			var overlapping_obj = left_att_1.get_overlapping_areas()
			for obj in overlapping_obj:
				var parent  = obj.get_parent()
				print(parent.name)
				var damage = att2dmg
				parent.hit(damage)
			Attack_Type = 2
func shoot():
	if dead == false:
		var instance = projectile.instantiate()
		if animated_sprite.flip_h:
			instance.speed = -200
		else:
			instance.speed = 200
		instance.global_position = collision.global_position + Vector2(0,-21)
		add_child(instance)

func _physics_process(delta):
	if dead:
		if death_animation == false:
			animated_sprite.play("Death")
			death_animation = true
		velocity.x = 0
		velocity.y = 400
	elif health <= 0:
		die()
	elif PlayerAttacking:
		if att_animation_run == false:
			if Attack_Type == 1:
				animated_sprite.play("Attack1")
				velocity.x = direction * (SPEED-300)
				velocity.y += gravity
			elif Attack_Type == 2:
				animated_sprite.play("Attack2")
				velocity.x = direction * (SPEED-300)
				velocity.y += 400
			elif Attack_Type == 3:
				animated_sprite.play("Laser")
				velocity.x = direction * (SPEED-300)
				velocity.y += 300
			att_animation_run = true
	elif hit_out == true:
		animated_sprite.play("Hit")
		velocity.x = -last_direction * 300
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		if Input.is_action_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var direction = Input.get_axis("Move Left", "Move Right")
		if direction == 1 or direction == -1:
			last_direction = direction
		if direction:
			velocity.x = direction * SPEED
			if Input.is_action_just_pressed("TP_Left"):
				direction = -1
				velocity.x = direction * (SPEED + 5000)
				print("TP")
			if Input.is_action_just_pressed("TP_Right"):
				direction = 1
				velocity.x = direction * (SPEED + 5000)
				print("TP")
			if direction < -0.1:
				animated_sprite.flip_h = true
				
			else:
				animated_sprite.flip_h = false

		else:
			if Input.is_action_just_pressed("TP_Left"):
				direction = -1
				velocity.x = direction * (SPEED*6)
				print("TP")
			if Input.is_action_just_pressed("TP_Right"):
				direction = 1
				velocity.x = direction * (SPEED*5)
				print("TP")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if PlayerAttacking == false:
			if direction == 0:
				animated_sprite.play("idle")
			elif is_on_floor() == false:
				animated_sprite.play("jump")
			else:
				animated_sprite.play("Run")
			if activate_jump.is_colliding() == false:
				animated_sprite.play("jump")
			if activate_fall.is_colliding() == false:
				animated_sprite.play("Fall")
	move_and_slide()

func hit(damage):
	if dead == false:
		print("Player HIT")
		animated_sprite.play("Hit")
		hit_out = true
		hit_timer.start()
		health = health - damage
		PlayerAttacking = false
		print(health)
		hitbox_shape.set_process(false)
func die():
	print("DIED Animation")
	dead = true
	reset_timer.start()
	PlayerAttacking = false
	
func speed_collection():
	SPEED += 25

func _on_hit_delay_timeout():
	attack2()
	hit_delay.stop()

func _on_reset_timer_timeout():
	get_tree().reload_current_scene()

func _on_quick_hit_delay_timeout():
	attack1()
	quick_hit_delay.stop()

func _on_laser_delay_timeout():
	shoot()
	laser_delay.stop()

func _on_hit_timer_timeout():
	hit_out = false
	hitbox_shape.set_process(false)
