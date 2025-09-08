extends Node2D
@onready var deteccion_mouse: Area2D = $"Deteccion Mouse"

const GRID_SIZE := 10  # Tamaño de la cuadrícula (10x10)
const CELL_SIZE := 50  # Tamaño de cada celda (debe coincidir con el de la serpiente)

func _draw() -> void:
	draw_grid()

func draw_grid() -> void:
	var color := Color("#FFF")
	
	# Dibujar líneas verticales
	for x in range(GRID_SIZE + 1):
		var x_pos = x * CELL_SIZE
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, GRID_SIZE * CELL_SIZE), color, 2)

	# Dibujar líneas horizontales
	for y in range(GRID_SIZE + 1):
		var y_pos = y * CELL_SIZE
		draw_line(Vector2(0, y_pos), Vector2(GRID_SIZE * CELL_SIZE, y_pos), color, 2)

func _ready() -> void:
	queue_redraw()  # Redibujar la cuadrícula cuando se carg
