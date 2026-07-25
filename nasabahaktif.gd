extends HBoxContainer

@onready var avatar = $avatar
@onready var label_nama = $infokiri/nama
@onready var label_return = $infokiri/return
@onready var label_turn = $turn

var sisa_tenor: int = 4 

func _ready() -> void:
	pass

# nerima data
func isi_data(data: Dictionary) -> void:
	if data.has("path_gambar"):
		avatar.texture = load(data["path_gambar"])
		
	label_nama.text = "ID: " + str(data["id_nasabah"]) + " | " + str(data["tipe_kelas"])
	label_return.text = "Return: +$" + str(data["cicilan_per_turn"]) + "/turn"
	
	# kalau nanti di main.gd ada data "tenor", dia bakal pakai itu,
	# kalau nggak ada, pakai default 4 turn
	if data.has("tenor"):
		sisa_tenor = data["tenor"]
		
	update_teks_turn()

func update_teks_turn() -> void:
	label_turn.text = "Sisa: " + str(sisa_tenor) + " Turn"

# fungsi dipanggil dari main.gd pas ganti turn
func kurangi_turn() -> void:
	sisa_tenor -= 1
	update_teks_turn()
	if sisa_tenor <= 0:
		queue_free() # kalau udah 0, lunas
