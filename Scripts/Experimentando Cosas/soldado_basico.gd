extends StaticBody2D
class_name soldado_basico
#----------Referencias--------------
@onready var nodo_administrador = self.get_parent().get_parent() #Referencia al nodo administrador
@onready var detectar_enemigo: RayCast2D = $DetectarEnemigo
@onready var cd_ataque: Timer = $cd_ataque
@onready var animacion_recibir_daño: Timer = $animacion_recibir_daño

#----------Referencias--------------
var estoy_seleccionado := false
var speed := 3
var direction := Vector2.ZERO
var cell_size := 50 #Tamaño de la cuadricula sobre la cual nos queremos mover
var is_moving := false
var color_original : Color
@export var aliado := true
@export var vida : int = 10
@export var ataque : int = 5
@export var armadura : int = 2
@export var rango_ataque : int = 1
@export var cd_ataque_variable : float = 1.0
@export var sprite_unidad_path : String

func _ready() -> void:
	input_pickable = true #Hace que siempre sea seleccionado por el mouse
	#---------Asignar sprite----------
	#Unicamente hay que colocar un path valido y el codigo hace todo
	if sprite_unidad_path != null:
		var sprite_unidad = Sprite2D.new()
		sprite_unidad.texture = load(sprite_unidad_path)
		sprite_unidad.centered = false
		add_child(sprite_unidad)
	#---------Asignar sprite----------
	#-----------Conectar señales---------
	animacion_recibir_daño.timeout.connect(_on_animacion_recibir_daño_timeout)
	cd_ataque.timeout.connect(cd_ataque_timeout)
	self.input_event.connect(_on_input_event)
	#-----------Conectar señales---------
	#Cambia el collision_layer para diferenciar aliados de enemigos
	#Cambia la collision_mask para detectar siempre a los enemigos de su bando
	#Cambia la direccion a la que apunta el raycast segun el bando junto a su rango con la siguiente formula
	#(tamaño de las celdas * cantidad de celdas que puede atacar)
	#Cambia el color del canvas 
	#Almacena su color original
	if aliado: 
		collision_layer = 1
		detectar_enemigo.collision_mask = 2
		detectar_enemigo.target_position = Vector2(0,-(cell_size*rango_ataque))
		modulate = Color("Blue")
		color_original = Color("Blue")
	else:
		collision_layer = 2
		detectar_enemigo.collision_mask = 1
		detectar_enemigo.target_position = Vector2(0,(cell_size*rango_ataque)) 
		modulate = Color("Green")
		color_original = Color("Green")

func _physics_process(delta):
	#Si el raycast detecta una colision y el ataque esta disponible, ejecuta el ataque
	if detectar_enemigo.is_colliding():
		detectar_enemigo.enabled = false
		cd_ataque.start(cd_ataque_variable)
		detectar_enemigo.get_collider().perder_vida(ataque)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#Si este objeto en particular detecta el click del mouse, ejecuta el codigo
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#Si se hace click izquierdo sobre self, envia su informacion al administrador de soldados
			#Para activar su movimiento
			nodo_administrador.seleccionar_soldado(self)
			#print("Left mouse button clicked!")

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
	
func perder_vida(daño : int) -> void:
	var daño_a_recibir = (daño - armadura) #La armadura reduce el daño
	if daño <= 0: #Si el daño es menor a 1, siempre recibe 1 de daño
		daño_a_recibir = 1
	set_vida(vida - daño_a_recibir) #Aplica el daño
	modulate = Color("Red") #Coloca el color rojo para informar que recibio daño
	animacion_recibir_daño.start() 
	#print(vida)
	
#--------------------Get y Set-------------------

func set_estoy_seleccionado(x : bool) -> void:
	estoy_seleccionado = x

func get_estoy_seleccionado() -> bool:
	return estoy_seleccionado

func get_vida() -> int:
	return vida

func set_vida(x : int) -> void:
	#Si la vida es menor a 1, se elimina el objeto
	if x <= 0:
		queue_free()
	else:
		vida = x
	
func get_ataque() -> int:
	return ataque
	
func set_ataque(x : int) -> void:
	ataque = x
	
func get_armadura() -> int:
	return armadura

func set_armadura(x : int) -> void:
	armadura = x
	
#--------------------Get y Set-------------------


func cd_ataque_timeout() -> void:
	#Al acabar el cd activa el raycast para realizar ataques
	detectar_enemigo.enabled = true


func _on_animacion_recibir_daño_timeout() -> void:
	modulate = color_original
