extends Node2D

#------------Referencias--------------
@onready var grid: Node2D = $Grid
var soldado_seleccionado : StaticBody2D
#----------Referencias----------------

func seleccionar_soldado(x : StaticBody2D):
	#Recibe la informacion del soldado que recibio click izquierdo
	#Actualiza todos los booleanos para desactivar y activar movimientos
	if soldado_seleccionado != null: #Para evitar errores
		soldado_seleccionado.set_estoy_seleccionado(false)
	soldado_seleccionado = x
	soldado_seleccionado.set_estoy_seleccionado(true)
func _ready() -> void:
	#Conecta la señal input event desde el Area2D de Grid a este nodo
	grid.deteccion_mouse.input_event.connect(input_event_de_grid)
	
func input_event_de_grid(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			#Si se apreta click derecho ejecuta el codigo
			if soldado_seleccionado != null: #Si no hay ningun soldado seleccionado, saltea el codigo
				soldado_seleccionado.set_estoy_seleccionado(false)
				soldado_seleccionado = null
				#Actualiza al ultimo soldado seleccionado para bloquearle el movimiento
				print("soldado deseleccionado")
