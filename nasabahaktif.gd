extends HBoxContainer

@onready var avatar = $avatar
@onready var label_nama = $infokiri/nama
@onready var label_return = $infokiri/return
@onready var label_turn = $infokanan/turn
@onready var label_peluang_galbay = $infokiri/galbay

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
		
	var tampil_peluang_galbay = round(data["peluang_galbay"]*100)/100
		
	label_nama.text = "[b]ID: " + str(data["id_nasabah"]) + "[/b] | " + str(data["tipe_kelas"])
	label_return.text = "Payback: [color=#33cc33]+$" + str(data["cicilan_per_turn"]) + "/week[/color]"
	label_peluang_galbay.text = "Galbay Risk: [color=#ffcc00]" + str(tampil_peluang_galbay) + "%[/color]"
	
	if data.has("tenor"):
		sisa_tenor = data["tenor"]
	update_teks_turn()

func isi_data_no_galbay(data: Dictionary) -> void:
	data_nasabah = data
	status_galbay = false
	
	if data.has("path_gambar"):
		avatar.texture = load(data["path_gambar"])
		
	label_nama.text = "[b]ID: " + str(data["id_nasabah"]) + "[/b] | " + str(data["tipe_kelas"])
	label_return.text = "Payback: [color=#33cc33]+$" + str(data["cicilan_per_turn"]) + "/week[/color]"
	
	if data.has("tenor"):
		sisa_tenor = data["tenor"]
		
	update_teks_turn()

func update_teks_turn() -> void:
	if status_galbay:
		label_turn.text = "[b][color=#ff3333]LOST (GALBAY)[/color][/b]"
	else:
		label_turn.text = "[b]" + str(sisa_tenor) + "[/b] weeks left"

func kurangi_turn() -> void:
	if status_galbay:
		queue_free() 
		return
		
	var roll_dadu = randf() 
	
	if roll_dadu <= data_nasabah["peluang_galbay"]:
		status_galbay = true
		data_nasabah["is_galbay"] = true 
		
		label_return.text = "[b][color=#ff3333]GALBAY! ($0)[/color][/b]"
		update_teks_turn()
		return 
	
	sisa_tenor -= 1
	update_teks_turn()
	if sisa_tenor <= 0:
		queue_free() 
		
func kurangi_turn_no_galbay() -> void:
	if status_galbay:
		queue_free() 
		return
	
	sisa_tenor -= 1
	update_teks_turn()
	if sisa_tenor <= 0:
		queue_free()
