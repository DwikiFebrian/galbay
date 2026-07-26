extends VBoxContainer

@onready var foto_profil = $fotoprofil
@onready var label_nama_kelas = $namakelas
@onready var label_keuntungan = $keuntungan
@onready var label_probabilitas = $probabilitas

@onready var btn_reject = $HBoxContainer/reject
@onready var btn_accept = $HBoxContainer/accept

var data_nasabah: Dictionary

signal nasabah_diterima(kartu_node: Node, data: Dictionary)
signal nasabah_ditolak(kartu_node: Node)

func _ready() -> void:
	pass

func isi_data(data: Dictionary) -> void:
	data_nasabah = data 

	label_nama_kelas.text = "ID: " + str(data["id_nasabah"]) + " | " + str(data["tipe_kelas"])
	label_keuntungan.text = "Modal: $" + str(data["modal"]) + "  ->  Return: +$" + str(data["cicilan_per_turn"]) + "/turn"

	var persen_galbay = int(data["peluang_galbay"] * 100)
	label_probabilitas.text = "Risiko Galbay: " + str(persen_galbay) + "%"
	
	if data.has("path_gambar"):
		foto_profil.texture = load(data["path_gambar"])

func isi_data_no_galbay(data: Dictionary) -> void:
	data_nasabah = data 

	label_nama_kelas.text = "ID: " + str(data["id_nasabah"]) + " | " + str(data["tipe_kelas"])
	label_keuntungan.text = "Modal: $" + str(data["modal"]) + "  ->  Return: +$" + str(data["cicilan_per_turn"]) + "/week"

	#var persen_galbay = int(data["peluang_galbay"] * 100)
	#label_probabilitas.text = "Risiko Galbay: " + str(persen_galbay) + "%"
	
	if data.has("path_gambar"):
		foto_profil.texture = load(data["path_gambar"])
	
func _on_accept_pressed() -> void:
	nasabah_diterima.emit(self, data_nasabah)

func _on_reject_pressed() -> void:
	nasabah_ditolak.emit(self)
