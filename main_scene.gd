extends Node2D
@onready var players: Node = $Players
const PLAYER = preload("res://player.tscn")
var peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("starting a server");
		_on_create_button_down()
		print("successful");
		
## 创建服务器
func _on_create_button_down() -> void:
	#创建监听的服务器,即创建了一个地址为 127.0.0.1:7788 的服务器
	var error = peer.create_server(7788)
	if error != OK:
		printerr("创建服务器失败, 错误码", error)
		return
	multiplayer.multiplayer_peer = peer
	
	# 作为服务端，需要监听是否有别的客户端进行连接
	multiplayer.peer_connected.connect(_on_peer_connected)
	# 客户端创建成功后，在当前场景添加玩家
	# multiplayer.get_unique_id()用于获取当前客户端的唯一id，作为服务器的客户端，一般id均为1

func add_player(id: int) -> void:
	var player = PLAYER.instantiate()
	player.name = str(id)
	players.add_child(player)

## 当有新的客户端连接时，该方法会被触发, 该方法只有主机端会被触发！
func _on_peer_connected(id: int) -> void:
	print("有玩家连接，ID为",id)
	# 添加新玩家
	add_player(id)
	pass

## 创建客户端并连接服务器
func _on_join_button_down() -> void:
	$UI/IP.select_all()
	var ip=$UI/IP.get_selected_text()
	# 创建客户端并连接ip为127.0.0.1:7788的服务器
	peer.create_client(str(ip), 7788)
	multiplayer.multiplayer_peer = peer
