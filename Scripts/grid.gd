extends Node2D
@onready var deteccion_mouse: Area2D = $"Deteccion Mouse"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
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
	queue_redraw()  # Redibujar la cuadrícula cuando se carga
	crear_diccionario_del_mapa(diccionario_cuadricula_movimientos)
	#botones para ordenar formaciones, es solo debug
	canvas_layer.get_child(0).get_child(0).pressed.connect(ordenar_aliado_arquero)
	canvas_layer.get_child(0).get_child(1).pressed.connect(ordenar_aliado_soldado)
	canvas_layer.get_child(0).get_child(2).pressed.connect(ordenar_enemigo_arquero)
	canvas_layer.get_child(0).get_child(3).pressed.connect(ordenar_enemigo_soldado)
	#print("llamando aliados")
	#get_tree().call_group("Aliados", "grupo_mi_nombre")
	#print("Llamando enemigos")
	#get_tree().call_group("Enemigos", "grupo_mi_nombre")
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

#------------grupos---------------
#Obtiene la lista de unidades divida en bandos, solo usar Aliados y Enemigos
func obtener_lista_de_bando(bando : String) -> Array:
	if bando == "Aliados" or bando == "Enemigos":
		return get_tree().get_nodes_in_group(bando)
	else: 
		print(bando + " no existe en los grupos de bando, error amarillo")
		var error_null = [null]
		return error_null
		
#obtiene la lista de unidades divida en tipos, solo usar Arqueros y Soldados
func obtener_lista_tipo_de_unidad(tipo : String) -> Array:
	if tipo == "Arqueros" or tipo == "Soldados":
		return get_tree().get_nodes_in_group(tipo)
	else:
		print(tipo + " no existe en los grupos de tipo, error amarillo")
		var error_null = [null]
		return error_null

func seleccionar_unidades_de_un_tipo(bando : String, tipo : String):
	#Selecciona las unidades segun su bando (aliado/enemigo) y su tipo (arquero/soldado)
	#Obtiene las listas
	var unidades_del_bando = obtener_lista_de_bando(bando)
	var unidades_del_tipo = obtener_lista_tipo_de_unidad(tipo)
	var unidades_validas = []
	for unidad in unidades_del_bando:
		#Selecciona todas las unidades de X bando
		if unidad in unidades_del_tipo:
			#Filtra las unidades segun su tipo
			unidades_validas.append(unidad)
	#Objetivo de debug
	for i in unidades_validas:
		print(i.name)

#--------------grupos-----------

#---------Debug------------
func ordenar_aliado_soldado():
	seleccionar_unidades_de_un_tipo("Aliados", "Soldados")
func ordenar_aliado_arquero():
	seleccionar_unidades_de_un_tipo("Aliados", "Arqueros")
func ordenar_enemigo_soldado():
	seleccionar_unidades_de_un_tipo("Enemigos", "Soldados")
func ordenar_enemigo_arquero():
	seleccionar_unidades_de_un_tipo("Enemigos", "Arqueros")
#--------debug------------
