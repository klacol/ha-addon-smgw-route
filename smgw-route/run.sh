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
bashio::log.info "Log Level: ${LOG_LEVEL}"

# Show initial routing table for troubleshooting
bashio::log.info "Initial routing table:"
ip route | while read line; do bashio::log.info "  $line"; done

# Function to check if route exists
check_route() {
    # More flexible check - look for network and gateway anywhere in the route
    if ip route show "${SMGW_NETWORK}" | grep -q "via ${GATEWAY_IP}"; then
        return 0
    else
        return 1
    fi
}

# Function to add route
add_route() {
    bashio::log.info "Adding route: ${SMGW_NETWORK} via ${GATEWAY_IP}"
    
    # Try to add the route
    if ip route add "${SMGW_NETWORK}" via "${GATEWAY_IP}" 2>&1 | tee /tmp/route_add_output.txt; then
        bashio::log.info "✅ Route added successfully"
        return 0
    else
        # Check if it failed because route already exists
        if grep -q "File exists" /tmp/route_add_output.txt; then
            bashio::log.info "Route already exists - this is OK"
            return 0
        else
            bashio::log.error "Failed to add route: $(cat /tmp/route_add_output.txt)"
            return 1
        fi
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
        bashio::log.info "Testing connectivity to gateway ${GATEWAY_IP}..."
        if ping -c 1 -W 2 "${GATEWAY_IP}" > /dev/null 2>&1; then
            bashio::log.info "✅ Gateway ${GATEWAY_IP} is reachable"
        else
            bashio::log.warning "⚠️ Gateway ${GATEWAY_IP} is not reachable"
        fi
        
        bashio::log.info "Testing connectivity to SMGW ${SMGW_IP}..."
        if ping -c 1 -W 2 "${SMGW_IP}" > /dev/null 2>&1; then
            bashio::log.info "✅ SMGW ${SMGW_IP} is reachable"
        else
            bashio::log.warning "⚠️ SMGW ${SMGW_IP} is not reachable - check GL.iNet connection!"
        fi
        
        date +%s > /tmp/last_ping
    fi
    
    # Check route every 60 seconds
    sleep 60
done
