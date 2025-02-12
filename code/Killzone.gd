extends Area2D

@onready var timer = $Timer


var dead = false

func _on_body_entered(body):
	dead = true
	print('died')
	Engine.time_scale = 0.5
	var parent = body.get_parent()
	body.die()
	print(parent)
	#body.get_parent().die()
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
