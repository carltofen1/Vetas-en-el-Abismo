@tool
extends EditorScript

func _run():
	var img = Image.create(840, 500, false, Image.FORMAT_RGBA8)
	
	# Fondo transparente
	img.fill(Color(0, 0, 0, 0))
	
	# ==========================================
	# 1. PINTAR LAS PAREDES INVISIBLES (ROJO)
	# ==========================================
	for y in range(500):
		# Pared Izquierda (0 a 100)
		for x in range(100):
			img.set_pixel(x, y, Color(1, 0, 0, 0.4))
		# Pared Derecha (740 a 840)
		for x in range(740, 840):
			img.set_pixel(x, y, Color(1, 0, 0, 0.4))
			
	# ==========================================
	# 2. PINTAR LOS PISOS (VERDE)
	# ==========================================
	var pisos_y = [
		Vector2(113, 120), # Piso 4
		Vector2(203, 210), # Piso 3
		Vector2(293, 300), # Piso 2
		Vector2(383, 390)  # Piso 1
	]
	
	for p in pisos_y:
		for y in range(p.x, p.y):
			for x in range(100, 740):
				# Borde negro para distinguir
				if y == p.x or y == p.y - 1:
					img.set_pixel(x, y, Color(0, 0, 0, 1))
				else:
					img.set_pixel(x, y, Color(0, 1, 0, 0.6))
				
	# ==========================================
	# 3. PINTAR LAS ZONAS DE BASE (AZUL)
	# ==========================================
	# Base Roja
	for y in range(357, 383):
		for x in range(118, 182):
			img.set_pixel(x, y, Color(0, 0, 1, 0.6))
			
	# Base Azul
	for y in range(357, 383):
		for x in range(658, 722):
			img.set_pixel(x, y, Color(0, 0, 1, 0.6))

	# ==========================================
	# GUARDAR IMAGEN
	# ==========================================
	img.save_png("res://plantilla_mapa.png")
	print("¡EXITO! Se ha generado el archivo 'plantilla_mapa.png' en la carpeta de tu proyecto.")
