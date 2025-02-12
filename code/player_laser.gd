extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var player_laser = $"."
@onready var hitbox = $Hitbox
@onready var disappear = $Disappear

var speed
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
func _ready():
	set_as_top_level(true)
	disappear.start()

func _physics_process(delta):
	position += (Vector2.RIGHT*speed) * delta
	var overlapping_obj = hitbox.get_overlapping_areas()
	for obj in overlapping_obj:
		var parent  = obj.get_parent()
		print(parent.name)
		var damage = 25
		parent.hit(damage)
		queue_free()

func _on_disappear_timeout():
	queue_free()
	disappear.stop()
