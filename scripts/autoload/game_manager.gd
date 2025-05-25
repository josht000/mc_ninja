extends Node

signal game_paused(is_paused: bool)
signal score_changed(new_score: int)

var current_score: int = 0
var high_score: int = 0
var is_paused: bool = false

func pause_game():
    is_paused = !is_paused
    get_tree().paused = is_paused
    emit_signal("game_paused", is_paused)

func add_score(points: int):
    current_score += points
    if current_score > high_score:
        high_score = current_score
    emit_signal("score_changed", current_score)

func reset_score():
    current_score = 0
    emit_signal("score_changed", current_score) 