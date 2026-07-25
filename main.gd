extends Node2D

@onready var label_uang = $"Control/Main layout/Panel atas/uang"
@onready var label_turn = $"Control/Main layout/Panel atas/turn"
@onready var label_boss = $"Control/Main layout/Panel atas/boss"
@onready var label_setor = $"Control/Main layout/Panel atas/setor"
@onready var container_draft = $"Control/Main layout/Paneh tengah/Targetlist"
@onready var container_aktif = $"Control/Main layout/VBoxContainer/Paneh bawah/list nasabah"

var nasabah_scene = preload("res://nasabahcards.tscn")
var active_row_scene = preload("res://nasabahaktif.tscn")

# state
var player_cash: int = 2000
var current_turn: int = 0
var deadline: int = 12
var quarter: int = 1
var max_turn: int = 48
var boss_goal: int = 2000
var nasabah_aktif: Array = []
var antrean_nasabah: Array = [] # buat nyimpen 12 calon nasabah per turn

# katalog manual
var template_kelas = [
	{
		"tipe": "Low Income",
		"modal_min": 10, "modal_max": 25,
		"return_min": 4, "return_max": 7,
		"galbay_min": 0.15, "galbay_max": 0.25,
		"gambar": "res://sprite/low1.png"
	},
	{
		"tipe": "Middle Class",
		"modal_min": 30, "modal_max": 60,
		"return_min": 10, "return_max": 18,
		"galbay_min": 0.05, "galbay_max": 0.10,
		"gambar": "res://sprite/middle1.png"
	},
	{
		"tipe": "High Income",
		"modal_min": 80, "modal_max": 150,
		"return_min": 25, "return_max": 40,
		"galbay_min": 0.01, "galbay_max": 0.05,
		"gambar": "res://sprite/high1.png"
	}
]

func _ready() -> void:
	update_ui_header()
	# bikin 12 antrean
	generate_antrean_turn(12)

func update_ui_header() -> void:
	label_uang.text = str(player_cash)
	#label_turn.text = "Turn: Week " + str(current_turn) + " / Week " + str(max_turn)
	#label_boss.text = "Boss Goal: $" + str(boss_goal)
	label_setor.text = "Tribute $" + str(boss_goal) + " in " + str(deadline - current_turn) + " week"
	#label_boss.text = "Tribute $" + str(boss_goal)
	#label_turn.text = "in " + str(deadline - current_turn) + " week"

# bikin antrean
func generate_antrean_turn(jumlah: int) -> void:
	antrean_nasabah.clear()
	
	for i in range(jumlah):
		var kelas_terpilih = template_kelas.pick_random()
		var data_random = {
			"id_nasabah": randi_range(1000, 9999),
			"tipe_kelas": kelas_terpilih["tipe"],
			"modal": randi_range(kelas_terpilih["modal_min"], kelas_terpilih["modal_max"]),
			"cicilan_per_turn": randi_range(kelas_terpilih["return_min"], kelas_terpilih["return_max"]),
			"peluang_galbay": randf_range(kelas_terpilih["galbay_min"], kelas_terpilih["galbay_max"]),
			"tenor": 4,
			"path_gambar": kelas_terpilih["gambar"]
		}
		antrean_nasabah.append(data_random) # Masukkan ke dalam antrean
		
	isi_slot_kosong()

func isi_slot_kosong() -> void:
	var max_tampil = 4
	var jumlah_sekarang = 0
	
	for child in container_draft.get_children():
		if not child.is_queued_for_deletion():
			jumlah_sekarang += 1
			
	while jumlah_sekarang < max_tampil and antrean_nasabah.size() > 0:
		var data_next = antrean_nasabah.pop_front() 
		
		var kartu_baru = nasabah_scene.instantiate()
		
		kartu_baru.nasabah_diterima.connect(proses_terima_nasabah)
		kartu_baru.nasabah_ditolak.connect(proses_tolak_nasabah)
		
		container_draft.add_child(kartu_baru)
		kartu_baru.isi_data(data_next)
		
		jumlah_sekarang += 1
		
	print("sisa antrean: ", antrean_nasabah.size())

func proses_terima_nasabah(kartu: Node, data: Dictionary) -> void:
	if player_cash >= data["modal"]:
		player_cash -= data["modal"]
		nasabah_aktif.append(data)
		update_ui_header()
		
		var baris_baru = active_row_scene.instantiate()
		container_aktif.add_child(baris_baru)
		baris_baru.isi_data(data) 
		
		kartu.queue_free()
		
		call_deferred("isi_slot_kosong")
	else:
		print("duit kurang")

func proses_tolak_nasabah(kartu: Node) -> void:
	kartu.queue_free()
	call_deferred("isi_slot_kosong")

func _on_nextweek_pressed() -> void:
	print("minggu berganti")
	#bisa kasih code ngitung duit di sini
	
	var penghutang = get_node("Control/Main layout/VBoxContainer/Paneh bawah/list nasabah")
	for nasabah in penghutang.get_children():
		#var kartu_baru = active_row_scene.instantiate()
		#player_cash += nasabah["cicilan_per_turn"]
		#player_cash += nasabah.data["cicilan_per_turn"]
		nasabah.kurangi_turn()
	
	for i in range(len(nasabah_aktif) - 1, -1, -1):
		var nasabah = nasabah_aktif[i]
		player_cash += nasabah["cicilan_per_turn"]
		nasabah["tenor"] -= 1
		if nasabah["tenor"] == 0:
			nasabah_aktif.remove_at(i)
		
	update_ui_header()
	
	current_turn += 1
	if current_turn % 12 == 0:
		setor_boss()
		current_turn = 0
		quarter += 1
	
	update_ui_header()
	
func setor_boss():
	if player_cash < boss_goal:
		print("Game Over")
	else:
		player_cash -= boss_goal
