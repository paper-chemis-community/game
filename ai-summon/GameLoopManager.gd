extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var max_player_num: int
var player_num: int

# 玩家数据字典 [peer_id: {"name": str, "hand": Array, "score": int, "is_ready": bool}]
var players_data: Dictionary = {}
var current_turn: int = 1  # 当前回合数
var current_player_id: int = 1  # 当前行动玩家的 peer_id
var game_started: bool = false
var game_phase: String = "waiting"  # waiting, playing, ended
var deck: Array = []  # 游戏牌组

func create_server(playern: int) -> void:
	max_player_num = playern
	player_num = 1
	
	if peer.create_server(GameManager.port, playern) != OK:
		print("Failed to create server on port: ", GameManager.port)
		return
	
	setup_multiplayer()
	
	# 服务器自己也是玩家
	players_data[1] = {
		"name": "Host",
		"hand": [],
		"score": 0,
		"is_ready": false
	}
	print("Server created on port: ", GameManager.port)

func create_client(ip: String) -> void:
	if peer.create_client(ip, GameManager.port) != OK:
		print("Failed to connect to server: ", ip)
		return
	
	setup_multiplayer()
	print("Connecting to server: ", ip)

func setup_multiplayer() -> void:
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected_to_server() -> void:
	print("Connected to server successfully!")

func _on_connection_failed() -> void:
	print("Failed to connect to server")

func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	add_player(id)
	
	# 如果游戏未开始且达到最大玩家数，询问是否开始游戏
	if !game_started and players_data.size() >= max_player_num:
		check_all_players_ready()

func _on_peer_disconnected(id: int):
	print("Peer disconnected: ", id)
	remove_player(id)
	
	# 如果当前玩家断开，切换到下一个玩家
	if id == current_player_id and game_started:
		next_turn()

func add_player(id: int) -> void:
	# 只有服务器才能添加玩家
	if multiplayer.is_server():
		players_data[id] = {
			"name": "Player_" + str(id),
			"hand": [],
			"score": 0,
			"is_ready": false
		}
		player_num = players_data.size()
		
		# 广播新玩家加入
		broadcast_player_list()
		print("Player added: ", id, " Total players: ", player_num)

func remove_player(id: int) -> void:
	if multiplayer.is_server() and players_data.has(id):
		players_data.erase(id)
		player_num = players_data.size()
		broadcast_player_list()
		print("Player removed: ", id)

# RPC: 设置玩家准备状态
@rpc("any_peer", "call_remote", "reliable")
func set_player_ready(is_ready: bool) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	if players_data.has(peer_id):
		players_data[peer_id]["is_ready"] = is_ready
		broadcast_player_list()
		
		if is_ready:
			check_all_players_ready()

# RPC: 设置玩家名称
@rpc("any_peer", "call_remote", "reliable")
func set_player_name(name: String) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	if players_data.has(peer_id):
		players_data[peer_id]["name"] = name
		broadcast_player_list()

# RPC: 开始游戏（仅主机调用）
@rpc("call_remote", "reliable")
func start_game() -> void:
	if multiplayer.is_server():
		if players_data.size() < 2:
			print("Need at least 2 players to start game")
			return
		
		game_started = true
		game_phase = "playing"
		current_turn = 1
		initialize_deck()
		deal_initial_cards()
		
		# 随机选择第一个玩家
		var player_ids = players_data.keys()
		current_player_id = player_ids[randi() % player_ids.size()]
		
		print("Game started! Current player: ", current_player_id)
		broadcast_game_state()

# 初始化牌组
func initialize_deck() -> void:
	deck = []
	# 这里可以根据 GameManager 中的卡牌列表初始化牌组
	if GameManager.card_list:
		for card_id in GameManager.card_list:
			# 每张卡牌加入多次（根据游戏需求调整）
			for i in range(3):  # 每张卡牌3份
				deck.append(card_id)
	
	# 洗牌
	deck.shuffle()
	print("Deck initialized with ", deck.size(), " cards")

# 发放初始手牌
func deal_initial_cards() -> void:
	var cards_per_player = 5  # 每个玩家初始手牌数
	
	for peer_id in players_data:
		for i in range(cards_per_player):
			if deck.size() > 0:
				var card_id = deck.pop_front()
				players_data[peer_id]["hand"].append(card_id)
	
	broadcast_hands()

# RPC: 抽牌
@rpc("any_peer", "call_remote", "reliable")
func draw_card() -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	
	# 检查是否是该玩家的回合
	if peer_id != current_player_id:
		return
	
	# 检查牌组是否还有牌
	if deck.size() == 0:
		print("Deck is empty!")
		return
	
	var card_id = deck.pop_front()
	players_data[peer_id]["hand"].append(card_id)
	
	print("Player ", peer_id, " drew card: ", card_id)
	broadcast_hands()

# RPC: 打出卡牌
@rpc("any_peer", "call_remote", "reliable")
func play_card(card_index: int, target_player_id: int = -1) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	
	# 检查是否是该玩家的回合
	if peer_id != current_player_id:
		return
	
	# 检查卡牌索引是否有效
	if card_index < 0 or card_index >= players_data[peer_id]["hand"].size():
		return
	
	var card_id = players_data[peer_id]["hand"][card_index]
	
	# 移除手牌中的卡牌
	players_data[peer_id]["hand"].remove_at(card_index)
	
	# 执行卡牌效果
	execute_card_effect(card_id, peer_id, target_player_id)
	
	print("Player ", peer_id, " played card: ", card_id)
	broadcast_hands()
	broadcast_game_state()

# 执行卡牌效果
func execute_card_effect(card_id: int, player_id: int, target_id: int) -> void:
	# 这里根据卡牌ID执行具体效果
	# 示例：简单加分效果
	if players_data.has(player_id):
		players_data[player_id]["score"] += 10
	
	# 可以添加更多复杂的卡牌效果逻辑
	print("Card ", card_id, " effect executed by player ", player_id)

# RPC: 结束回合
@rpc("any_peer", "call_remote", "reliable")
func end_turn() -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	
	if peer_id != current_player_id:
		return
	
	next_turn()

# 切换到下一个玩家
func next_turn() -> void:
	var player_ids = players_data.keys()
	var current_index = player_ids.find(current_player_id)
	
	if current_index != -1:
		current_index = (current_index + 1) % player_ids.size()
		current_player_id = player_ids[current_index]
		current_turn += 1
	
	print("Turn ", current_turn, ". Current player: ", current_player_id)
	broadcast_game_state()

# 检查所有玩家是否都准备好了
func check_all_players_ready() -> void:
	var all_ready = true
	for player_id in players_data:
		if !players_data[player_id]["is_ready"]:
			all_ready = false
			break
	
	if all_ready and players_data.size() >= 2:
		print("All players ready! Starting game...")
		start_game.rpc()

# 广播玩家列表
func broadcast_player_list() -> void:
	update_players_data.rpc(players_data)

# RPC: 更新玩家数据
@rpc("call_remote", "reliable")
func update_players_data(data: Dictionary) -> void:
	players_data = data
	player_num = players_data.size()
	emit_signal("players_updated", players_data)

# 广播游戏状态
func broadcast_game_state() -> void:
	update_game_state.rpc(game_started, game_phase, current_turn, current_player_id)

# RPC: 更新游戏状态
@rpc("call_remote", "reliable")
func update_game_state(started: bool, phase: String, turn: int, current_id: int) -> void:
	game_started = started
	game_phase = phase
	current_turn = turn
	current_player_id = current_id
	emit_signal("game_state_updated", game_started, game_phase, current_turn, current_player_id)

# 广播手牌信息（只发给对应玩家）
func broadcast_hands() -> void:
	for peer_id in players_data:
		send_hand.rpc_id(peer_id, players_data[peer_id]["hand"])
	
	# 发送其他玩家的手牌数量
	var hand_sizes = {}
	for peer_id in players_data:
		hand_sizes[peer_id] = players_data[peer_id]["hand"].size()
	broadcast_hand_sizes.rpc(hand_sizes)

# RPC: 发送手牌
@rpc("call_remote", "reliable")
func send_hand(hand: Array) -> void:
	var peer_id = multiplayer.get_unique_id()
	if players_data.has(peer_id):
		players_data[peer_id]["hand"] = hand
	emit_signal("hand_updated", hand)

# RPC: 广播手牌数量
@rpc("call_remote", "reliable")
func broadcast_hand_sizes(sizes: Dictionary) -> void:
	emit_signal("hand_sizes_updated", sizes)

# RPC: 结束游戏
@rpc("call_remote", "reliable")
func end_game() -> void:
	game_started = false
	game_phase = "ended"
	broadcast_game_state()
	
	# 计算并显示最终得分
	var scores = {}
	for player_id in players_data:
		scores[player_id] = players_data[player_id]["score"]
	
	emit_signal("game_ended", scores)

# 信号定义（需要在编辑器中连接或在其他脚本中连接）
signal players_updated(players: Dictionary)
signal game_state_updated(started: bool, phase: String, turn: int, current_player: int)
signal hand_updated(hand: Array)
signal hand_sizes_updated(sizes: Dictionary)
signal game_ended(scores: Dictionary)