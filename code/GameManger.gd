extends Node

var score = 0
var kills = 0
@onready var label = $"../Player/Camera2D/Label"

func add_score():
	score += 1
	label.text = " Kills : " + str(score) +"/11"
	print(score)
func add_kill():
	kills += 1
	label.text = " Kills : " + str(kills) +"/11"
	print(kills)
		
