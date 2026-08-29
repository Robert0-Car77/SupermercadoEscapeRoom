extends Control

@onready var message: Label = $Message

func _ready() -> void:
    $PlayButton.pressed.connect(_on_play_pressed)
    $ContinueButton.pressed.connect(_on_continue_pressed)
    $OptionsButton.pressed.connect(_on_options_pressed)
    $ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
    get_tree().change_scene_to_file("res://Game.tscn")

func _on_continue_pressed() -> void:
    message.text = "No hay una partida guardada todavía."

func _on_options_pressed() -> void:
    message.text = "OPCIONES — Próximamente: sonido, pantalla y controles."

func _on_exit_pressed() -> void:
    get_tree().quit()
