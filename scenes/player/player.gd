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

# Variáveis de combate
var enemy_in_range: bool = false
var enemy_attack_cooldown: bool = true
var health: int = 100
var player_alive: bool = true

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
    "idle_back": {"animation": "idle_back", "flip_h": false},
    "attack_back": {"animation": "attack_back", "flip_h": false},
    "attack_front": {"animation": "attack_front", "flip_h": false},
    "attack_side_right": {"animation": "attack_side", "flip_h": false},
    "attack_side_left": {"animation": "attack_side", "flip_h": true},
    "death_animation": {"animation": "death", "flip_h": false}
}

func player() -> void:
    pass

# Função principal de atualização
func _physics_process(delta: float) -> void:
    process_input()
    move_if_needed(delta)
    update_animation_if_needed()
    check_and_stop_if_needed()

    if health <= 0:
        player_alive = false
        health = 0
        set_animation("death_animation")
        print("Player is dead!")
        self.queue_free()

# Processa a entrada do usuário
func process_input() -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        update_destination(get_global_mouse_position())

    if Input.is_action_pressed("mv_stop"):
        halt_movement()

# Atualiza o destino do movimento
func update_destination(new_destination: Vector2) -> void:
    if new_destination != global_position:
        destination = new_destination
        is_moving = true

# Para o movimento do jogador
func halt_movement() -> void:
    if is_moving:
        is_moving = false
        velocity = Vector2.ZERO
        set_animation_based_on_direction(last_direction, "idle")

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
func perform_movement(delta: float) -> void:
    move_and_collide(velocity * delta)

# Atualiza a animação se necessário
func update_animation_if_needed() -> void:
    if is_moving:
        set_animation_based_on_direction(direction, "walk")

# Define a animação com base na direção e tipo
func set_animation_based_on_direction(dir: Vector2, type: String) -> void:
    var key: String

    if abs(dir.x) > abs(dir.y):
        if dir.x > 0:
            key = type + "_side_right"
        else:
            key = type + "_side_left"
    else:
        if dir.y > 0:
            key = type + "_front"
        else:
            key = type + "_back"

    if current_animation != key:
        set_animation(key)
        last_direction = dir

# Verifica se o jogador deve parar de se mover
func check_and_stop_if_needed() -> void:
    if is_moving and global_position.distance_to(destination) < STOP_DISTANCE:
        halt_movement()

# Define a animação atual
func set_animation(key: String) -> void:
    if animation_map.has(key):
        var anim_data = animation_map[key]
        current_animation = anim_data["animation"]
        animated_sprite.flip_h = anim_data["flip_h"]
        animated_sprite.play(current_animation)
    else:
        print("Erro: Chave de animação não encontrada - ", key)
        # Defina uma animação padrão ou tome outra ação apropriada
        animated_sprite.play("idle_front")

# Função chamada quando o corpo do jogador entra em contato com outro corpo
func _on_player_hitbox_body_entered(_body:Node2D) -> void:
    if _body.has_method("enemy"):
        enemy_in_range = true

# Função chamada quando o corpo do jogador sai de contato com outro corpo
func _on_player_hitbox_body_exited(_body:Node2D) -> void:
    if _body.has_method("enemy"):
        enemy_in_range = false

func _on_attack_cooldown_timeout() -> void:
    enemy_attack_cooldown = true

func attack() -> void:
    pass

func enemy_attack() -> void:
    if enemy_in_range and enemy_attack_cooldown == true:
        health = health - 20
        enemy_attack_cooldown = false
        $attack_cooldown.start()
        print("Player health: ", health)

# Função chamada quando o nó entra na árvore de cena pela primeira vez
func _ready() -> void:
    pass

# Função chamada a cada frame
func _process(delta: float) -> void:
    _physics_process(delta)
    enemy_attack()
