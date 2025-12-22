extends Control

# perfect ff6d00
# good ffff00
# miss 00b2d4

@onready var label: Label = $Label

func set_text_info(text: String) -> void:
	if label == null:
		label = $Label  # 使用 await 等待一帧
	label.text = text
	match text:
		"PERFECT":
			label.set("theme_override_colors/font_color", Color("ff6d00"))
		"GOOD":
			label.set("theme_override_colors/font_color", Color("ffff00"))
		"MISS":
			label.set("theme_override_colors/font_color", Color("00b2d4"))
		_:
			label.set("theme_override_colors/font_color", Color("00b2d4"))
