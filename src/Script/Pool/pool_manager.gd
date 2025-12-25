extends Node

"""
全局脚本，对象池管理器
管理游戏中所有的对象池
1. FallingKey
"""

@export var pool_array: Array[PoolResource]

var pool_dictionary: Dictionary[int, Array]


func _ready() -> void:
	for pool in pool_array:
		create_pool(pool.object_scene, pool.pool_size)


"""生成对象"""
func spawn_object(object_scene: PackedScene, position: Vector2) -> Node2D:
	var pool_key: int = object_scene.get_instance_id()
	if pool_dictionary.has(pool_key):
		var object: Node2D = get_from_pool(pool_key)
		object.global_position = position
		return object
	return null


"""从对象池中获取空对象"""
func get_from_pool(pool_key:int) -> Node2D:
	var object:Node2D = pool_dictionary[pool_key].pop_front()
	pool_dictionary[pool_key].append(object)
	object.visible = false
	object.set_process(false)
	object.set_physics_process(false)
	return object


"""创建目标对象的对象池"""
func create_pool(object_scene: PackedScene, pool_size: int):
	var pool_key:int = object_scene.get_instance_id()
	
	# 如果已经存在对象池，直接返回
	if pool_dictionary.has(pool_key):
		return
	
	var parent_node: Node2D = Node2D.new()
	get_tree().current_scene.add_child(parent_node)
	pool_dictionary[pool_key] = []
	for i in range(pool_size):
		var object: Node2D = object_scene.instantiate()
		parent_node.add_child(object)
		object.visible = false
		pool_dictionary[pool_key].append(object)
