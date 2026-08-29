extends Node2D

var player := Vector2(768.0, 850.0)
var speed := 280.0
var clues: Array[int] = []
var message := "Busca las pistas. Acércate y pulsa E."
var message_time := 0.0
var won := false

var clue_objects = [
    {"pos": Vector2(270, 260), "title": "CEREALES", "text": "Encontraste el número 2.", "part": "2"},
    {"pos": Vector2(1230, 300), "title": "LIMPIEZA", "text": "Encontraste el número 7.", "part": "7"},
    {"pos": Vector2(1160, 730), "title": "CAJA", "text": "Encontraste el número 4.", "part": "4"}
]

var door_pos := Vector2(768, 150)
var interact_was_down := false

func _ready() -> void:
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    if won:
        queue_redraw()
        return

    # Controles directos: no dependen de Input Map.
    var dir := Vector2.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        dir.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        dir.y += 1.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        dir.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        dir.x += 1.0

    if dir.length() > 0.0:
        player += dir.normalized() * speed * delta

    player.x = clamp(player.x, 80.0, 1456.0)
    player.y = clamp(player.y, 220.0, 880.0)

    var e_down := Input.is_key_pressed(KEY_E)
    if e_down and not interact_was_down:
        interact()
    interact_was_down = e_down

    if Input.is_key_pressed(KEY_ESCAPE):
        get_tree().change_scene_to_file("res://Main.tscn")

    if message_time > 0.0:
        message_time -= delta

    queue_redraw()

func interact() -> void:
    if player.distance_to(door_pos) < 145.0:
        if clues.size() == 3:
            won = true
            message = "¡¡ESCAPASTE!! Código: 274"
        else:
            message = "La salida está cerrada. Te faltan %d pistas." % (3 - clues.size())
        message_time = 3.0
        return

    for i in range(clue_objects.size()):
        var obj = clue_objects[i]
        if player.distance_to(obj.pos) < 120.0:
            if not clues.has(i):
                clues.append(i)
                message = "%s — %s" % [obj.title, obj.text]
            else:
                message = "Ya investigaste este objeto."
            message_time = 3.0
            return

    message = "No hay nada que investigar aquí."
    message_time = 1.5

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1536, 1024), Color("#171a1f"))
    draw_rect(Rect2(45, 45, 1446, 934), Color("#303840"))

    # Entrada / techo
    draw_rect(Rect2(45, 45, 1446, 160), Color("#15181d"))
    draw_string(ThemeDB.fallback_font, Vector2(85, 115), "SUPERMERCADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(85, 160), "ESCAPE ROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("#e1ae45"))

    # Puerta
    draw_rect(Rect2(680, 80, 176, 120), Color("#173126"))
    draw_rect(Rect2(680, 80, 176, 120), Color("#5fe28a"), false, 5)
    draw_string(ThemeDB.fallback_font, Vector2(716, 135), "SALIDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#76f0a0"))
    draw_string(ThemeDB.fallback_font, Vector2(694, 173), "PUERTA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

    # Estantes
    _shelf(Rect2(80, 330, 430, 120), "PASILLO 1")
    _shelf(Rect2(1025, 330, 430, 120), "PASILLO 2")
    _shelf(Rect2(80, 500, 430, 120), "PASILLO 3")
    _shelf(Rect2(1025, 500, 430, 120), "PASILLO 4")

    # Objetos / pistas
    for i in range(clue_objects.size()):
        var obj = clue_objects[i]
        var found = clues.has(i)
        var c = Color("#626d77") if found else Color("#e0a63b")
        draw_circle(obj.pos, 30, c)
        draw_circle(obj.pos, 30, Color.WHITE, false, 3)
        draw_string(ThemeDB.fallback_font, obj.pos + Vector2(-8, 9), "✓" if found else "?",
            HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color.WHITE)
        draw_string(ThemeDB.fallback_font, obj.pos + Vector2(-60, 55), obj.title,
            HORIZONTAL_ALIGNMENT_LEFT, 130, 15, Color.WHITE)

    # Player
    draw_circle(player, 25, Color("#45b8ff"))
    draw_circle(player, 25, Color.WHITE, false, 3)

    # HUD
    draw_rect(Rect2(55, 900, 1426, 65), Color("#0c0e12"))
    draw_string(ThemeDB.fallback_font, Vector2(75, 930),
        "WASD / FLECHAS = MOVER     E = INVESTIGAR     ESC = MENÚ",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#cbd2da"))
    draw_string(ThemeDB.fallback_font, Vector2(75, 957),
        message, HORIZONTAL_ALIGNMENT_LEFT, 1050, 20, Color.WHITE)

    draw_rect(Rect2(1170, 65, 300, 95), Color("#0c0e12"))
    draw_string(ThemeDB.fallback_font, Vector2(1190, 102),
        "PISTAS: %d / 3" % clues.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#e9bd55"))
    draw_string(ThemeDB.fallback_font, Vector2(1190, 138),
        "CÓDIGO: " + ("".join(_code_parts()) if clues.size() > 0 else "???"),
        HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color.WHITE)

    if won:
        draw_rect(Rect2(250, 300, 1036, 350), Color("#090b0d"))
        draw_rect(Rect2(250, 300, 1036, 350), Color("#65e593"), false, 6)
        draw_string(ThemeDB.fallback_font, Vector2(0, 420), "¡¡ESCAPASTE!!",
            HORIZONTAL_ALIGNMENT_CENTER, 1536, 60, Color("#72ef9d"))
        draw_string(ThemeDB.fallback_font, Vector2(0, 485),
            "Encontraste todas las pistas.", HORIZONTAL_ALIGNMENT_CENTER, 1536, 28, Color.WHITE)
        draw_string(ThemeDB.fallback_font, Vector2(0, 540),
            "Código: 274", HORIZONTAL_ALIGNMENT_CENTER, 1536, 34, Color("#e9bd55"))
        draw_string(ThemeDB.fallback_font, Vector2(0, 600),
            "Pulsa ESC para volver al menú.", HORIZONTAL_ALIGNMENT_CENTER, 1536, 21, Color("#cccccc"))

func _code_parts() -> Array[String]:
    var result: Array[String] = []
    for i in clues:
        result.append(clue_objects[i].part)
    return result

func _shelf(r: Rect2, title: String) -> void:
    draw_rect(r, Color("#20262c"))
    draw_rect(r, Color("#6b7782"), false, 3)
    draw_string(ThemeDB.fallback_font, r.position + Vector2(18, 30), title,
        HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
    for j in range(3):
        var x = r.position.x + 18 + j * 135
        draw_rect(Rect2(x, r.position.y + 52, 110, 50), Color("#52606a"))
