extends Node2D
@export var Enemies : Array=[]
@onready var player = get_owner().get_node("Player")
@onready var whiteSkeleton= preload("res://WhiteSkeleton.tscn")
@onready var blueSkeleton= preload("res://BlueSkeleton.tscn")
@onready var redSkeleton= preload("res://RedSkeleton.tscn")
var generation_rate

func _ready():
	pass 


func _process(delta):
	pass


	
