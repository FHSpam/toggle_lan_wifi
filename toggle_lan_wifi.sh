#!/bin/bash


log()
{
	echo "$@"
}

	
# @return 0 if enabled, 1 if not
# !! Not working ...
isLanEnabled()
{
	ethtool eth0 | grep "Link detected" | grep "yes"
	([ $? = 0 ] && log "Lan is enabled" && RET=0) || ( log "Lan is disabled" && RET=1)
	return $RET
}


#isLanEnabled2()
#{
#	# Since isLanEnabled does not seem to be working, assume the state (disconnected/connected)
#	# of the Lan is the opposite of the Wifi 
#	return !isWifiEnabled
#}



# @return 0 if enabled, 1 if not, 2 if can't tell
isWifiEnabled()
{
	if   [ `nmcli radio  wifi` = "enabled" ]; then
		log "Wifi is enabled"
		RET=0
	elif [ `nmcli radio  wifi` = "disabled" ]; then
		log "Wifi is disabled"
		RET=1
	else
		log "Can't determine if Wifi is enabled or disabled. Exiting..."
		RET=2
	fi
	return $RET
}


# @param 1 to switch on, 0 to switch off
turnWifi()
{
	[ $1 = 0 ] && nmcli radio wifi off && log "Wifi turned off" && return 0
	[ $1 = 1 ] && nmcli radio wifi on && log "Wifi turned on" && return 0
	log "Error, check script: turnWifi()" && return 1
}


# @param 1 to switch on, 0 to switch off
turnLan()
{
	[ $1 = 0 ] && ip link set down eth0 && log "Lan turned off" && return 0
	[ $1 = 1 ] && ip link set up   eth0 && log "Lan turned on"  && return 0
	log "Error, check script: turnLan()" && return 1
}

#if  [ isLanEnabled -a !isWifiEnabled ]; then
#	log "LAN: ON ; WIFI: OFF" 
#elif [ !isLanEnabled -a isWifiEnabled ]; then
#	log "LAN: OFF ; WIFI: ON" 
#else
#	log "Error: inconsistent state: both LAN and WIFI are ON or OFF"
#fi


if  isWifiEnabled; then
	log "LAN: ? ; WIFI: ON" 
	log "Switching LAN ON, and WIFI OFF"
	turnLan 1
	turnWifi 0
elif (! isWifiEnabled); then
	log "LAN: ? ; WIFI: OFF" 
	log "Switching LAN OFF, and WIFI ON"
	turnLan 0
	turnWifi 1
else
	log "Error: inconsistent state: both LAN and WIFI are ON or OFF"
fi



