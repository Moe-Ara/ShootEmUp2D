extends Node2D

func _ready():
	pass


func _process(delta):
	pass

static func rotateNode(target:Node2D, mousePosition:Vector2):
	target.rotation = wrapf(target.rotation,-PI,PI)	
	target.rotation=clamp(target.rotation+mousePosition.angle()*0.1,-1.5,1.5)
	
