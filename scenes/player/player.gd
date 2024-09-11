extends CharacterBody2D

# Constantes
const SPEED: float = 50
const STOP_DISTANCE: float = 5

# Variáveis de estado
var direction: Vector2 = Vector2.ZERO
var destination: Vector2 = Vector2.ZERO
var is_moving: bool = false
var current_animation: String = ""
var last_direction: Vector2 = Vector2.ZERO

# Referência ao AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Dicionário para mapear direções às animações
var animation_map = {
    "walk_side_right": {"animation": "walk_side", "flip_h": false},
    "walk_side_left": {"animation": "walk_side", "flip_h": true},
    "walk_front": {"animation": "walk_front", "flip_h": false},
    "walk_back": {"animation": "walk_back", "flip_h": false},
    "idle_side_right": {"animation": "idle_side", "flip_h": false},
    "idle_side_left": {"animation": "idle_side", "flip_h": true},
    "idle_front": {"animation": "idle_front", "flip_h": false},
    "idle_back": {"animation": "idle_back", "flip_h": false}
}

# Função principal de atualização
func _physics_process(delta: float) -> void:
    process_input()
    move_if_needed(delta)
    update_animation_if_needed()
    check_and_stop_if_needed()

# Processa a entrada do usuário
func process_input() -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        update_destination(get_global_mouse_position())

    if Input.is_action_pressed("mv_stop"):
        halt_movement()

# Atualiza o destino do movimento
func update_destination(new_destination: Vector2) -> void:
    destination = new_destination
    is_moving = true

# Para o movimento do jogador
func halt_movement() -> void:
    is_moving = false
    velocity = Vector2.ZERO
    set_idle_animation()

# Calcula a direção do movimento
func calculate_direction() -> void:
    direction = (destination - global_position).normalized()
    velocity = direction * SPEED

# Move o jogador se necessário
func move_if_needed(delta: float) -> void:
    if is_moving:
        calculate_direction()
        perform_movement(delta)

# Realiza o movimento do jogador
func perform_movement(_delta: float) -> void:
    move_and_slide()

# Atualiza a animação se necessário
func update_animation_if_needed() -> void:
    if is_moving:
        determine_animation()

# Determina a animação com base na direção
func determine_animation() -> void:
    if abs(direction.x) > abs(direction.y):
        if direction.x > 0:
            set_animation("walk_side_right")
        else:
            set_animation("walk_side_left")
    else:
        if direction.y > 0:
            set_animation("walk_front")
        else:
            set_animation("walk_back")
    last_direction = direction

# Verifica se o jogador deve parar de se mover
func check_and_stop_if_needed() -> void:
    if is_moving and global_position.distance_to(destination) < STOP_DISTANCE:
        halt_movement()

# Define a animação atual
func set_animation(key: String) -> void:
    var anim_data = animation_map[key]
    current_animation = anim_data["animation"]
    animated_sprite.flip_h = anim_data["flip_h"]
    animated_sprite.play(current_animation)

# Define a animação de idle com base na última direção
func set_idle_animation() -> void:
    if abs(last_direction.x) > abs(last_direction.y):
        if last_direction.x > 0:
            set_animation("idle_side_right")
        else:
            set_animation("idle_side_left")
    else:
        if last_direction.y > 0:
            set_animation("idle_front")
        else:
            set_animation("idle_back")

# Função chamada quando o nó entra na árvore de cena pela primeira vez
func _ready() -> void:
    pass

# Função chamada a cada frame
func _process(delta: float) -> void:
    _physics_process(delta)