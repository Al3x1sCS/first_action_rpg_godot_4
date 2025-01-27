extends CharacterBody2D

# Constantes
const SPEED = 25
const RANDOM_MOVE_INTERVAL = 2.0  # Intervalo para mudar a direção e velocidade aleatoriamente

# Variáveis de estado
var player_chase = false
var player = null
var last_direction = Vector2.ZERO  # Armazena a última direção de movimento
var current_animation = ""

# Variáveis de combate
var player_in_range: bool = false
var attack_cooldown: float = 0.0
var health: int = 100
var is_alive: bool = true
var can_take_damage: bool = true

# Variáveis para movimento aleatório
var random_direction = Vector2.ZERO
var random_speed = 0
var random_move_timer = 0.0

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
    "damage_back": {"animation": "damage_back", "flip_h": false},
    "damage_front": {"animation": "damage_front", "flip_h": false},
    "damage_side_right": {"animation": "damage_side", "flip_h": false},
    "damage_side_left": {"animation": "damage_side", "flip_h": true},
    "death_animation": {"animation": "death_animation", "flip_h": false}
}

func enemy() -> void:
    pass

func deal_with_damage() -> void:
    if player_in_range and global.player_current_attack == true:
        if can_take_damage == true:    
            health = health - 20
            $take_damage_cooldown.start()
            can_take_damage = false
            print("Enemy health: ", health)
            if health <= 0:
                is_alive = false
                health = 0
                set_animation("death_animation")
                self.queue_free()
                print("Enemy is dead!")

func _on_enemy_hitbox_body_entered(_body:Node2D) -> void:
    if _body.has_method("player"):
        player_in_range = true

func _on_enemy_hitbox_body_exited(_body:Node2D) -> void:
    if _body.has_method("player"):
        player_in_range = false

func _on_detection_area_body_entered(_body: Node2D) -> void:
    player = _body
    player_chase = true

func _on_detection_area_body_exited(_body: Node2D) -> void:
    player = null
    player_chase = false

func _on_take_damage_cooldown_timeout() -> void:
    can_take_damage = true

func _physics_process(_delta: float) -> void:
    deal_with_damage()

    if player_chase:
        velocity = (player.position - position).normalized() * SPEED
        last_direction = player.position - position  # Atualiza a última direção de movimento
        set_animation_based_on_direction(last_direction, "attack")
    else:
        move_randomly(_delta)

    position += velocity * _delta

# Função para mover aleatoriamente
func move_randomly(_delta: float) -> void:
    random_move_timer -= _delta
    if random_move_timer <= 0:
        if velocity == Vector2.ZERO:
            # Se estava parado, começa a se mover
            random_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
            random_speed = randf_range(10, SPEED)
            random_move_timer = randf_range(1, RANDOM_MOVE_INTERVAL)  # Tempo aleatório para se mover
            set_animation_based_on_direction(random_direction, "walk")
        else:
            # Se estava se movendo, para
            random_direction = Vector2.ZERO
            random_speed = 0
            random_move_timer = randf_range(0.5, 2.0)  # Tempo aleatório para ficar parado
            set_animation_based_on_direction(last_direction, "idle")

    velocity = random_direction * random_speed

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    _physics_process(_delta)