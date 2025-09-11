extends Node2D
@onready var deteccion_mouse: Area2D = $"Deteccion Mouse"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@export var GRID_SIZE : float = 10  # Tamaño de la cuadrícula (10x10)
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

func cambiar_formacion(bando : String, tipo : String):
	var unidades_a_mover = []
	var coordenada_y : int
	var filas_a_ocupar = [] #Eje Y
	var grid_impar : bool
	var ubicaciones_a_ocupar = []
	var comodin_ubicaciones_a_ocupar = []
	var mitad_del_grid = ceil(GRID_SIZE/2) #La mitad del grid redondeado hacia arriba
	if int(GRID_SIZE) % 2 == 0: #Averigua si el grid es impar o par
		#Tiene un +1 porque al empezar en 0, lo impar es par y viceversa.
		grid_impar = false
	else:
		grid_impar = true
	if bando == "Aliados":
		coordenada_y = 5
	else:
		coordenada_y = 4
	unidades_a_mover = seleccionar_unidades_de_un_tipo(bando, "Soldados").duplicate()
	if unidades_a_mover.size() > GRID_SIZE:
		for cantidad in range(1,ceil(unidades_a_mover.size() / GRID_SIZE)):
			#Cuenta la cantidad de filas que hay que ocupar
			filas_a_ocupar.append(cantidad)
	else:
		filas_a_ocupar.append(1)
	print("filas a ocupar: " + str(filas_a_ocupar))
	print("Mitad del grid: "+str(mitad_del_grid))
	for eje_y in filas_a_ocupar:
		for eje_x in mitad_del_grid:
			if bando == "Aliados":
				if !grid_impar: #Primero inspecciona los numeros par
					ubicaciones_a_ocupar.append(Vector2(mitad_del_grid + eje_x, 4+eje_y))
					ubicaciones_a_ocupar.append(Vector2(mitad_del_grid - eje_x - 1, 4+eje_y))
				else: #Luego inspecciona los numeros impar
					if eje_x == 0: 
						ubicaciones_a_ocupar.append(Vector2(mitad_del_grid - 1, 4+eje_y))
					else:
						ubicaciones_a_ocupar.append(Vector2(mitad_del_grid + (eje_x - 1), 4+eje_y))
						ubicaciones_a_ocupar.append(Vector2(mitad_del_grid - (eje_x + 1), 4+eje_y))
						
	print("Ubicaciones a ocupar:Vector(Y,X) " + str(ubicaciones_a_ocupar))
	
	for unidad in unidades_a_mover: #Actualiza a las unidades
		var ubicacion_a_moverse = ubicaciones_a_ocupar[0] #Obtiene la proxima ubicacion que debe ocuparse
		ubicaciones_a_ocupar.remove_at(0) #Elimina de la lista la ubicacion que ya fue ocupada
		unidad.abandonando_posicion()#Deja su anterior ubicacion como libre
		unidad.movimiento_desde_formacion(ubicacion_a_moverse)#Activa el movimiento a la nueva ubicacion
		
		
		
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

func seleccionar_unidades_de_un_tipo(bando : String, tipo : String) -> Array:
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
	return unidades_validas
#--------------grupos-----------

#---------Debug------------
func ordenar_aliado_soldado():
	cambiar_formacion("Aliados", "Soldados")
func ordenar_aliado_arquero():
	seleccionar_unidades_de_un_tipo("Aliados", "Arqueros")
func ordenar_enemigo_soldado():
	seleccionar_unidades_de_un_tipo("Enemigos", "Soldados")
func ordenar_enemigo_arquero():
	seleccionar_unidades_de_un_tipo("Enemigos", "Arqueros")
#--------debug------------
