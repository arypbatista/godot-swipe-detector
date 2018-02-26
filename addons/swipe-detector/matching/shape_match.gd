extends "res://addons/swipe-detector/matching/gesture_match.gd"


const ShapeSimilarityAlgorithm = preload("res://addons/swipe-detector/matching/shape_similarity_algorithm.gd")


# Don't use yet, lot of false possitives

func _init(sample, pattern, threshold).(sample, pattern, threshold):
	pass

func similarity_algorithm():
	return ShapeSimilarityAlgorithm.new()

func points(gesture):
	return gesture.get_points()
