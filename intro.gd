extends Node2D 

@onready var boss_anim = $karakter/boss
@onready var player_anim = $karakter/player

# Tambahkan referensi ke bungkus utama dialog box buat di-hide/show
@onready var dialog_box = $"ui_layer/dialog box" 
@onready var dialog_text = $"ui_layer/dialog box/RichTextLabel"

var dialog_lines: Array = [
	"Listen up! I'm fronting you this seed money.",
	"Get out there and hook as many targets as you can.",
	"Squeeze every last cent out of them...",
	"...and pay me back! Don't make me wait."
]

var current_line: int = 0
var tween: Tween 

var is_dialog_active: bool = false 

func _ready() -> void:
	dialog_box.hide()
	dialog_text.text = ""
	
	player_anim.play("player")
	
	boss_anim.play("walkboss") 
	
	gerakkan_bos()

func gerakkan_bos() -> void:
	var move_tween = get_tree().create_tween()
	
	var target_posisi_x = boss_anim.position.x - 300 
	var durasi_jalan = 2.0 
	
	move_tween.tween_property(boss_anim, "position:x", target_posisi_x, durasi_jalan)
	
	move_tween.tween_callback(bos_sampai)

func bos_sampai() -> void:
	boss_anim.play("idleboss")
	
	dialog_box.show()
	is_dialog_active = true 
	
	tampilkan_dialog()

func tampilkan_dialog() -> void:
	if current_line < dialog_lines.size():
		dialog_text.text = dialog_lines[current_line]
		dialog_text.visible_ratio = 0.0 
		
		tween = get_tree().create_tween()
		var durasi_ngetik = dialog_lines[current_line].length() * 0.05
		tween.tween_property(dialog_text, "visible_ratio", 1.0, durasi_ngetik)
	else:
		get_tree().change_scene_to_file("res://main.tscn")

func _input(event: InputEvent) -> void:
	if not is_dialog_active:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		lanjut_dialog()

func lanjut_dialog() -> void:
	if tween and tween.is_running():
		tween.kill()
		dialog_text.visible_ratio = 1.0
	else:
		current_line += 1
		tampilkan_dialog()
