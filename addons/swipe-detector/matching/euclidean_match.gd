extends "res://addons/swipe-detector/matching/gesture_match.gd"


const EuclideanSimilarityAlgorithm = preload("res://addons/swipe-detector/matching/euclidean_similarity_algorithm.gd")


func _init(sample, pattern, threshold).(sample, pattern, threshold):
  pass

func similarity_algorithm():
  return EuclideanSimilarityAlgorithm.new()
