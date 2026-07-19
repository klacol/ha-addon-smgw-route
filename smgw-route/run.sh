#!/usr/bin/with-contenv bashio

# Read configuration
SMGW_NETWORK=$(bashio::config 'smgw_network')
GATEWAY_IP=$(bashio::config 'gateway_ip')
SMGW_IP=$(bashio::config 'smgw_ip')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting SMGW Route Manager..."
bashio::log.info "SMGW Network: ${SMGW_NETWORK}"
bashio::log.info "Gateway IP: ${GATEWAY_IP}"
bashio::log.info "SMGW IP: ${SMGW_IP}"

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
    
    # Test connectivity to gateway and SMGW (only every 5 minutes to reduce log spam)
    if [ ! -f /tmp/last_ping ] || [ $(($(date +%s) - $(cat /tmp/last_ping))) -gt 300 ]; then
        # Show routing table in debug mode
        bashio::log.debug "Current routing table:"
        bashio::log.debug "$(ip route)"
        
        bashio::log.info "Testing connectivity to gateway ${GATEWAY_IP}..."
        GATEWAY_PING_OUTPUT=$(ping -c 1 -W 2 "${GATEWAY_IP}" 2>&1)
        if [ $? -eq 0 ]; then
            bashio::log.info "✅ Gateway ${GATEWAY_IP} is reachable"
            bashio::log.debug "Ping result: ${GATEWAY_PING_OUTPUT}"
        else
            bashio::log.warning "⚠️ Gateway ${GATEWAY_IP} is not reachable"
            bashio::log.debug "Ping output: ${GATEWAY_PING_OUTPUT}"
        fi
        
        bashio::log.info "Testing connectivity to SMGW ${SMGW_IP}..."
        SMGW_PING_OUTPUT=$(ping -c 1 -W 2 "${SMGW_IP}" 2>&1)
        if [ $? -eq 0 ]; then
            bashio::log.info "✅ SMGW ${SMGW_IP} is reachable"
            bashio::log.debug "Ping result: ${SMGW_PING_OUTPUT}"
        else
            bashio::log.warning "⚠️ SMGW ${SMGW_IP} is not reachable - check GL.iNet connection!"
            bashio::log.debug "Ping output: ${SMGW_PING_OUTPUT}"
            
            # Additional debug information when SMGW is not reachable
            bashio::log.debug "Checking route to SMGW network:"
            bashio::log.debug "$(ip route get ${SMGW_IP} 2>&1)"
            
            bashio::log.debug "ARP table:"
            bashio::log.debug "$(ip neigh show)"
            
            bashio::log.debug "Network interfaces:"
            bashio::log.debug "$(ip addr show)"
        fi
        
        date +%s > /tmp/last_ping
    fi
    
    # Check route every 60 seconds
    sleep 60
done
