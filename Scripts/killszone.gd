extends Area2D

var _triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	pass  # handled by body_shape_entered

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if _triggered:
		return
	if body.name != "Player":
		return
	_triggered = true

	var GameOver = load("res://Scripts/game_over.gd")
	get_tree().current_scene.add_child(GameOver.new())

func _on_timer_timeout() -> void:
	pass  # timer kept in scene for compatibility; restart handled by game_over.gd
