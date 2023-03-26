extends Node

class_name Vault

var _network_config
var _vault : Array = []
var _vault_size : int

func _init(network_config : NetworkConfig):
	_network_config = network_config
	_vault_size = _network_config.DEFAULT_VAULT_SIZE
	
func get_by_id(id : String) -> Snapshot:
	for snapshot in _vault:
		if(snapshot.id == id):
			return snapshot

	push_error("Snapshot with id %s not found in vault" % id)
	return null

func clear() -> void:
	_vault = []

func get_latest_snapshot() -> Snapshot:
	if _vault.size() == 0:
		return Snapshot.new()
	else:
		return _vault[_vault.size() - 1]

func get_surrounding_snapshots(time : int) -> Array:
	_vault.sort_custom(Callable(NetworkUtil,"sort_snapshots"))
		
	for i in len(_vault):
		var snapshot = _vault[_vault.size() - 1 - i]
		if snapshot.time <= time:
			return [_vault[_vault.size() - 2 - i], _vault[_vault.size() - 1 - i]]
	return [null, null]

func get_closest_snapshot(time: int) -> Snapshot:
	_vault.sort_custom(Callable(NetworkUtil,"sort_snapshots"))
	for i in len(_vault):
		var before_snapshot = null
		if i > 0:
			before_snapshot = _vault[i - 1]
		var snapshot = _vault[i]
		if(snapshot.time == time):
			return snapshot
		else:
			if before_snapshot != null && time - before_snapshot.time <= snapshot.time:
				return before_snapshot
			else:
				return snapshot
	
	return _vault[_vault.size() - 1]

func add(snapshot : Snapshot) -> void:
	_vault.append(snapshot)
	_vault.sort_custom(Callable(NetworkUtil,"sort_snapshots"))
	if _vault.size() > _vault_size:
		_vault.pop_front()

func size() -> int:
	return _vault.size()

func set_max_size(vault_size : int) -> void:
	_vault_size = vault_size

func max_size() -> int:
	return _vault_size
