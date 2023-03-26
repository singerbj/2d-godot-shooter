class_name NetworkConfig

# Network
var DEFAULT_SERVER_PORT : int = 56969
var DEFAULT_MAXIMUM_CONNECTIONS : int = 4
var DEFAULT_DO_PNP : bool = false

# Vault
var DEFAULT_VAULT_SIZE : int = 40

# Snapshot Interpolation
var DEFAULT_AUTO_CORRECT_TIME_SERVER_OFFSET : bool = false
var DEFAULT_AUTO_CORRECT_TIME_CLIENT_OFFSET : bool = true
var DEFAULT_INTERPOLATION_BUFFER_MULTIPLIER : int = 3 #TODO: the OG value was 3. not sure what this does or if it is needed
var DEFAULT_MAX_TIME_OFFSET_MS : int = 50 #TODO: put this back to a reasonable number, originally it was 50ms

# UPNP
var DEFAULT_UPNP_DISCOVERY_TIMEOUT_MS : int = 15000

# InputManager
var DEFAULT_INPUT_BUFFER_MAX_SIZE : int = 20
