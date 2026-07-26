extends Node2D

@onready var label_uang = $"Control/Main layout/Panel atas/uang"
@onready var label_turn = $"Control/Main layout/Panel atas/turn"
@onready var label_boss = $"Control/Main layout/Panel atas/boss"
@onready var label_setor = $"Control/Main layout/Panel atas/setor"
@onready var label_queue = $"Control/Main layout/Panel atas/queue"
@onready var container_draft = $"Control/Main layout/PanelContainer/Paneh tengah/Targetlist"
@onready var container_aktif = $"Control/Main layout/list/VBoxContainer/Paneh bawah/PanelContainer/list nasabah"
@onready var middle_sucker_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/middle sucker/middle sucker"
@onready var high_sucker_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/high sucker/high sucker"
@onready var counter_expansion_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/counter expansion/button"
@onready var doomer_influencer_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/doomer influencer/button"
@onready var broken_kneecaps_button = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/broken kneecaps/button"
@onready var middle_sucker_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/middle sucker"
@onready var high_sucker_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/high sucker"
@onready var broken_kneecaps_upgrades = $"Control/Main layout/list/upgrade/MarginContainer/list upgrade/broken kneecap"

var nasabah_scene = preload("res://nasabahcards.tscn")
var active_row_scene = preload("res://nasabahaktif.tscn")

# state
var player_cash: int = 100
var current_turn: int = 0
var deadline: int = 12
var quarter: int = 0
var max_turn: int = 48
var target = [200, 400, 900, 1500]
var boss_goal: int = target[0]
var nasabah_aktif: Array = []
var antrean_nasabah: Array = [] # buat nyimpen 12 calon nasabah per turn
var queue_length: int = 4
var current_on_queue: int = 0
var max_tampil = 2
var weight = [3,0,0]

# modifier upgrade
var bonus_return: int = 0
var bonus_tenor: int = 0
var reduksi_galbay: float = 0.0

# harga upgrade
var harga_up1: int = 50
var harga_up2: int = 50
var harga_up3: int = 50
var harga_up4: int = 50
var harga_up5: int = 50
var harga_counter_expansion = [40, 75]
var harga_middle_sucker = [50, 75, 100]
var harga_high_sucker = [100, 200, 300]
var harga_doomer_influencer = [30, 67, 100, 200]
var harga_broken_kneecap = [75, 140]

# level upgrade
var level_middle_sucker = 0
var level_high_sucker = 0
var level_counter_expansion_sucker = 0
var level_doomer_influencer = 0
var level_broken_kneecaps = 0

# katalog manual
var template_kelas = [
	{
		"tipe": "Low Income",
		"modal_min": 10, "modal_max": 25,
		"bunga_min": 0.15, "bunga_max": 0.25,
		"return_min": 4, "return_max": 7,
		"galbay_min": 0.10, "galbay_max": 0.20,
		"gambar": [
			"res://sprite/low1.png", 
			"res://sprite/low2.png", 
			"res://sprite/low3.png",
			"res://sprite/low4.png",
			"res://sprite/low5.png",
			"res://sprite/low6.png"
			
		]
	}
	,
	{
		"tipe": "Middle Class",
		"modal_min": 40, "modal_max": 80,
		"return_min": 10, "return_max": 18,
		"bunga_min": 0.10, "bunga_max": 0.30,
		"galbay_min": 0.07, "galbay_max": 0.15,
		"gambar": [
			"res://sprite/middle1.png",
			"res://sprite/middle2.png",
			"res://sprite/middle3.png",
			"res://sprite/middle4.png",
			"res://sprite/middle5.png"
		]
	},
	{
		"tipe": "High Income",
		"modal_min": 100, "modal_max": 200,
		"return_min": 25, "return_max": 40,
		"bunga_min": 0.10, "bunga_max": 0.35,
		"galbay_min": 0.05, "galbay_max": 0.10,
		"gambar": [
			"res://sprite/high1.png",
			"res://sprite/high2.png",
			"res://sprite/high3.png",
			"res://sprite/high4.png" 
		]
	}
]

func _ready() -> void:
	update_ui_header()
	# bikin 12 antrean
	generate_antrean_turn(queue_length)

func update_ui_header() -> void:
	label_uang.text = str(player_cash)
	#label_turn.text = "Turn: Week " + str(current_turn) + " / Week " + str(max_turn)
	#label_boss.text = "Boss Goal: $" + str(boss_goal)
	label_setor.text = "Tribute $" + str(boss_goal) + " in " + str(deadline - current_turn) + " week"
	#label_boss.text = "Tribute $" + str(boss_goal)
	#label_turn.text = "in " + str(deadline - current_turn) + " week"
	label_queue.text = str(current_on_queue) + " suckers currently on queue"

# bikin antrean
func generate_antrean_turn(jumlah: int) -> void:
	antrean_nasabah.clear()
	for child in container_draft.get_children():
		child.queue_free()
	
	var class_weight = []
	for i in range(3):
		for j in weight[i]:
			class_weight.append(i)
	for i in range(jumlah):
		#var kelas_terpilih = template_kelas.pick_random()
		var chosen_class = class_weight.pick_random()
		var kelas_terpilih = template_kelas[chosen_class]
		var data_random = {
			"id_nasabah": randi_range(1000, 9999),
			"tipe_kelas": kelas_terpilih["tipe"],
			"modal": randi_range(kelas_terpilih["modal_min"], kelas_terpilih["modal_max"]),
			"bunga": randf_range(kelas_terpilih["bunga_min"], kelas_terpilih["bunga_max"]),
			#"cicilan_per_turn": randi_range(kelas_terpilih["return_min"], kelas_terpilih["return_max"]),
			"peluang_galbay": max(0.01, randf_range(kelas_terpilih["galbay_min"], kelas_terpilih["galbay_max"]) /pow(2, level_broken_kneecaps) ),
			"tenor": 4 + bonus_tenor,
			"path_gambar": kelas_terpilih["gambar"].pick_random()
		}
		data_random["cicilan_per_turn"] = int(ceil(data_random["modal"] * (1 + data_random["bunga"]) / data_random["tenor"])) + bonus_return
		antrean_nasabah.append(data_random) # Masukkan ke dalam antrean
		
	isi_slot_kosong()

func isi_slot_kosong() -> void:
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
		if quarter <= 1:
			kartu_baru.isi_data_no_galbay(data_next)
		else:
			kartu_baru.isi_data(data_next)
		
		current_on_queue = antrean_nasabah.size()
		jumlah_sekarang += 1
		
	current_on_queue = antrean_nasabah.size()
	update_ui_header()
	print("sisa antrean: ", antrean_nasabah.size())

func proses_terima_nasabah(kartu: Node, data: Dictionary) -> void:
	if player_cash >= data["modal"]:
		player_cash -= data["modal"]
		nasabah_aktif.append(data)
		update_ui_header()
		
		var baris_baru = active_row_scene.instantiate()
		container_aktif.add_child(baris_baru)
		
		if quarter <= 1:
			baris_baru.isi_data_no_galbay(data)
		else:
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
	
	var penghutang = get_node("Control/Main layout/list/VBoxContainer/Paneh bawah/PanelContainer/list nasabah")
	for nasabah in penghutang.get_children():
		#var kartu_baru = active_row_scene.instantiate()
		#player_cash += nasabah["cicilan_per_turn"]
		#player_cash += nasabah.data["cicilan_per_turn"]
		if quarter <= 1:
			nasabah.kurangi_turn_no_galbay()
		else:
			nasabah.kurangi_turn()
	
	for i in range(len(nasabah_aktif) - 1, -1, -1):
		var nasabah = nasabah_aktif[i]
		if nasabah.has("is_galbay") and nasabah["is_galbay"] == true:
			nasabah_aktif.remove_at(i)
			continue
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
		new_quarter()
	
	update_ui_header()
	generate_antrean_turn(queue_length)
	
func setor_boss():
	if player_cash < boss_goal:
		print("Game Over")
	else:
		player_cash -= boss_goal
		
func new_quarter():
	if quarter == 4:
		end_game()
	else:
		boss_goal = target[quarter]
		if quarter == 1:
			middle_sucker_upgrades.visible = true
			high_sucker_upgrades.visible = true
		elif quarter == 2:
			broken_kneecaps_upgrades.visible = true
		
func end_game():
	pass

# tombol upgrade

func _on_middle_sucker_pressed() -> void:
	if player_cash >= harga_middle_sucker[level_middle_sucker]:
		player_cash -= harga_middle_sucker[level_middle_sucker]
		weight[1] += 4
		level_middle_sucker += 1
		update_ui_header()
		middle_sucker_button.text ="$" +  str(harga_middle_sucker[level_middle_sucker])
	else:
		print("Duit kurang buat upgrade Middle Sucker")
	if level_middle_sucker == 2:
		middle_sucker_button.disabled = true
		
func _on_high_sucker_pressed() -> void:
	if player_cash >= harga_high_sucker[level_high_sucker]:
		player_cash -= harga_high_sucker[level_high_sucker]
		weight[1] += 5
		level_high_sucker += 1
		update_ui_header()
		high_sucker_button.text ="$" +  str(harga_high_sucker[level_high_sucker])
	else:
		print("Duit kurang buat upgrade High Sucker")
	if level_middle_sucker == 3:
		middle_sucker_button.disabled = true

func _on_counter_expansion_pressed() -> void:
	if player_cash >= harga_counter_expansion[level_counter_expansion_sucker]:
		player_cash -= harga_counter_expansion[level_counter_expansion_sucker]
		max_tampil += 1 
		level_counter_expansion_sucker += 1 
		
		update_ui_header()
		isi_slot_kosong() 
		
		counter_expansion_button.text = "$" + str(harga_counter_expansion[level_counter_expansion_sucker])
	else:
		print("Duit kurang buat upgrade Counter Expansion!")
	
	if level_counter_expansion_sucker == 2:
		counter_expansion_button.disabled = true


#func _on_tombolbeli_2_pressed() -> void:
	#if player_cash >= harga_up2:
		#player_cash -= harga_up2
		#bonus_return += 1
		#harga_up2 += 50
		#update_ui_header()
	#else:
		#print("Duit kurang buat Upgrade 2!")


func _on_doomer_influencer_pressed() -> void:
	if player_cash >= harga_doomer_influencer[level_doomer_influencer]:
		player_cash -= harga_doomer_influencer[level_doomer_influencer]
		queue_length += 2
		level_doomer_influencer += 1
		update_ui_header()
	else:
		print("Duit kurang buat upgrade Doomer Influencer!")
		
	if level_doomer_influencer == 4:
		doomer_influencer_button.disabled = true
		


#func _on_tombolbeli_4_pressed() -> void:
	#if player_cash >= harga_up4:
		#player_cash -= harga_up4
		#bonus_tenor += 1
		#harga_up4 += 50
		#update_ui_header()
	#else:
		#print("Duit kurang buat Upgrade 4!")


func _on_broken_kneecap_pressed() -> void:
	if player_cash >= harga_broken_kneecap[level_broken_kneecaps]:
		player_cash -= harga_broken_kneecap[level_broken_kneecaps]
		level_broken_kneecaps += 1
		update_ui_header()
	else:
		print("Duit kurang buat Upgrade 5!")
	if level_broken_kneecaps == 2:
		broken_kneecaps_button.disabled = true
