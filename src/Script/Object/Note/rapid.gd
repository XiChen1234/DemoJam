class_name Rapid
extends BaseNote

@onready var sprite_2d: Sprite2D = $Sprite2D

var duration: float
var total_length: float

func _ready() -> void: 
	_build_sprite()


func _process(_delta: float) -> void:
	if current_time > timestamp + duration + DEAD_TIMESTAMP:
		expired.emit(self)


func init_config(data: Dictionary) -> void:
	super(data)
	duration = data.get("duration")
	total_length = duration * speed
	#print("length: %f" % total_length)


func _build_sprite() -> void:
	var width: float = sprite_2d.texture.get_width()
	#print("segment_length: %f" % width)
	var offset: float = sprite_2d.offset.x
	var count: int = ceil((total_length - width) / (width - offset)) + 1
	#print("count: %f" % count)
	for i in range(count - 1):
		var item: Sprite2D = sprite_2d.duplicate()
		item.position += Vector2(i * 100, 0)
		add_child(item)
