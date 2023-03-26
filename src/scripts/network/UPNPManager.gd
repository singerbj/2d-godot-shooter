extends Node


class_name UPNPManager

# Emitted when UPnP port mapping setup is completed successfully.
signal upnp_completed_success()
# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed_failure(error)

var thread = null
var _network_config

func _init(network_config : NetworkConfig):
	_network_config = network_config

func upnp_setup(server_port : int, max_players : int):
#	thread = Thread.new()
#	thread.start(Callable(self,"_upnp_setup").bind([ server_port, max_players ]))
	_upnp_setup([ server_port, max_players ])

func _upnp_setup(user_data : Array):
	var server_port = user_data[0]
	var max_players = user_data[1]
	
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover(_network_config.DEFAULT_UPNP_DISCOVERY_TIMEOUT_MS)

	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed_failure", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		emit_signal("upnp_completed_success", server_port, max_players)

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
