class_name PoolManager
extends Node


@export var pool_array: Array[PoolResource]

var pool_dictionary: Dictionary[int, Array] # 对象池字典，场景id：实例数组
var scene_from_key: Dictionary[int, PackedScene] # 场景映射，场景id：实际场景
var parent_dictionary: Dictionary[int, Node2D] # 父节点映射，场景id：父节点

static var current: PoolManager = null

func _enter_tree() -> void:
	PoolManager.current = self

func _exit_tree() -> void:
	if PoolManager.current == self:
		PoolManager.current = null


func _ready() -> void:
	for pool in pool_array:
		create_pool(pool.object_scene, pool.pool_size)


"""回收对象"""
func recycle(object:Node2D) -> void:
	object.visible = false
	object.set_process(false)
	object.set_physics_process(false)


"""激活对象"""
func active(object: Node2D) -> void:
	object.visible = true
	object.set_process(true)
	object.set_physics_process(true)


"""生成对象"""
func spawn_object(object_scene: PackedScene, position: Vector2) -> Node2D:
	var pool_key: int = object_scene.get_instance_id()
	if pool_dictionary.has(pool_key):
		var object: Node2D = get_from_pool(pool_key)
		object.global_position = position
		return object
	return null


"""
从对象池中获取空对象
若所有对象的visible都为true，则扩展一个
"""
func get_from_pool(pool_key:int) -> Node2D:
	for object: Node2D in pool_dictionary[pool_key]:
		if not object.visible:
			return object
	
	return expand_pool(pool_key) 


"""对象池容量不足，扩展"""
func expand_pool(pool_key: int) -> Node2D:
	var scene = scene_from_key[pool_key]
	var object: Node2D = create_objet(scene)
	pool_dictionary[pool_key].append(object)
	parent_dictionary[pool_key].add_child(object)
	return object


"""创建对象池"""
func create_pool(object_scene: PackedScene, pool_size: int):
	var pool_key: int = object_scene.get_instance_id()
	if pool_dictionary.has(pool_key):
		return
	
	var parent_node: Node2D = Node2D.new()
	parent_dictionary[pool_key] = parent_node
	get_tree().current_scene.add_child.call_deferred(parent_node)
	pool_dictionary[pool_key] = []
	scene_from_key[pool_key] = object_scene
	for i in range(pool_size):
		var object: Node2D = create_objet(object_scene)
		parent_node.add_child(object)
		pool_dictionary[pool_key].append(object)
		


"""生成空对象"""
func create_objet(object_scene: PackedScene) -> Node2D:
		var object: Node2D = object_scene.instantiate()
		recycle(object)
		return object
