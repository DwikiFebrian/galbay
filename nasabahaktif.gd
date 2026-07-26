extends HBoxContainer

@onready var avatar = $avatar
@onready var label_nama = $infokiri/nama
@onready var label_return = $infokiri/return
@onready var label_turn = $turn

var sisa_tenor: int = 4 
var data_nasabah: Dictionary
var status_galbay: bool = false 

func _ready() -> void:
	pass

# nerima data
func isi_data(data: Dictionary) -> void:
	data_nasabah = data
	status_galbay = false
	
	if data.has("path_gambar"):
		avatar.texture = load(data["path_gambar"])
		
	label_nama.text = "ID: " + str(data["id_nasabah"]) + " | " + str(data["tipe_kelas"])
	label_return.text = "Return: +$" + str(data["cicilan_per_turn"]) + "/turn"
	
	if data.has("tenor"):
		sisa_tenor = data["tenor"]
		
	update_teks_turn()

func update_teks_turn() -> void:
	if status_galbay:
		label_turn.text = "LOST"
		label_turn.add_theme_color_override("font_color", Color(1, 0, 0)) 
	else:
		label_turn.text = "Sisa: " + str(sisa_tenor) + " Turn"

func kurangi_turn() -> void:
	if status_galbay:
		queue_free() 
		return
		
	var roll_dadu = randf() 
	
	if roll_dadu <= data_nasabah["peluang_galbay"]:
		status_galbay = true
		data_nasabah["is_galbay"] = true 
		
		label_return.text = "GALBAY! ($0)"
		label_return.add_theme_color_override("font_color", Color(1, 0, 0))
		update_teks_turn()
		return 
	
	sisa_tenor -= 1
	update_teks_turn()
	if sisa_tenor <= 0:
		queue_free() 
