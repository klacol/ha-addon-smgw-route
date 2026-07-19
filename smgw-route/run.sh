#!/usr/bin/with-contenv bashio

# Read configuration
SMGW_NETWORK=$(bashio::config 'smgw_network')
GATEWAY_IP=$(bashio::config 'gateway_ip')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting SMGW Route Manager..."
bashio::log.info "SMGW Network: ${SMGW_NETWORK}"
bashio::log.info "Gateway IP: ${GATEWAY_IP}"

# Find the correct network connection name
bashio::log.info "Searching for network connections..."
CONNECTIONS=$(nmcli -t -f NAME connection show)

if [ -z "$CONNECTIONS" ]; then
    bashio::log.error "No network connections found!"
    exit 1
fi

bashio::log.debug "Available connections: ${CONNECTIONS}"

# Try to find the Supervisor connection
CONNECTION_NAME=""
for conn in $CONNECTIONS; do
    if echo "$conn" | grep -iq "supervisor"; then
        CONNECTION_NAME="$conn"
        bashio::log.info "Found connection: ${CONNECTION_NAME}"
        break
    fi
done

# Fallback: Use the first connection if no Supervisor connection found
if [ -z "$CONNECTION_NAME" ]; then
    CONNECTION_NAME=$(echo "$CONNECTIONS" | head -n 1)
    bashio::log.warning "No Supervisor connection found, using: ${CONNECTION_NAME}"
fi

# Check if route already exists
EXISTING_ROUTES=$(nmcli connection show "${CONNECTION_NAME}" | grep -i "ipv4.routes" || true)
bashio::log.debug "Existing routes: ${EXISTING_ROUTES}"

if echo "$EXISTING_ROUTES" | grep -q "${SMGW_NETWORK}"; then
    bashio::log.info "Route to ${SMGW_NETWORK} already exists"
else
    bashio::log.info "Adding route: ${SMGW_NETWORK} via ${GATEWAY_IP}"
    
    # Add the static route
    if nmcli connection modify "${CONNECTION_NAME}" +ipv4.routes "${SMGW_NETWORK} ${GATEWAY_IP}"; then
        bashio::log.info "Route added successfully"
        
        # Reactivate connection to apply changes
        bashio::log.info "Reactivating connection..."
        if nmcli connection up "${CONNECTION_NAME}"; then
            bashio::log.info "Connection reactivated successfully"
        else
            bashio::log.warning "Failed to reactivate connection, route will be active after reboot"
        fi
    else
        bashio::log.error "Failed to add route"
        exit 1
    fi
fi

# Verify route is active
bashio::log.info "Verifying route..."
if ip route | grep -q "${SMGW_NETWORK}"; then
    bashio::log.info "✅ Route is active and working!"
    ip route | grep "${SMGW_NETWORK}"
else
    bashio::log.warning "Route not yet active in routing table, will be active after connection restart"
fi

# Test connectivity to gateway
bashio::log.info "Testing connectivity to gateway ${GATEWAY_IP}..."
if ping -c 1 -W 2 "${GATEWAY_IP}" > /dev/null 2>&1; then
    bashio::log.info "✅ Gateway ${GATEWAY_IP} is reachable"
else
    bashio::log.warning "⚠️ Gateway ${GATEWAY_IP} is not reachable"
fi

bashio::log.info "SMGW Route Manager configured successfully"
bashio::log.info "Addon will now exit (route persists)"
