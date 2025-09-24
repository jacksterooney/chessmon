extends Control

signal new_game_selected

@onready var select_arrow: TextureRect = $Arrow

var selected_option: int = 0
var option_count: int = 2

func _ready() -> void:
    visible = true
    _set_select_arrow_y_position(selected_option)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_down"):
        selected_option += 1
        _set_select_arrow_y_position(selected_option)
        
    elif event.is_action_pressed("ui_up"):
        if selected_option == 0:
            selected_option = option_count - 1
        else:
            selected_option -= 1
        _set_select_arrow_y_position(selected_option)
    
    elif event.is_action_pressed("interact"):
        if selected_option == 0:
            print("Starting game...")
            visible = false
            new_game_selected.emit()
        elif selected_option == 1:
            print("Quitting game...")
            get_tree().quit()

func _set_select_arrow_y_position(option: int) -> void:
    select_arrow.position.y = 63 + (option % option_count) * 12