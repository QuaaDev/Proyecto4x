extends StaticBody2D

#----------Referencias--------------
@onready var nodo_administrador = self.get_parent().get_parent() #Referencia al nodo administrador
#----------Referencias--------------
var estoy_seleccionado := false
var speed := 3
var direction := Vector2.ZERO
var cell_size := 50 #Tamaño de la cuadricula sobre la cual nos queremos mover
var is_moving := false

func _ready() -> void:
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#Si este objeto en particular detecta el click del mouse, ejecuta el codigo
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#Si se hace click izquierdo sobre self, envia su informacion al administrador de soldados
			#Para activar su movimiento
			nodo_administrador.seleccionar_soldado(self)
			print("Left mouse button clicked!")

func _input(event: InputEvent) -> void:
	if estoy_seleccionado: #Activa el movimiento si se selecciona esta unidad
		if is_moving:
			return
		#Movimiento basico del boneco
		if event is InputEventKey and event.pressed and !is_moving:
			if event.keycode == KEY_UP:
				direction = Vector2.UP
			elif event.keycode == KEY_DOWN:
				direction = Vector2.DOWN
			elif event.keycode == KEY_LEFT:
				direction = Vector2.LEFT
			elif event.keycode == KEY_RIGHT:
				direction = Vector2.RIGHT
				
			#Si el movimiento es diferente a cero aplica el movimiento
			if direction != Vector2.ZERO:
				move_to_next_tile()

#Aplica movimiento al objeto
func move_to_next_tile() -> void:
	is_moving = true
	var new_position = position + direction * cell_size
	var tween = create_tween()
	tween.tween_property(self,"position",new_position, 1.0/speed)
	#Objeto a aplicar / propiedad a editar / ubicacion objetivo / velocidad de la animacion
	tween.tween_callback(move_finish)

func move_finish() -> void:
	is_moving = false

#--------------------Get y Set-------------------

func set_estoy_seleccionado(x : bool):
	estoy_seleccionado = x

func get_estoy_seleccionado() -> bool:
	return estoy_seleccionado
	
#--------------------Get y Set-------------------
