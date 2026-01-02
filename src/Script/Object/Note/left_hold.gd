class_name LeftHold
extends BaseNote

@onready var tail: Sprite2D = $Tail
@onready var body: Sprite2D = $Body
@onready var head: Sprite2D = $Head

var duration: float
var total_length: float


func _ready() -> void:
	_build_sprite()


func _process(_delta: float) -> void:
	if current_time > timestamp + duration + DEAD_TIMESTAMP:
		timeout.emit(self)


func init_config(data: Dictionary) -> void:
	super.init_config(data)
	duration = data.get("duration")
	total_length = duration * speed


func _build_sprite() -> void:
	var head_w: float = head.texture.get_width() - head.offset.x
	var body_w: float = body.texture.get_width()
	var tail_w: float = tail.texture.get_width()
	var body_length: float = max(0.0, total_length - head_w - tail_w)
	body.position = Vector2(head_w, 0)
	body.scale.x = body_length / body_w
	tail.position = Vector2(
			head_w + body_w * body.scale.x, 0
		)
	tail.scale = Vector2.ONE
