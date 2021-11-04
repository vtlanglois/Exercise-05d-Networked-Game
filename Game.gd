extends Spatial

onready var player1pos = $Player1Pos
onready var player2pos = $Player2Pos

func _ready():
	var player1 = preload("res://Player/Player.tscn").instance()
	player1.global_transform = player1pos.global_transform
	add_child(player1)
