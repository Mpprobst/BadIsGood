class_name SFXDictionary
extends Resource

@export var footsteps : Array[AudioStream] # any length
@export var surface_impacts : Array[AudioStream] # big, small
@export var flesh_impacts : Array[AudioStream]

func get_rand_footstep():
	return random_clip(footsteps)

func get_rand_impact():
	return random_clip(surface_impacts)
	
func get_rand_flesh():
	return random_clip(flesh_impacts)

func random_clip(list):
	var rng = RandomNumberGenerator.new()
	var idx = rng.randi_range(0,len(list)-1)
	return list[idx]
