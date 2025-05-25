extends CanvasLayer

func _ready():
    GameManager.connect("score_changed", _on_score_changed)
    $ScoreLabel.text = "Score: 0"

func _on_score_changed(new_score):
    $ScoreLabel.text = "Score: " + str(new_score) 