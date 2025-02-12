extends Area2D

@onready var collision = $CollisionShape2D
@onready var player = $"../../../Player"



func _on_body_entered(body):
	collision.queue_free()
	visible = false
	player.speed_collection()
