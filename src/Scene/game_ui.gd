extends Control

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var combo_label: Label = $CanvasLayer/ComboLabel

var score: int = 0
var combo_count: int = 0

func _ready() -> void:
	Signals.increase_score.connect(_on_increase_score)
	Signals.increase_combo.connect(_on_increase_combo)
	Signals.reset_combo.connect(_on_reset_combo)

func _on_increase_score(incr: int) -> void:
	score += incr
	score_label.text = "%d pts" % score

func _on_increase_combo() -> void:
	combo_count += 1
	combo_label.text = "Combo: %d" % combo_count

func _on_reset_combo() -> void:
	combo_count = 0
	combo_label.text = "Combo: 0"
