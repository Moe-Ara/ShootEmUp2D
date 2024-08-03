extends Node2D
const Utils = preload("res://utils.gd")
@export var weaponRotation=rotation
func _ready():	
	pass 


func _process(delta):
	Utils.rotateNode(self,get_local_mouse_position())

