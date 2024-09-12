extends CharacterBody2D

var speed = 25
var player_chase = false
var player = null
var last_direction = Vector2.ZERO  # Armazena a última direção de movimento
var current_animation = ""

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

func _on_detection_area_body_entered(_body: Node2D) -> void:
    player = _body
    player_chase = true

func _on_detection_area_body_exited(_body: Node2D) -> void:
    player = null
    player_chase = false

func _physics_process(_delta: float) -> void:
    if player_chase:
        velocity = (player.position - position).normalized() * speed
        last_direction = player.position - position  # Atualiza a última direção de movimento
        set_animation_based_on_direction(last_direction, "walk")
    else:
        velocity = Vector2.ZERO  # Ou defina uma lógica de movimento padrão
        set_animation_based_on_direction(last_direction, "idle")

    position += velocity * _delta

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