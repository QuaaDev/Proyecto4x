extends Node2D
@onready var deteccion_mouse: Area2D = $"Deteccion Mouse"

@export var GRID_SIZE := 10  # Tamaño de la cuadrícula (10x10)
@export var CELL_SIZE := 50  # Tamaño de cada celda (debe coincidir con el de la serpiente)

var diccionario_cuadricula_movimientos : Dictionary
#Diccionario que almacena una cuadricula del mapa actual, la clave es el Vector2 
#de la cuadricula, el dato es un booleano que almacena si esa casilla esta ocupada o no
#{Vector2(1,1) : false, 1: true} 
#True si la casilla esta libre, false si esta ocupada
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
	crear_diccionario_del_mapa(diccionario_cuadricula_movimientos)

func crear_diccionario_del_mapa(diccionario_a_llenar : Dictionary) -> void:
	#Crea y carga el diccionario con valores
	for y in GRID_SIZE+1: #Eje y
		for x in GRID_SIZE+1:#Eje x
			diccionario_a_llenar[Vector2(x,y)] = true
			
func solicitar_movimiento(posicion : Vector2) -> bool:
	#-----------importante-------------
	#Esta funcion debe de recibir siempre la posicion a la que quiere ir, no la actual
	#-----------importante-------------
	#Convierte la posicion global a la posicion local que utiliza el diccionario
	#Divide la posicion en pixeles por el tamaño de las cuadriculas
	var posicion_local = Vector2((posicion.x / CELL_SIZE),(posicion.y/CELL_SIZE))
	#Si la posicion local supera los limites del grid, se cancela el movimiento
	if (posicion_local.x > GRID_SIZE or posicion_local.x < 0) or (posicion_local.y >= GRID_SIZE or posicion_local.y < 0):
		return false
	#Si la posicion del diccionario esta libre (true), vuelve valido el movimiento y marca la casilla
	#como ocupada (false)
	elif diccionario_cuadricula_movimientos[posicion_local] == true:
		actualizar_diccionario_movimiento(posicion_local,false)
		return true
	#Si la casilla esta ocupada (false), cancela el movimiento
	else:
		#print("PATATA")
		return false

#Actualiza el diccionario con nueva informacion
func actualizar_diccionario_movimiento(posicion : Vector2, valor : bool) -> void:
	diccionario_cuadricula_movimientos[posicion] = valor
func coso():
	#print(diccionario_cuadricula_movimientos)
	pass
