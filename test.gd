extends Node

const SERVER_PORT : int = 3000

enum PeerType {
	WebSocket,
	ENet,
}

@export var peer_type : PeerType = PeerType.WebSocket
@export var with_custom_api : bool = false
@export var added_later_scene : PackedScene

@onready var _initially_in_tree_visuals : Sprite2D = $InitiallyInTree/Visuals
var _added_later_visuals : Sprite2D = null
var _accum : float = 0.0

func _ready() -> void:
	if OS.get_cmdline_args().has("--server"):
		if peer_type == PeerType.WebSocket:
			start_websocket_server()
		else:
			start_enet_server()
	else:
		if peer_type == PeerType.WebSocket:
			start_websocket_client()
		else:
			start_enet_client()


func start_websocket_server() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	
	add_child(added_later_scene.instantiate())
	_added_later_visuals = $AddedLater/Visuals

	var web_socket_peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var error : Error = web_socket_peer.create_server(SERVER_PORT)
	
	if error != OK:
		print("[Server] Failed to create a web socket server: (%s) %s" % [error, error_string(error)])
	else:
		print("[Server] Successfully created a web socket server")
		multiplayer.multiplayer_peer = web_socket_peer


func start_enet_server() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	
	add_child(added_later_scene.instantiate())
	_added_later_visuals = $AddedLater/Visuals

	var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error : Error = enet_peer.create_server(SERVER_PORT)
	
	if error != OK:
		print("[Server] Failed to create a enet game server: (%s) %s" % [error, error_string(error)])
	else:
		print("[Server] Successfully created an enet server")
		multiplayer.multiplayer_peer = enet_peer


func start_websocket_client() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	
	add_child(added_later_scene.instantiate())
	_added_later_visuals = $AddedLater/Visuals
	
	var game_peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var server_url : String = "ws://%s:%s" % ["127.0.0.1", SERVER_PORT]
	var error : Error = game_peer.create_client(server_url)
	if error != OK:
		print("[Client] Failed to create websocket client: %s" % [error_string(error)])
	else:
		print("[Client] Successfully created a websocket client")
	
	multiplayer.multiplayer_peer = game_peer


func start_enet_client() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	
	add_child(added_later_scene.instantiate())
	_added_later_visuals = $AddedLater/Visuals
	
	var game_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error : Error = game_peer.create_client("127.0.0.1", SERVER_PORT)
	if error != OK:
		print("[Client] Failed to create enet client: %s" % [error_string(error)])
	else:
		print("[Client] Successfully created an enet client")
	
	multiplayer.multiplayer_peer = game_peer


func _process(delta: float) -> void:
	if OS.get_cmdline_args().has("--server"):
		_accum += delta
		_initially_in_tree_visuals.position.y += sin(_accum)
		if _added_later_visuals != null:
			_added_later_visuals.position.y += sin(_accum)
