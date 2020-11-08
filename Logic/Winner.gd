extends Control

onready var _return = get_node("Return")

func _ready():
	pass

func _on_Return_pressed():
	print("yo?")
	get_tree().change_scene("res://Menu.tscn")
