#!/usr/bin/with-contenv bashio

# Read configuration
SMGW_NETWORK=$(bashio::config 'smgw_network')
GATEWAY_IP=$(bashio::config 'gateway_ip')
SMGW_IP=$(bashio::config 'smgw_ip')
SMGW_HOSTNAME=$(bashio::config 'smgw_hostname')
DNS_ENABLED=$(bashio::config 'dns_enabled')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting SMGW Route Manager..."
bashio::log.info "SMGW Network: ${SMGW_NETWORK}"
bashio::log.info "Gateway IP: ${GATEWAY_IP}"
bashio::log.info "SMGW IP: ${SMGW_IP}"
bashio::log.info "SMGW Hostname: ${SMGW_HOSTNAME:-<nicht konfiguriert>}"
bashio::log.info "DNS Enabled: ${DNS_ENABLED}"
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

# Function to check if DNS entry exists in /etc/hosts
check_dns_entry() {
    if [ -z "${SMGW_HOSTNAME}" ]; then
        return 1
    fi
    
    if grep -q "${SMGW_IP}.*${SMGW_HOSTNAME}" /etc/hosts 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to add DNS entry to /etc/hosts
add_dns_entry() {
    if [ -z "${SMGW_HOSTNAME}" ]; then
        bashio::log.warning "DNS Hostname nicht konfiguriert - überspringe DNS-Eintrag"
        return 1
    fi
    
    bashio::log.info "Adding DNS entry: ${SMGW_IP} ${SMGW_HOSTNAME}"
    
    # Remove any existing entries for this hostname or IP (avoid duplicates)
    sed -i "/${SMGW_HOSTNAME}/d" /etc/hosts 2>/dev/null || true
    
    # Add the new entry
    echo "${SMGW_IP}    ${SMGW_HOSTNAME}  # SMGW Route Manager" >> /etc/hosts
    
    if check_dns_entry; then
        bashio::log.info "✅ DNS entry added successfully"
        return 0
    else
        bashio::log.error "Failed to add DNS entry"
        return 1
    fi
}

# Function to remove DNS entry from /etc/hosts
remove_dns_entry() {
    if [ -z "${SMGW_HOSTNAME}" ]; then
        return 0
    fi
    
    bashio::log.info "Removing DNS entry for ${SMGW_HOSTNAME}"
    sed -i "/${SMGW_HOSTNAME}/d" /etc/hosts 2>/dev/null || true
    sed -i "/# SMGW Route Manager/d" /etc/hosts 2>/dev/null || true
}

# Initial DNS setup
if [ "${DNS_ENABLED}" = "true" ]; then
    if [ -n "${SMGW_HOSTNAME}" ]; then
        bashio::log.info "DNS-Konfiguration aktiviert - Hostname: ${SMGW_HOSTNAME}"
        
        # Clean up any old entries first
        remove_dns_entry
        
        # Add new DNS entry
        if add_dns_entry; then
            bashio::log.info "✅ DNS-Eintrag erfolgreich gesetzt: ${SMGW_HOSTNAME} -> ${SMGW_IP}"
            
            # Test DNS resolution
            if nslookup "${SMGW_HOSTNAME}" >/dev/null 2>&1 || getent hosts "${SMGW_HOSTNAME}" >/dev/null 2>&1; then
                bashio::log.info "✅ DNS-Auflösung funktioniert: ${SMGW_HOSTNAME}"
            else
                bashio::log.warning "⚠️ DNS-Auflösung konnte nicht getestet werden"
            fi
        else
            bashio::log.error "❌ Fehler beim Setzen des DNS-Eintrags"
        fi
    else
        bashio::log.warning "DNS ist aktiviert, aber kein Hostname konfiguriert - bitte 'smgw_hostname' setzen"
    fi
else
    bashio::log.info "DNS-Konfiguration deaktiviert"
    # Clean up any existing entries
    remove_dns_entry
fi


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
    
    # Check and maintain DNS entry if enabled
    if [ "${DNS_ENABLED}" = "true" ] && [ -n "${SMGW_HOSTNAME}" ]; then
        if ! check_dns_entry; then
            bashio::log.warning "DNS entry not found or changed, re-adding it..."
            remove_dns_entry
            add_dns_entry
        else
            bashio::log.debug "DNS entry for ${SMGW_HOSTNAME} is active"
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
            
            # If hostname is configured and DNS is enabled, test HTTPS access
            if [ "${DNS_ENABLED}" = "true" ] && [ -n "${SMGW_HOSTNAME}" ]; then
                bashio::log.info "Testing HTTPS access to ${SMGW_HOSTNAME}..."
                if curl -k -s --connect-timeout 5 "https://${SMGW_HOSTNAME}" >/dev/null 2>&1; then
                    bashio::log.info "✅ HTTPS access to ${SMGW_HOSTNAME} is working"
                else
                    bashio::log.debug "HTTPS test to ${SMGW_HOSTNAME} failed (might be normal if SMGW requires authentication)"
                fi
            fi
        else
            bashio::log.warning "⚠️ SMGW ${SMGW_IP} is not reachable - check GL.iNet connection!"
        fi
        
        date +%s > /tmp/last_ping
    fi
    
    # Check route every 60 seconds
    sleep 60
done
