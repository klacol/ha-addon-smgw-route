#!/usr/bin/with-contenv bashio

# Read configuration
SMGW_NETWORK=$(bashio::config 'smgw_network')
GATEWAY_IP=$(bashio::config 'gateway_ip')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting SMGW Route Manager..."
bashio::log.info "SMGW Network: ${SMGW_NETWORK}"
bashio::log.info "Gateway IP: ${GATEWAY_IP}"

# Function to add route
add_route() {
    bashio::log.info "Adding route: ${SMGW_NETWORK} via ${GATEWAY_IP}"
    
    if ip route add "${SMGW_NETWORK}" via "${GATEWAY_IP}"; then
        bashio::log.info "✅ Route added successfully"
        return 0
    else
        bashio::log.error "Failed to add route"
        return 1
    fi
}

# Function to check if route exists
check_route() {
    if ip route | grep -q "^${SMGW_NETWORK} via ${GATEWAY_IP}"; then
        return 0
    else
        return 1
    fi
}

# Main loop - keep addon running and maintain route
while true; do
    # Check if route exists
    if check_route; then
        bashio::log.debug "Route to ${SMGW_NETWORK} is active"
    else
        bashio::log.warning "Route not found, adding it..."
        if ! add_route; then
            bashio::log.error "Failed to add route, will retry in 60 seconds"
            sleep 60
            continue
        fi
    fi
    
    # Verify route is active
    if ip route | grep -q "${SMGW_NETWORK}"; then
        bashio::log.debug "✅ Route is active: $(ip route | grep "${SMGW_NETWORK}")"
    fi
    
    # Test connectivity to gateway (only every 5 minutes to reduce log spam)
    if [ ! -f /tmp/last_ping ] || [ $(($(date +%s) - $(cat /tmp/last_ping))) -gt 300 ]; then
        bashio::log.info "Testing connectivity to gateway ${GATEWAY_IP}..."
        if ping -c 1 -W 2 "${GATEWAY_IP}" > /dev/null 2>&1; then
            bashio::log.info "✅ Gateway ${GATEWAY_IP} is reachable"
        else
            bashio::log.warning "⚠️ Gateway ${GATEWAY_IP} is not reachable"
        fi
        date +%s > /tmp/last_ping
    fi
    
    # Check route every 60 seconds
    sleep 60
done
