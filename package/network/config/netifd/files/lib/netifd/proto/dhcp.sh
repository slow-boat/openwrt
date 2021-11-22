#!/bin/sh

[ -L /sbin/udhcpc ] || exit 0

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_dhcp_init_config() {
	renew_handler=1

	proto_config_add_string 'ipaddr:ipaddr'
	proto_config_add_string 'hostname:hostname'
	proto_config_add_string clientid
	proto_config_add_string vendorid
	proto_config_add_boolean 'broadcast:bool'
	proto_config_add_boolean 'norelease:bool'
	proto_config_add_string 'reqopts:list(string)'
	proto_config_add_boolean 'defaultreqopts:bool'
	proto_config_add_string iface6rd
	proto_config_add_array 'sendopts:list(string)'
	proto_config_add_boolean delegate
	proto_config_add_string zone6rd
	proto_config_add_string zone
	proto_config_add_string mtu6rd
	proto_config_add_string customroutes
	proto_config_add_boolean classlessroute
	proto_config_add_boolean ipv6
	proto_config_add_boolean defaultroute
	proto_config_add_boolean usegateway
	proto_config_add_boolean subnetroute
	proto_config_add_boolean dns
	proto_config_add_boolean peerdns
	proto_config_add_string metric
	proto_config_add_string ip4table
	proto_config_add_string ip6table
	proto_config_add_string table
}

proto_dhcp_add_sendopts() {
	[ -n "$1" ] && append "$3" "-x $1"
}

proto_dhcp_setup() {
	local config="$1"
	local iface="$2"

	local ipaddr hostname clientid vendorid broadcast norelease reqopts defaultreqopts iface6rd sendopts delegate zone6rd zone mtu6rd customroutes classlessroute ipv6 defaultroute usegateway subnetroute dns peerdns metric table ip4table ip6table
	json_get_vars ipaddr hostname clientid vendorid broadcast norelease reqopts defaultreqopts iface6rd delegate zone6rd zone mtu6rd customroutes classlessroute ipv6 defaultroute usegateway subnetroute dns peerdns metric table ip4table ip6table

	local opt dhcpopts
	for opt in $reqopts; do
		append dhcpopts "-O $opt"
	done

	json_for_each_item proto_dhcp_add_sendopts sendopts dhcpopts
	[ "$ipv6" = "1" ] || ipv6=

	[ -z "$hostname" ] && hostname="$(cat /proc/sys/kernel/hostname)"
	[ "$hostname" = "*" ] && hostname=

	[ "$defaultreqopts" = 0 ] && defaultreqopts="-o" || defaultreqopts=
	[ "$broadcast" = 1 ] && broadcast="-B" || broadcast=
	[ "$norelease" = 1 ] && norelease="" || norelease="-R"
	[ -n "$clientid" ] && clientid="-x 0x3d:${clientid//:/}" || clientid="-C"
	
	[ -z "$ipv6" ] && {
		[ -n "$iface6rd" ] && proto_export "IFACE6RD=$iface6rd"
		[ "$iface6rd" != 0 -a -f /lib/netifd/proto/6rd.sh ] && append dhcpopts "-O 212"
		[ -n "$zone6rd" ] && proto_export "ZONE6RD=$zone6rd"
		[ -n "$mtu6rd" ] && proto_export "MTU6RD=$mtu6rd"
		[ "$delegate" = "0" ] && proto_export "IFACE6RD_DELEGATE=0"
	}
	[ -n "$zone" ] && proto_export "ZONE=$zone"
	[ -n "$customroutes" ] && proto_export "CUSTOMROUTES=$customroutes"
	[ -n "$dns" ] && proto_export "DNSOVERRIDE=$dns"
	[ "$defaultroute" = "0" ] && proto_export "DEFAULTROUTE=0"
	[ "$usegateway" = "0" ] && proto_export "USEGATEWAY=0"
	[ "$subnetroute" = "0" ] && proto_export "SUBNETROUTE=0"
	[ "$peerdns" = "0" ] && proto_export "PEERDNS=0"
	
	# Request classless route option (see RFC 3442) by default
	[ "$classlessroute" = "0" ] || append dhcpopts "-O 121"

	[ -n "$metric" ] && proto_export "METRIC=$metric"
	[ -n "$table" ] && proto_export "IP4TABLE=$table" && [ "$ipv6" = "1" ] && proto_export "IP6TABLE=$table"
	[ -n "$ip4table" ] && proto_export "IP4TABLE=$ip4table"
	[ -n "$ip6table" ] && [ "$ipv6" = "1" ] && proto_export "IP6TABLE=$ip6table"
	
	proto_export "INTERFACE=$config"
	proto_run_command "$config" udhcpc \
		-p /var/run/udhcpc-$iface.pid \
		-s /lib/netifd/dhcp.script \
		-f -R -t 0 -i "$iface" \
		${ipaddr:+-r $ipaddr} \
		${hostname:+-x "hostname:$hostname"} \
		${vendorid:+-V "$vendorid"} \
		$clientid $defaultreqopts $broadcast $norelease $dhcpopts
}

proto_dhcp_renew() {
	local interface="$1"
	# SIGUSR1 forces udhcpc to renew its lease
	local sigusr1="$(kill -l SIGUSR1)"
	[ -n "$sigusr1" ] && proto_kill_command "$interface" $sigusr1
}

proto_dhcp_teardown() {
	local interface="$1"
	proto_kill_command "$interface"
}

add_protocol dhcp
