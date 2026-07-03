extends Node

# =====================================================
# ObjectPool.gd - Autoload
# Object Pooling para optimización (GDD v6.0 Cap.12)
# Pre-instancia minerales y proyectiles para evitar
# framerate drops por el Garbage Collector de Godot
# =====================================================

var _pools: Dictionary = {}  # { "nombre": [nodo1, nodo2, ...] }


func crear_pool(nombre: String, escena: PackedScene, cantidad: int) -> void:
	if _pools.has(nombre):
		return  # Ya existe
	
	_pools[nombre] = []
	for i in range(cantidad):
		var instancia = escena.instantiate()
		instancia.set_process(false)
		instancia.set_physics_process(false)
		instancia.visible = false
		# Lo agregamos al árbol pero desactivado
		add_child(instancia)
		_pools[nombre].append(instancia)
	
	print("Pool '", nombre, "' creado con ", cantidad, " instancias.")


func obtener(nombre: String) -> Node:
	if not _pools.has(nombre):
		print("ERROR: Pool '", nombre, "' no existe.")
		return null
	
	for instancia in _pools[nombre]:
		if not instancia.visible:
			instancia.visible = true
			instancia.set_process(true)
			instancia.set_physics_process(true)
			return instancia
	
	# Si no hay disponibles, retornamos null
	# (podríamos expandir el pool aquí si es necesario)
	print("ADVERTENCIA: Pool '", nombre, "' agotado.")
	return null


func devolver(nombre: String, instancia: Node) -> void:
	if not _pools.has(nombre):
		return
	
	instancia.visible = false
	instancia.set_process(false)
	instancia.set_physics_process(false)
	
	# Resetear posición
	if instancia is Node2D:
		instancia.position = Vector2(-9999, -9999)


func contar_disponibles(nombre: String) -> int:
	if not _pools.has(nombre):
		return 0
	
	var count = 0
	for instancia in _pools[nombre]:
		if not instancia.visible:
			count += 1
	return count


func contar_en_uso(nombre: String) -> int:
	if not _pools.has(nombre):
		return 0
	
	var count = 0
	for instancia in _pools[nombre]:
		if instancia.visible:
			count += 1
	return count
