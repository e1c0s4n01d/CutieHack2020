extends Control

onready var play = get_node("Play")

func _ready():
	pass

func _on_Play_pressed():
	get_tree().change_scene("res://Game.tscn")
