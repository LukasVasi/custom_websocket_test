extends Node

@export var with_custom_api : bool = false

var accum : float = 0.0

func _ready() -> void:
	if OS.get_cmdline_args().has("--server"):
		start_web_game_server()
	else:
		start_web_game_client()


func start_web_game_server() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())

	var web_socket_peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var port : int = 3000
	var error : Error = web_socket_peer.create_server(port)
	
	if error != OK:
		print("[Server] Failed to create a web game server: (%s) %s" % [error, error_string(error)])
	else:
		print("[Server] Successfully created a web game server on port %s" % [port])
		multiplayer.multiplayer_peer = web_socket_peer


func start_web_game_client() -> void:
	if with_custom_api:
		get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	
	var game_peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var server_url : String = "ws://%s:%s" % ["127.0.0.1", 3000]
	var error : Error = game_peer.create_client(server_url)
	if error != OK:
		print("[Client] Failed to create game client: %s" % [error_string(error)])
	else:
		print("[Client] Successfully created game client")
	
	multiplayer.multiplayer_peer = game_peer


func _process(delta: float) -> void:
	if OS.get_cmdline_args().has("--server"):
		accum += delta
		$Map/Visuals.position.y += sin(accum)
