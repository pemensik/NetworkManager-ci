@testplan
Feature: nmcli - general

    # Please do use tags as follows:
    # @bugzilla_link (rhbz123456)
    # @version_control (ver+/-=1.4.1)
    # @other_tags (see environment.py)
    # @test_name (compiled from scenario name)
    # Scenario:


    @logging
    Scenario: NM - general - setting log level and autocompletion
    Then "DEBUG\s+ERR\s+INFO\s+.*TRACE\s+WARN" is visible with tab after "sudo nmcli general logging level "
    * Set logging for "all" to "INFO"
    Then "INFO\s+[^:]*$" is visible with command "nmcli general logging"
    * Set logging for "default,WIFI:ERR" to " "
    Then "INFO\s+[^:]*,WIFI:ERR,[^:]*$" is visible with command "nmcli general logging"


    @rhbz1212196
    @gen-bond_remove
    @reduce_logging
    Scenario: NM - general - reduce logging
     * Add connection type "bond" named "gen-bond0" for device "gen-bond"
    Then "preparing" is not visible with command "journalctl _COMM=NetworkManager --since '2 min ago'   |grep '<info> .*gen-bond' |grep 'preparing device'"
    Then "exported as" is not visible with command "journalctl _COMM=NetworkManager --since '2 min ago' |grep '<info> .*gen-bond' |grep 'exported as'"
    Then "Stage" is not visible with command "journalctl _COMM=NetworkManager --since '2 min ago'       |grep '<info> .*gen-bond' |grep 'Stage'"


    @rhbz1362542
    @ver+=1.4.0
    @insufficient_logging_perms
    Scenario: NM - general - not enough logging perms
    Then "Error: failed to set logging: access denied" is visible with command "sudo -u test nmcli general logging level TRACE domains all"


    @rhbz1422786
    @ver+=1.8.0
    @eth8_disconnect
    @insufficient_perms_connection_down
    Scenario: nmcli - general - not enough perms for connection down
    * Bring "up" connection "testeth8"
    Then "Not authorized to deactivate connections" is visible with command "sudo -u test nmcli connection down testeth8"


    @rhbz1422786
    @ver+=1.8.0
    @eth8_disconnect
    @insufficient_perms_connection_up
    Scenario: nmcli - general - not enough perms for connection up
    Then "Not authorized to control networking" is visible with command "sudo -u test nmcli connection up testeth8"


    @general_check_version
    Scenario: nmcli - general - check version
    * Note the output of "rpm -q --queryformat '%{VERSION}' NetworkManager" as value "1"
    * Note the output of "nmcli -t -f VERSION general" as value "2"
    Then Check noted values "1" and "2" are the same


    @remove_fedora_connection_checker
    @general_state_connected
    Scenario: nmcli - general - state connected
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo connected" as value "2"
    Then Check noted values "1" and "2" are the same


    @restore_hostname
    @hostname_change
    Scenario: nmcli - general - set hostname
    * Execute "sudo nmcli general hostname walderon"
    Then "walderon" is visible with command "cat /etc/hostname"


    @ver+=1.4.0
    @con_general_remove @teardown_testveth @eth0 @restore_hostname
    @pull_hostname_from_dhcp
    Scenario: nmcli - general - pull hostname from DHCP
    * Prepare simulated test "testG" device
    * Execute "sudo nmcli general hostname localhost"
    * Execute "hostnamectl set-hostname --transient localhost.localdomain"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    When "localhost" is visible with command "hostnamectl --transient" in "60" seconds
    * Bring up connection "con_general"
    When "ransient" is visible with command "hostnamectl" in "60" seconds
    Then "localhost" is not visible with command "hostnamectl --transient" in "60" seconds


    @rhbz1405275
    @ver+=1.8.0
    @con_general_remove @teardown_testveth @restart @delete_testeth0 @restore_hostname
    @hostname_mode_full
    Scenario: NM - general - hostname mode full
    * Execute "echo -e '[main]\nhostname-mode=full' > /etc/NetworkManager/conf.d/90-hostname.conf"
    * Restart NM
    * Prepare simulated test "testG" device
    * Execute "sudo nmcli general hostname localhost"
    * Execute "hostnamectl set-hostname --transient localhost.localdomain"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    When "localhost" is visible with command "hostnamectl --transient" in "60" seconds
    * Bring up connection "con_general"
    When "ransient" is visible with command "hostnamectl" in "60" seconds
    Then "localhost" is not visible with command "hostnamectl --transient" in "60" seconds


    @rhbz1405275
    @ver+=1.8.0
    @con_general_remove @teardown_testveth @restart @delete_testeth0 @restore_hostname
    @hostname_mode_dhcp
    Scenario: NM - general - hostname mode dhcp
    * Execute "echo -e '[main]\nhostname-mode=dhcp' > /etc/NetworkManager/conf.d/90-hostname.conf"
    * Restart NM
    * Prepare simulated test "testG" device
    * Execute "sudo nmcli general hostname localhost"
    * Execute "hostnamectl set-hostname --transient localhost.localdomain"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    When "localhost" is visible with command "hostnamectl --transient" in "60" seconds
    * Bring up connection "con_general"
    When "ransient" is visible with command "hostnamectl" in "60" seconds
    Then "localhost" is not visible with command "hostnamectl --transient" in "60" seconds


    @rhbz1405275
    @ver+=1.8.0
    @con_general_remove @teardown_testveth @restart @delete_testeth0 @restore_hostname
    @hostname_mode_full_without_dhcp_hosts
    Scenario: NM - general - hostname mode dhcp without dhcp hosts
    * Execute "echo -e '[main]\nhostname-mode=dhcp' > /etc/NetworkManager/conf.d/90-hostname.conf"
    * Execute "echo no-hosts > /etc/dnsmasq.d/dnsmasq_custom.conf"
    * Restart NM
    * Prepare simulated test "testG" device
    * Execute "sudo nmcli general hostname localhost"
    * Execute "hostnamectl set-hostname --transient localhost.localdomain"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    When "localhost" is visible with command "hostnamectl --transient" in "60" seconds
    * Bring up connection "con_general"
    When "ransient" is visible with command "hostnamectl" in "60" seconds
    Then "localhost" is visible with command "hostnamectl --transient" in "60" seconds
     And "localhost" is visible with command "hostnamectl --transient" for full "20" seconds


    @rhbz1405275
    @ver+=1.8.0
    @con_general_remove @teardown_testveth @restart @delete_testeth0 @restore_hostname
    @hostname_mode_none
    Scenario: NM - general - hostname mode none
    * Execute "echo -e '[main]\nhostname-mode=none' > /etc/NetworkManager/conf.d/90-hostname.conf"
    * Restart NM
    * Prepare simulated test "testG" device
    * Execute "sudo nmcli general hostname localhost"
    * Execute "hostnamectl set-hostname --transient localhost.localdomain"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    When "localhost" is visible with command "hostnamectl --transient" in "60" seconds
    * Bring up connection "con_general"
    When "ransient" is visible with command "hostnamectl" in "60" seconds
    Then "localhost" is visible with command "hostnamectl --transient" in "60" seconds
     And "localhost" is visible with command "hostnamectl --transient" for full "20" seconds


    @restart @veth
    @general_state_disconnected
    Scenario: nmcli - general - state disconnected
    * "disconnect" all " connected" devices
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo disconnected" as value "2"
    Then Check noted values "1" and "2" are the same
    * Bring up connection "testeth0"


    @veth
    @general_state_asleep
    Scenario: nmcli - general - state asleep
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo asleep" as value "2"
    Then Check noted values "1" and "2" are the same
    Then Execute "nmcli networking on"


    @general_state_running
    Scenario: nmcli - general - running
    * Note the output of "nmcli -t -f RUNNING general" as value "1"
    * Note the output of "echo running" as value "2"
    Then Check noted values "1" and "2" are the same


    @veth @restart
    @general_state_not_running
    Scenario: nmcli - general - not running
    * Stop NM
    * Wait for at least "2" seconds
    Then "NetworkManager is not running" is visible with command "nmcli general"


    @rhbz1311988
    @restart @add_testeth8 @shutdown @eth8_disconnect
    @shutdown_service_assumed
    Scenario: NM - general - shutdown service - assumed
    * Delete connection "testeth8"
    * Stop NM
    * Execute "ip addr add 192.168.50.5/24 dev eth8"
    * Execute "route add default gw 192.168.50.1 metric 200 dev eth8"
    * "default via 192.168.50.1 dev eth8\s+metric 200" is visible with command "ip r"
    * "inet 192.168.50.5" is visible with command "ip a s eth8" in "5" seconds
    * Start NM
    * "default via 192.168.50.1 dev eth8\s+metric 200" is visible with command "ip r"
    * "inet 192.168.50.5" is visible with command "ip a s eth8" in "5" seconds
    * Stop NM
    Then "default via 192.168.50.1 dev eth8\s+metric 200" is visible with command "ip r" for full "5" seconds
     And "inet 192.168.50.5" is visible with command "ip a s eth8"


     @rhbz1311988
     @con_general_remove @restart @shutdown
     @shutdown_service_connected
     Scenario: NM - general - shutdown service - connected
     * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general autoconnect no"
     * Bring "up" connection "con_general"
     * "default via 192.168.100.1 dev eth8" is visible with command "ip r"
     * "inet 192.168.100" is visible with command "ip a s eth8" in "5" seconds
     * Stop NM
     Then "default via 192.168.100.1 dev eth8" is visible with command "ip r" for full "5" seconds
      And "inet 192.168.100" is visible with command "ip a s eth8"


      @rhbz1311988
      @restart @shutdown
      @shutdown_service_any
      Scenario: NM - general - shutdown service - all
      * Stop NM
      Then All ifaces but "gre0, gretap0, dummy0, ip6tnl0, tunl0, sit0" are not in state "DOWN"
       And "After=network-pre.target dbus.service" is visible with command "grep After /usr/lib/systemd/system/NetworkManager.service"


    @rhbz1371201
    @ver+=1.4.0
    @CAP_SYS_ADMIN_for_ibft
    Scenario: NM - service - CAP_SYS_ADMIN for ibft plugin
      Then "CAP_SYS_ADMIN" is visible with command "grep CapabilityBoundingSet /usr/lib/systemd/system/NetworkManager.service"


    @general_networking_on_off
    Scenario: nmcli - general - networking
    * Note the output of "nmcli -t -f NETWORKING general" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f NETWORKING general" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @general_networking_enabled
    Scenario: nmcli - networking - status - enabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same


    @general_networking_disabled
    Scenario: nmcli - networking - status - disabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    * Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli networking" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @veth
    @general_networking_off
    Scenario: nmcli - networking - turn off
    * "eth0:" is visible with command "ifconfig"
    * Execute "nmcli networking off"
    Then "eth0:" is not visible with command "ifconfig"
    Then Execute "nmcli networking on"


    @veth
    @general_networking_on
    Scenario: nmcli - networking - turn on
    * Execute "nmcli networking off"
    * "eth0:" is not visible with command "ifconfig"
    * Execute "nmcli networking on"
    Then "eth0:" is visible with command "ifconfig"


    @nmcli_radio_status
    Scenario: nmcli - radio - status
    Then "WIFI-HW\s+WIFI\s+WWAN-HW\s+WWAN\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled" is visible with command "nmcli radio"


    @nmcli_device_status
    Scenario: nmcli - device - status
    Then "DEVICE\s+TYPE\s+STATE.+eth0\s+ethernet" is visible with command "nmcli device"


    @con_general_remove
    @nmcli_device_show_ip
    Scenario: nmcli - device - show - check ip
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general autoconnect no"
    * Open editor for connection "con_general"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "con_general"
    Then "IP4.ADDRESS.*192.168.1.10/24" is visible with command "nmcli device show eth8"


    @nmcli_device_show_general_params
    Scenario: nmcli - device - show - check general params
    * Note the output of "nmcli device show eth0"
    Then Check noted output contains "GENERAL.DEVICE:\s+eth0"
    Then Check noted output contains "GENERAL.TYPE:\s+ethernet"
    Then Check noted output contains "GENERAL.MTU:\s+[0-9]+"
    Then Check noted output contains "GENERAL.HWADDR:\s+\S+:\S+:\S+:\S+:\S+:\S+"
    Then Check noted output contains "GENERAL.CON-PATH:\s+\S+\s"
    Then Check noted output contains "GENERAL.CONNECTION:\s+\S+\s"


    @nmcli_device_disconnect
    Scenario: nmcli - device - disconnect
    * Bring "up" connection "testeth8"
    * "eth8\s+ethernet\s+connected" is visible with command "nmcli device"
    * Disconnect device "eth8"
    Then "eth8\s+ethernet\s+connected" is not visible with command "nmcli device"


## Basically various bug related reproducer tests follow here

    @con_general_remove
    @device_connect
    Scenario: nmcli - device - connect
    * Bring "up" connection "testeth9"
    * Disconnect device "eth9"
    When "eth9\s+ethernet\s+ connected\s+eth9" is not visible with command "nmcli device"
    * Connect device "eth9"
    Then "eth9\s+ethernet\s+connected" is visible with command "nmcli device"


    @rhbz1032717
    @ver+=1.2.0 @ver-=1.7.1
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_routes
    Scenario: NM - device - reapply just routes
    * Prepare simulated test "testG" device
    * Add connection type "ethernet" named "con_general" for device "testG"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.99.111 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "ip netns exec testG_ns kill -SIGSTOP $(cat /tmp/testG_ns.pid)"
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     And "2000::/126 dev testG\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
     And "192.168.5.0/24 via 192.168.99.111 dev testG\s+proto static\s+metric" is visible with command "ip route"
     And "routers = 192.168.99.1" is visible with command "nmcli con show con_general"
     And "default via 192.168.99.1 dev testG" is visible with command "ip r"


    @ver+=1.7.1 @ver-=1.10.1
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_routes
    Scenario: NM - device - reapply just routes
    * Prepare simulated test "testG" device
    * Add connection type "ethernet" named "con_general" for device "testG"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.99.111 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     # metric 256 is valid for @ver-=1.9.1 only, please delete of too old
     And "2000::/126 dev testG\s+proto kernel\s+metric (100|256)" is visible with command "ip -6 route"
     And "192.168.5.0/24 via 192.168.99.111 dev testG\s+proto static\s+metric" is visible with command "ip route"
     And "routers = 192.168.99.1" is visible with command "nmcli con show con_general"
     And "default via 192.168.99.1 dev testG" is visible with command "ip r"


    @ver+=1.10.2  @ver-1.11
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_routes
    Scenario: NM - device - reapply just routes
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no ipv4.may-fail no ipv6.method ignore"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.99.111 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     And "2000::/126 dev testG\s+proto kernel\s+metric 1" is visible with command "ip -6 route"
     And "192.168.5.0/24 via 192.168.99.111 dev testG\s+proto static\s+metric" is visible with command "ip route"
     And "routers = 192.168.99.1" is visible with command "nmcli con show con_general"
     And "default via 192.168.99.1 dev testG\s+proto dhcp\s+metric 21" is visible with command "ip r"


    @ver+=1.11
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_routes
    Scenario: NM - device - reapply just routes
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.99.111 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     And "2000::/126 dev testG\s+proto kernel\s+metric 1" is visible with command "ip -6 route"
     And "192.168.5.0/24 via 192.168.99.111 dev testG\s+proto static\s+metric" is visible with command "ip route"
     And "routers = 192.168.99.1" is visible with command "nmcli con show con_general"
     # Metric still cannot be changed when dhcp is used. Bug #1528071
     # And "default via 192.168.99.1 dev testG\s+proto dhcp\s+metric 21" is visible with command "ip r"
     And "default via 192.168.99.1 dev testG\s+proto dhcp\s+metric" is visible with command "ip r"


    @rhbz1032717
    @ver+=1.2.0 @ver-=1.10.0
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_all
    Scenario: NM - device - reapply even address and gate
    * Prepare simulated test "testG" device
    * Add connection type "ethernet" named "con_general" for device "testG"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "ip netns exec testG_ns kill -SIGSTOP $(cat /tmp/testG_ns.pid)"
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     # metric 256 is valid for @ver-=1.9.1 only, please delete of too old
     And "2000::/126 dev testG\s+proto kernel\s+metric (100|256)" is visible with command "ip -6 route"
     And "192.168.3.0/24 dev testG\s+proto kernel\s+scope link\s+src 192.168.3.10" is visible with command "ip route"
     And "192.168.4.1 dev testG\s+proto static\s+scope link\s+metric 21" is visible with command "ip route"
     And "192.168.5.0/24 via 192.168.3.11 dev testG\s+proto static\s+metric" is visible with command "ip route"
     And "routers = 192.168.99.1" is not visible with command "nmcli con show con_general"
     And "default via 192.168.99.1 dev testG" is not visible with command "ip r"


    @rhbz1032717 @rhbz1505893
    @ver+=1.10.2
    @con_general_remove @teardown_testveth @dhcpd
    @device_reapply_all
    Scenario: NM - device - reapply even address and gate
    * Prepare simulated test "testG" device
    * Add connection type "ethernet" named "con_general" for device "testG"
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Submit "set ipv6.method static" in editor
    * Submit "set ipv6.addresses 2000::2/126" in editor
    * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
    * Save in editor
    * Execute "ip netns exec testG_ns kill -SIGSTOP $(cat /tmp/testG_ns.pid)"
    * Execute "nmcli device reapply testG"
    Then "1010::1 via 2000::1 dev testG\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
     And "2000::/126 dev testG\s+proto kernel\s+metric 1" is visible with command "ip -6 route"
     And "192.168.3.0/24 dev testG\s+proto kernel\s+scope link\s+src 192.168.3.10 metric 21" is visible with command "ip route"
     And "192.168.4.1 dev testG\s+proto static\s+scope link\s+metric 21" is visible with command "ip route"
     And "192.168.5.0/24 via 192.168.3.11 dev testG\s+proto static\s+metric 1" is visible with command "ip route"
     And "routers = 192.168.99.1" is not visible with command "nmcli con show con_general"
     And "default via 192.168.99.1 dev testG" is not visible with command "ip r"


    @rhbz1113941
    @veth
    @device_connect_no_profile
    Scenario: nmcli - device - connect - no profile
    * Finish "nmcli connection delete id testeth9"
    * Connect device "eth9"
    * Bring "down" connection "eth9"
    Then "eth9" is not visible with command "nmcli connection show -a"
    Then "connection.interface-name: \s+eth9" is visible with command "nmcli connection show eth9"


    @rhbz1034150
    @gen_br_remove
    @nmcli_device_delete
    Scenario: nmcli - device - delete
    * Add a new connection of type "bridge" and options "ifname brX con-name gen_br"
    * "brX\s+bridge" is visible with command "nmcli device"
    * Execute "nmcli device delete brX"
    Then "brX\s+bridge" is not visible with command "nmcli device"
    Then "gen_br" is visible with command "nmcli connection"


    @rhbz1034150
    @veth @newveth
    @nmcli_device_attempt_hw_delete
    Scenario: nmcli - device - attempt to delete hw interface
    * "eth9\s+ethernet" is visible with command "nmcli device"
    Then "Error" is visible with command "nmcli device delete eth9"
    Then "eth9\s+ethernet" is visible with command "nmcli device"


    @rhbz1067712
    @con_general_remove @teardown_testveth @restart
    @nmcli_general_correct_profile_activated_after_restart
    Scenario: nmcli - general - correct profile activated after restart
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general -- ipv4.method auto ipv6.method auto ipv4.may-fail no ipv6.may-fail no"
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general2 -- ipv4.method auto ipv6.method auto ipv4.may-fail no ipv6.may-fail no"
    * Wait for at least "2" seconds
    * Bring up connection "con_general"
    When "100" is visible with command "nmcli  -t -f GENERAL.STATE device show testG"
    * Restart NM
    Then "con_general" is visible with command "nmcli device" in "10" seconds
     And "con_general2" is not visible with command "nmcli device"


    @rhbz1007365
    @bridge
    @nmcli_novice_mode_readline
    Scenario: nmcli - general - using readline library in novice mode
    * Open wizard for adding new connection
    * Expect "Connection type"
    * Send "bond" in editor
    * Clear the text typed in editor
    * Submit "bridge" in editor
    Then Expect "There are \d+ optional .*[Bb]ridge"
    * Submit "no" in editor
    * Dismiss IP configuration in editor
    * Dismiss Proxy configuration in editor
    Then "nm-bridge" is visible with command "nmcli connection show bridge"


    @restart @remove_dns_clean
    @dns_none
    Scenario: NM - dns none setting
    * Execute "printf '[main]\ndns=none\n' | sudo tee /etc/NetworkManager/conf.d/90-test-dns-none.conf"
    * Restart NM
    * Execute "echo 'nameserver 1.2.3.4' | sudo bash -c 'cat > /etc/resolv.conf'"
    * Execute "systemctl mask sendmail"
    * Bring "up" connection "testeth0"
    * Execute "systemctl unmask sendmail"
    Then "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 1[0-9]" is not visible with command "cat /etc/resolv.conf"


    @restart @remove_dns_clean
    @remove_dns_none
    Scenario: NM - dns  none removal
    * Execute "printf '[main]\ndns=none\n' | sudo tee /etc/NetworkManager/conf.d/90-test-dns-none.conf"
    * Restart NM
    * Execute "echo 'nameserver 1.2.3.4' | sudo bash -c 'cat > /etc/resolv.conf'"
    * Execute "systemctl mask sendmail"
    * Bring "up" connection "testeth0"
    * Execute "systemctl unmask sendmail"
    When "nameserver 1[0-9]" is not visible with command "cat /etc/resolv.conf"
    When "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    * Execute "sudo rm -rf /etc/NetworkManager/conf.d/90-test-dns-none.conf"
    * Restart NM
    * Bring "up" connection "testeth0"
    Then "nameserver 1.2.3.4" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 1[0-9]" is visible with command "cat /etc/resolv.conf"


    @rhbz1136836 @rhbz1173632
    @restart
    @connection_up_after_journald_restart
    Scenario: NM - general - bring up connection after journald restart
    #* Add connection type "ethernet" named "con_general" for device "eth8"
    #* Bring "up" connection "testeth0"
    * Finish "sudo systemctl restart systemd-journald.service"
    Then Bring "up" connection "testeth0"


    @rhbz1110436
    @restore_hostname @restart
    @nmcli_general_dhcp_hostname_over_localhost
    Scenario: NM - general - dont take localhost as configured hostname
    * Execute "hostnamectl set-hostname walderon"
    * Note the output of "cat /etc/hostname" as value "orig_file"
    * Execute "systemctl mask dbus-org.freedesktop.hostname1.service"
    * Execute "systemctl mask systemd-hostnamed.service"
    * Execute "systemctl stop systemd-hostnamed.service"
    * Restart NM
    * Note the output of "hostname" as value "orig_cmd"
    * Check noted values "orig_file" and "orig_cmd" are the same
    * Execute "echo localhost.localdomain > /etc/hostname"
    * Wait for at least "5" seconds
    * Note the output of "hostname" as value "localh_cmd"
    # Check that setting the hostname to localhost have been ignored
    * Check noted values "orig_cmd" and "localh_cmd" are the same
    # Now set it to custom non-localhost value
    * Execute "echo myown.hostname > /etc/hostname"
    * Note the output of "echo myown.hostname" as value "nonlocalh_file"
    * Wait for at least "5" seconds
    * Note the output of "nmcli g hostname" as value "nonlocalh_cmd"
    # Now see that the non-locahost value has been set
    Then Check noted values "nonlocalh_file" and "nonlocalh_cmd" are the same
    # Restoring orig. hostname in after_scenario


    @ver-=1.1
    @rhbz1136843
    @nmcli_general_ignore_specified_unamanaged_devices
    Scenario: NM - general - ignore specified unmanaged devices
    * Execute "ip link add name dnt type bond"
    # Still unmanaged
    * "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"
    * Execute "ip link set dev dnt up"
    * "dnt\s+bond\s+disconnected" is visible with command "nmcli device"
    # Add a config rule to unmanage the device
    * Execute "echo -e \\n[keyfile]\\nunmanaged-devices=interface-name:dnt > /etc/NetworkManager/NetworkManager.conf"
    * Execute "pkill -HUP NetworkManager"
    * Wait for at least "5" seconds
    # Now the device should be listed as unmanaged
    Then "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"


    @rhbz1136843
    @ver+=1.1.1
    @nmcli_general_ignore_specified_unamanaged_devices
    Scenario: NM - general - ignore specified unmanaged devices
    * Execute "ip link add name dnt type bond"
    # Still unmanaged
    * "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"
    * Execute "ip link set dev dnt up"
    * "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"
    # Add a config rule to unmanage the device
    * Execute "echo -e \\n[keyfile]\\nunmanaged-devices=interface-name:dnt > /etc/NetworkManager/NetworkManager.conf"
    * Execute "pkill -HUP NetworkManager"
    * Execute "ip addr add dev dnt 1.2.3.4/24"
    * Wait for at least "5" seconds
    # Now the device should be listed as unmanaged
    Then "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"


    @rhbz1371433
    @ver+=1.7.9
    @con_general_remove @manage_eth8 @eth8_disconnect @restart
    @nmcli_general_set_device_unmanaged
    Scenario: NM - general - set device to unmanaged state
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general autoconnect no"
    * Bring up connection "con_general"
    When "/sbin/dhclient" is visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
    * Execute "nmcli device set eth8 managed off"
    When "/sbin/dhclient" is not visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
     And "state UP" is visible with command "ip a s eth8"
     And "unmanaged" is visible with command "nmcli device show eth8"
     And "fe80" is visible with command "ip a s eth8"
     And "192" is visible with command "ip a s eth8" in "10" seconds
     And "192" is visible with command "ip r |grep eth8"
    * Restart NM
    Then "/sbin/dhclient" is not visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
     And "state UP" is visible with command "ip a s eth8"
     And "unmanaged" is visible with command "nmcli device show eth8"
     And "fe80" is visible with command "ip a s eth8"
     And "192" is visible with command "ip a s eth8"
     And "192" is visible with command "ip r |grep eth8"


    @rhbz1371433
    @ver+=1.7.9
    @con_general_remove @manage_eth8 @eth8_disconnect
    @nmcli_general_set_device_back_to_managed
    Scenario: NM - general - set device back from unmanaged state
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general autoconnect no"
    * Bring "up" connection "con_general"
    When "/sbin/dhclient" is visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
     And "fe80" is visible with command "ip a s eth8" in "15" seconds
     And "192" is visible with command "ip a s eth8" in "15" seconds
     And "192" is visible with command "ip r |grep eth8"
    * Wait for at least "2" seconds
    * Execute "nmcli device set eth8 managed off"
    When "/sbin/dhclient" is not visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
     And "state UP" is visible with command "ip a s eth8"
     And "unmanaged" is visible with command "nmcli device show eth8"
     And "192" is visible with command "ip a s eth8" in "15" seconds
     And "fe80" is visible with command "ip a s eth8" in "15" seconds
     And "192" is visible with command "ip r |grep eth8"
    * Bring "up" connection "con_general"
    Then "/sbin/dhclient" is visible with command "ps aux|grep dhc |grep eth8 |grep -v orig"
     And "state UP" is visible with command "ip a s eth8"
     And "unmanaged" is not visible with command "nmcli device show eth8"
     And "192" is visible with command "ip a s eth8" in "15" seconds
     And "fe80" is visible with command "ip a s eth8" in "15" seconds
     And "192" is visible with command "ip r |grep eth8"


    @general_vlan
    @nmcli_general_ifcfg_tailing_whitespace
    Scenario: nmcli - general - ifcfg tailing whitespace ignored
    * Add a new connection of type "vlan" and options "con-name eth8.100 autoconnect no dev eth8 id 100"
    * Check ifcfg-name file created for connection "eth8.100"
    * Execute "sed -i 's/PHYSDEV=eth8/PHYSDEV=eth9    /' /etc/sysconfig/network-scripts/ifcfg-eth8.100"
    * Reload connections
    Then "eth9" is visible with command "nmcli con show eth8.100"


    @ver-=1.5
    @mock
    @nmcli_device_wifi_with_two_devices
    Scenario: nmcli - device - wifi show two devices
    Then "test_two_wifi_with_accesspoints \(__main__.TestNetworkManager\) ... ok" is visible with command "sudo -u test python ./tmp/dbusmock-unittest.py TestNetworkManager.test_two_wifi_with_accesspoints"


    @rhbz1114681
    @general_vlan
    @nmcli_general_keep_slave_device_unmanaged
    Scenario: nmcli - general - keep slave device unmanaged
    Given Check ifcfg-name file created for connection "testeth8"
    * Execute "echo -e NM_CONTROLLED=no >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
    * Reload connections
    * Execute "ip link add link eth8 name eth8.100 type vlan id 100"
    Then "eth8\s+ethernet\s+unmanaged" is visible with command "nmcli device" in "5" seconds
    Then "eth8.100\s+vlan\s+unmanaged" is visible with command "nmcli device"
    Then "testeth8" is not visible with command "nmcli device"


    @rhbz1393997
    @con_general_remove @restart @restore_hostname
    @nmcli_general_DHCP_HOSTNAME_profile_pickup
    Scenario: nmcli - general - connect correct profile with DHCP_HOSTNAME
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Execute "nmcli connection modify con_general ipv4.dns 8.8.4.4"
    * Execute "echo -e 'DHCP_HOSTNAME=walderon' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Bring "up" connection "con_general"
    * Restart NM
    Then "con_general" is visible with command "nmcli  -t -f CONNECTION device"


    @rhbz1171751
    @ver+=1.8.0
    @add_testeth8 @restart @not_on_s390x
    @match_connections_when_no_var_run_exists
    Scenario: NM - general - connection matching for anaconda
     * Stop NM
     * Execute "rm -rf /etc/sysconfig/network-scripts/ifcfg-testeth8"
     * Execute "rm -rf /var/run/NetworkManager/*"
     * Execute "echo 'DEVICE=eth8' >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
     * Execute "echo 'NAME=testeth8' >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
     * Execute "echo 'BOOTPROTO=dhcp' >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
     * Execute "echo 'IPV6INIT=yes' >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
     * Execute "echo 'TYPE=Ethernet' >> /etc/sysconfig/network-scripts/ifcfg-testeth8"
     Then "testeth8" is not visible with command "nmcli con sh -a"
     * Start NM
     Then "testeth8" is visible with command "nmcli con sh -a" in "5" seconds


    @rhbz1460760
    @ver+=1.8.0
    @con_general_remove @mtu
    @ifcfg_respect_externally_set_mtu
    Scenario: NM - general - respect externally set mtu
    * Execute "ip link set dev eth8 mtu 1400"
    * Execute "echo 'DEVICE=eth8' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Execute "echo 'NAME=con_general' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Execute "echo 'BOOTPROTO=dhcp' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Execute "echo 'IPV6INIT=yes' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Execute "echo 'TYPE=Ethernet' >> /etc/sysconfig/network-scripts/ifcfg-con_general"
    * Reload connections
    * Bring "up" connection "con_general"
    Then "1400" is visible with command "ip a s eth8" in "5" seconds


    @rhbz1103777
    @firewall
    @no_error_when_firewald_restarted
    Scenario: NM - general - no error when firewalld restarted
    * Execute "sudo systemctl restart firewalld"
    Then "nm_connection_get_setting_connection: assertion" is not visible with command "journalctl --since '10 seconds ago' --no-pager |grep nm_connection"


    @rhbz1103777
    @ver+=1.8.0
    @firewall @con_general_remove @restart
    @show_zones_after_firewalld_install
    Scenario: NM - general - show zones after firewall restart
    * Execute "yum -y remove firewalld"
    * Restart NM
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general connection.zone work"
    * Execute "yum -y install firewalld"
    * Execute "systemctl start firewalld"
    Then "work" is visible with command "firewall-cmd  --get-zone-of-interface=eth8"


    @rhbz1286576
    @restart
    @wpa_supplicant_not_started
    Scenario: NM - general - do not start wpa_supplicant
    * Execute "sudo systemctl stop wpa_supplicant"
    * restart NM
    Then "^active" is not visible with command "systemctl is-active wpa_supplicant" in "5" seconds


    @rhbz1041901
    @gen-bond_remove
    @nmcli_general_multiword_autocompletion
    Scenario: nmcli - general - multiword autocompletion
    * Add a new connection of type "bond" and options "ifname gen-bond con-name 'Bondy connection 1'"
    * "Bondy connection 1" is visible with command "nmcli connection"
    * Autocomplete "nmcli connection delete Bondy" in bash and execute
    Then "Bondy connection 1" is not visible with command "nmcli connection" in "3" seconds


    @rhbz1170199
    @con_general_remove @IPy
    @nmcli_general_dbus_set_gateway
    Scenario: nmcli - general - dbus api gateway setting
    * Execute "python tmp/dbus-set-gw.py"
    Then "ipv4.gateway:\s+192.168.1.100" is visible with command "nmcli connection show con_general"


    @rhbz1141264
    @BBB
    @preserve_failed_assumed_connections
    Scenario: NM - general - presume failed assumed connections
    * Execute "ip tuntap add BBB mode tap"
    * Execute "ip link set dev BBB up"
    * Execute "ip addr add 10.2.5.6/24 valid_lft 1024 preferred_lft 1024 dev BBB"
    Then "10.2.5.6/24" is visible with command "ip addr show BBB" for full "50" seconds
    * Bring "down" connection "BBB"
    * Execute "ip link set dev BBB up"
    * Execute "ip addr add 10.2.5.6/24 dev BBB"
    Then "10.2.5.6/24" is visible with command "ip addr show BBB" for full "10" seconds


    @rhbz1066705
    @BBB
    @vxlan_interface_recognition
    Scenario: NM - general - vxlan interface support
    * Execute "/sbin/ip link add BBB type vxlan id 42 group 239.1.1.1 dev eth8"
    When "unmanaged" is visible with command "nmcli device show BBB" in "5" seconds
    * Execute "ip link set dev BBB up"
    * Execute "ip addr add fd00::666/8 dev BBB"
    Then "connected" is visible with command "nmcli device show BBB" in "10" seconds
    Then vxlan device "BBB" check for parent "eth8"


    @rhbz1109426
    @two_bridged_veths_gen
    @veth_goes_to_unmanaged_state
    Scenario: NM - general - veth in unmanaged state
    * Execute "ip link add test1g type veth peer name test1gp"
    Then "test1g\s+ethernet\s+unmanaged.*test1gp\s+ethernet\s+unmanaged" is visible with command "nmcli device"


    @rhbz1067299
    @two_bridged_veths_gen @peers_ns
    @nat_from_shared_network
    Scenario: NM - general - NAT_dhcp from shared networks
    * Execute "ip link add test1g type veth peer name test1gp"
    * Add a new connection of type "bridge" and options "ifname vethbrg con-name vethbrg autoconnect no"
    * Execute "nmcli connection modify vethbrg ipv4.method shared"
    * Execute "nmcli connection modify vethbrg ipv4.address 172.16.0.1/24"
    * Bring "up" connection "vethbrg"
    * Execute "brctl addif vethbrg test1gp"
    * Execute "ip link set dev test1gp up"
    * Execute "ip netns add peers"
    * Execute "ip link set test1g netns peers"
    * Execute "ip netns exec peers ip link set dev test1g up"
    * Execute "ip netns exec peers ip addr add 172.16.0.111/24 dev test1g"
    * Execute "ip netns exec peers ip route add default via 172.16.0.1"
    Then Execute "ip netns exec peers ping -c 2 -I test1g 8.8.8.8"
    Then Unable to ping "172.16.0.111" from "eth0" device


    @rhbz1083683 @rhbz1256772 @rhbz1260243
    @runonce @teardown_testveth @restart
    @run_once_new_connection
    Scenario: NM - general - run once and quit start new ipv4 and ipv6 connection
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general"
    * Execute "nmcli connection modify con_general ipv4.addresses 1.2.3.4/24 ipv4.may-fail no ipv6.addresses 1::128/128 ipv6.may-fail no connection.autoconnect yes"
    * Bring "up" connection "con_general"
    * Disconnect device "testG"
    * Stop NM and clean "testG"
    When "state DOWN" is visible with command "ip a s testG" in "15" seconds
    * Execute "echo '[main]' > /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'configure-and-quit=yes' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'dhcp=internal' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Start NM
    Then "192." is visible with command " ip a s testG |grep 'inet '|grep dynamic" in "60" seconds
    Then "1.2.3.4\/24" is visible with command "ip a s testG |grep 'inet '|grep -v dynamic" in "60" seconds
    Then "2620:" is visible with command "ip a s testG |grep 'inet6'|grep  dynamic" in "60" seconds
    Then "1::128\/128" is visible with command "ip a s testG |grep 'inet6'" in "60" seconds
    Then "default via 192" is visible with command "ip r |grep testG" in "60" seconds
    Then "1.2.3.0\/24" is visible with command "ip r |grep testG" in "60" seconds
    Then "1::128" is visible with command "ip -6 r |grep testG" in "60" seconds
    Then "nm-iface-helper --ifname testG" is visible with command "ps aux|grep helper" in "60" seconds
    Then "inactive" is visible with command "systemctl is-active NetworkManager"


    @rhbz1083683 @rhbz1256772
    @teardown_testveth
    @runonce @restart
    @run_once_ip4_renewal
    Scenario: NM - general - run once and quit ipv4 renewal
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general"
    * Bring "up" connection "con_general"
    * Disconnect device "testG"
    * Stop NM and clean "testG"
    When "state DOWN" is visible with command "ip a s testG" in "5" seconds
    * Execute "echo '[main]' > /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'configure-and-quit=yes' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'dhcp=internal' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "sleep 1"
    * Start NM
    * "192" is visible with command " ip a s testG |grep 'inet '|grep dynamic" in "60" seconds
    * Execute "sleep 20"
    # VVV this means that lifetime was refreshed
    When "preferred_lft (119|118|117)sec" is visible with command " ip a s testG" in "100" seconds
    Then "192.168.99" is visible with command " ip a s testG |grep 'inet '|grep dynamic"
    Then "192.168.99.0/24" is visible with command "ip r |grep testG"


    @rhbz1083683 @rhbz1256772
    @teardown_testveth
    @runonce @restart
    @run_once_ip6_renewal
    Scenario: NM - general - run once and quit ipv6 renewal
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general"
    #* Execute "nmcli con modify con_general ipv4.may-fail no ipv6.may-fail no"
    * Bring "up" connection "con_general"
    Then "2620" is visible with command "ip a s testG" in "60" seconds
    Then "192" is visible with command "ip a s testG" in "60" seconds
    * Disconnect device "testG"
    * Stop NM and clean "testG"
    When "state DOWN" is visible with command "ip a s testG" in "5" seconds
    * Execute "echo '[main]' > /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'configure-and-quit=yes' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'dhcp=internal' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "sleep 1"
    * Start NM
    * Force renew IPv6 for "testG"
    When "2620:" is not visible with command "ip a s testG"
    Then "2620:" is visible with command "ip a s testG" in "120" seconds


    @rhbz1201497
    @ver-=1.9.9
    @runonce @restore_hostname @eth0 @restart
    @run_once_helper_for_localhost_localdomain
    Scenario: NM - general - helper running for localhost on localdo
    * Bring "up" connection "testeth0"
    * Disconnect device "eth0"
    * Execute "sleep 2"
    * Stop NM and clean "eth0"
    When "state DOWN" is visible with command "ip a s eth0" in "5" seconds
    * Execute "hostnamectl set-hostname localhost.localdomain"
    * Execute "echo '[main]' > /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'configure-and-quit=yes' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'dhcp=internal' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "ip link set dev eth0 up"
    * Execute "sleep 1"
    * Start NM
    Then "eth0" is visible with command "ps aux|grep helper" in "40" seconds
    Then "eth0" is visible with command "ps aux|grep helper" for full "20" seconds


    @rhbz1201497
    @ver+=1.10
    @runonce @restore_hostname @eth0 @restart
    @run_once_helper_for_localhost_localdomain
    Scenario: NM - general - helper running for localhost on localdo
    * Bring "up" connection "testeth0"
    * Disconnect device "eth0"
    * Execute "sleep 2"
    * Stop NM and clean "eth0"
    When "state DOWN" is visible with command "ip a s eth0" in "5" seconds
    * Execute "hostnamectl set-hostname localhost.localdomain"
    * Execute "echo '[main]' > /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'configure-and-quit=yes' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'dhcp=internal' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    ## VVV Just to make sure slow devices will catch carrier
    * Execute "echo '[device]' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'match-device=interface-name:eth0' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "echo 'carrier-wait-timeout=10000' >> /etc/NetworkManager/conf.d/01-run-once.conf"
    * Execute "sleep 1"
    * Start NM
    Then "eth0" is visible with command "ps aux|grep helper" in "40" seconds
    Then "eth0" is visible with command "ps aux|grep helper" for full "20" seconds


    @rhbz1498943
    @ver+=1.10
    @network_online_target_not_depend_on_wait_online
    Scenario: NM - general - network-online target - no wait-online dep
    Then "No such file or directory" is visible with command "cat /usr/lib/systemd/system/network-online.target.wants/NetworkManager-wait-online.service"


    @rhbz1520865
    @ver+=1.10
    @rhel7_only
    @nm_wait_online_requisite_NM
    Scenario: NM - general - NM wait online - requisite NM
    Then "Requisite=NetworkManager.service" is visible with command "cat /usr/lib/systemd/system/NetworkManager-wait-online.service"


    @rhbz1520865
    @ver+=1.10
    @not_in_rhel
    @nm_wait_online_requires_NM
    Scenario: NM - general - NM wait online - requires NM
    Then "Requires=NetworkManager.service" is visible with command "cat /usr/lib/systemd/system/NetworkManager-wait-online.service"


    @rhbz1086906
    @veth @delete_testeth0 @newveth @con_general_remove @restart
    @wait-online-for-both-ips
    Scenario: NM - general - wait-online - for both ipv4 and ipv6
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general"
    * Execute "nmcli con modify con_general ipv4.may-fail no ipv6.may-fail no"
    * Bring "up" connection "con_general"
    * Disconnect device "testG"
    * Restart NM
    #When "2620:" is not visible with command "ip a s testG"
    * Execute "/usr/bin/nm-online -s -q --timeout=30"
    When "inet .* global" is visible with command "ip a s testG"
    Then "inet6 .* global" is visible with command "ip a s testG"


    @rhbz1498807
    @ver+=1.8.0
    @gen_br_remove @restart
    @wait_online_with_autoconnect_no_connection
    Scenario: NM - general - wait-online - skip non autoconnect soft device connections
    * Add a new connection of type "bridge" and options "con-name gen_br ifname brX autoconnect no"
    * Stop NM
    * Start NM
    Then "PASS" is visible with command "/usr/bin/nm-online -s -q --timeout=30 && echo PASS"


    @rhbz1515027
    @ver+=1.10
    @con_general_remove @delete_testeth0 @remove_custom_cfg @teardown_testveth @restart
    @nm_online_wait_for_delayed_device
    Scenario: NM - general - wait for delayed device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general"
    * Stop NM
    * Prepare simulated veth device "testG" wihout carrier
    * Execute "echo '[device-testG]' > /etc/NetworkManager/conf.d/99-xxcustom.conf"
    * Execute "echo 'match-device=interface-name:testG' >> /etc/NetworkManager/conf.d/99-xxcustom.conf"
    * Execute "echo 'carrier-wait-timeout=20000' >> /etc/NetworkManager/conf.d/99-xxcustom.conf"
    * Execute "sleep 2"
    * Start NM
    * Run child "echo FAIL > /tmp/nm-online.txt && /usr/bin/nm-online -s -q --timeout=35 && echo PASS > /tmp/nm-online.txt"
    When "FAIL" is visible with command "cat /tmp/nm-online.txt"
    * Execute "sleep 10"
    When "FAIL" is visible with command "cat /tmp/nm-online.txt"
     And Execute "ip netns exec testG_ns ip link set testGp up"
    Then "PASS" is visible with command "cat /tmp/nm-online.txt" in "10" seconds


    @rhbz1160013
    @eth_down_and_delete @need_dispatcher_scripts @con_general_remove
    @policy_based_routing
    Scenario: NM - general - policy based routing
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general"
    * Bring "up" connection "con_general"
    * Bring "up" connection "con_general"
    * Create PBR files for profile "con_general" and "eth8" device in table "1"
    * Bring "down" connection "con_general"
    * Bring "up" connection "con_general"
    Then "32764:\s+from 192.168.100.* lookup 1.*32765:\s+from all iif eth8 lookup 1" is visible with command "ip rule"
    Then "default via 192.168.100.1 dev eth8" is visible with command "ip r s table 1"
    * Bring "down" connection "con_general"
    Then "32764:\s+from 192.168.100..* lookup 1.*32765:\s+from all iif eth8 lookup 1" is not visible with command "ip rule"
    Then "default via 192.168.100.1 dev eth8" is not visible with command "ip r s table 1"


    @rhbz1384799
    @ver+=1.10
    @con_general_remove @eth_down_and_delete @need_dispatcher_scripts @teardown_testveth @restart
    @modify_policy_based_routing_connection
    Scenario: NM - general - modify policy based routing connection
    * Prepare simulated test "testG" device
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    * Bring "up" connection "con_general"
    * Create PBR files for profile "con_general" and "testG" device in table "1"
    * Modify connection "con_general" changing options "connection.autoconnect yes ipv6.method ignore"
    * Reboot
    Then "32764:\s+from 192.168.99.* lookup 1.*32765:\s+from all iif testG lookup 1" is visible with command "ip rule" in "20" seconds
     And "default via 192.168.99.1 dev testG" is visible with command "ip r s table 1" in "20" seconds
     And "2620" is not visible with command "ip a s testG" in "10" seconds


    @rhbz1262972
    @con_general_remove
    @nmcli_general_dhcp_profiles_general_gateway
    Scenario: NM - general - auto connections ignore the generic-set gateway
    # Up dhcp connection
    * Bring "up" connection "testeth9"
    # Create a static connection without gateway
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general autoconnect no"
    * Execute "nmcli connection modify con_general ipv4.method manual ipv4.addresses 1.2.3.4/24 ipv4.may-fail no"
    # Set a "general" gateway (normally discouraged)
    * Execute "echo 'GATEWAY=1.2.3.1' >> /etc/sysconfig/network"
    * Reload connections
    # See that we can still 'see' an upped dhcp connection
    Then "testeth9" is visible with command "nmcli connection"
    # And it still has the DHCP originated gateway, ignoring the static general setting
    Then "default via 192.168.100.1 dev eth9" is visible with command "ip route"
    # Check the other one also for the address
    Then "192.168." is visible with command "ip a s eth9"
    * Bring "up" connection "con_general"
    # See we didn't inactive auto connection
    Then "testeth9" is visible with command "nmcli connection"
    # Static connection up and running with given address
    Then "1.2.3.4" is visible with command "ip a s eth8"
    # And it does use the general set gateway
    Then "default via 1.2.3.1 dev eth8" is visible with command "ip route"


    @rhbz1254089
    @teardown_testveth @allow_veth_connections @restart
    @allow_wired_connections
    Scenario: NM - general - create Wired connection for veth devices
    * Prepare simulated test "testG" device
    * Restart NM
    Then "Wired connection" is visible with command "nmcli con"


    @rhbz1182085
    @ver+=1.9
    @netservice @restart
    @nmcli_general_profile_pickup_doesnt_break_network
    Scenario: nmcli - general - profile pickup does not break network service
    * Add a new connection of type "ethernet" and options "ifname * con-name con_general"
    * Add a new connection of type "ethernet" and options "ifname * con-name con_general2"
    * "connected:con_general" is visible with command "nmcli -t -f STATE,CONNECTION device" in "50" seconds
    * "connected:con_general2" is visible with command "nmcli -t -f STATE,CONNECTION device" in "50" seconds
    # Finish asserts the command exited with 0, thus the network service completed properly
    Then Finish "systemctl restart NetworkManager.service && sleep 3 && systemctl restart network.service"


    @rhbz1079353
    @con_general_remove @teardown_testveth
    @nmcli_general_wait_for_carrier_on_new_device_request
    Scenario: nmcli - general - wait for carrier on new device activation request
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    * Prepare simulated veth device "testG" wihout carrier
    * Execute "nmcli con modify con_general ipv4.may-fail no"
    * Execute "nmcli con up con_general" without waiting for process to finish
    * Wait for at least "1" seconds
    * Execute "ip netns exec testG_ns ip link set testGp up"
    * "connected:con_general" is visible with command "nmcli -t -f STATE,CONNECTION device" in "60" seconds
    Then "192" is visible with command "ip a s testG" in "60" seconds
    Then "2620" is visible with command "ip a s testG" in "60" seconds


    # Tied to the bz, though these are not direct verifiers
    @rhbz1079353
    @con_general_remove @need_config_server @teardown_testveth
    @nmcli_general_activate_static_connection_carrier_ignored
    Scenario: nmcli - general - activate static connection with no carrier - ignored
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    * Modify connection "con_general" changing options "ipv4.method manual ipv4.address '192.168.5.11/24' ipv4.gateway '192.168.5.1' ipv6.method ignore"
    * Prepare simulated veth device "testG" wihout carrier
    * Execute "nmcli con up con_general"
    Then "connected:con_general" is visible with command "nmcli -t -f STATE,CONNECTION device" in "60" seconds
    Then "192.168.5.11" is visible with command "ip a s testG" in "60" seconds


    @rhbz1079353
    @con_general_remove @no_config_server @teardown_testveth
    @nmcli_general_activate_static_connection_carrier_not_ignored
    Scenario: nmcli - general - activate static connection with no carrier - not ignored
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no"
    * Modify connection "con_general" changing options "ipv4.method manual ipv4.address '192.168.5.11/24' ipv4.gateway '192.168.5.1' ipv6.method ignore"
    * Prepare simulated veth device "testG" wihout carrier
    * Execute "nmcli con up con_general"
    Then "connected:con_general" is visible with command "nmcli -t -f STATE,CONNECTION device" in "60" seconds
    Then "192.168.5.11" is visible with command "ip a s testG" in "60" seconds


    @rhbz1272974
    @need_s390x
    @remove_ctcdevice
    @ctc_device_recognition
    Scenario: NM - general - ctc device as ethernet recognition
    * Execute "znetconf -a $(znetconf -u |grep CTC |awk 'BEGIN { FS = "," } ; { print $1 }')"
    Then "ethernet" is visible with command "nmcli dev |grep $(znetconf -c |grep ctc | awk '{print $5}')"


    @rhbz1128581
    @con_general_remove @eth0 @teardown_testveth
    @connect_to_slow_router
    Scenario: NM - general - connection up to 60 seconds
    * Prepare simulated test "testM" device
    * Add a new connection of type "ethernet" and options "ifname testM con-name con_general autoconnect no"
    * Modify connection "con_general" changing options "ipv4.method manual ipv4.address '192.168.99.99/24' ipv4.gateway '192.168.99.1' ipv6.method ignore"
    * Append "GATEWAY_PING_TIMEOUT=60" to ifcfg file "con_general"
    * Reload connections
    # VVV Remove gateway's ip address so it is unpingable
    * Execute "ip netns exec testM_ns ip a del 192.168.99.1/24 dev testM_bridge"
    * Run child "nmcli con up con_general"
    When "gateway ping failed with error code 1" is visible with command "journalctl -o cat --since '50 seconds ago' |grep testM" in "20" seconds
    # VVV Add gateway's ip address so it is pingable again
    * Run child "sleep 40 && ip netns exec testM_ns ip a add 192.168.99.1/24 dev testM_bridge"
    Then "connected:con_general" is visible with command "nmcli -t -f STATE,CONNECTION device" in "55" seconds
    And "connected:full" is visible with command "nmcli -t -f STATE,CONNECTIVITY general status"


    @rhbz1034158
    @connect_testeth0 @disp
    @nmcli_monitor
    Scenario: nmcli - monitor
    * Run child "nmcli m 2>&1> /tmp/monitor.txt"
    * Write dispatcher "pre-up.d/98-disp" file with params "sleep 1;"
    * Write dispatcher "pre-down.d/97-disp" file with params "sleep 1;"
    * Bring "down" connection "testeth0"
    * Execute "sleep 1"
    * Bring "up" connection "testeth0"
    * Execute "sleep 1"
    * Execute "pkill -9 nmcli"
    Then "eth0: deactivating" is visible with command "cat /tmp/monitor.txt"
     And "Connectivity is now 'none'" is visible with command "cat /tmp/monitor.txt"
     And "eth0: disconnected" is visible with command "cat /tmp/monitor.txt"
     And "There's no primary connection" is visible with command "cat /tmp/monitor.txt"
     And "Networkmanager is now in the 'disconnected' state" is visible with command "cat /tmp/monitor.txt"
     And "Networkmanager is now in the 'connecting' state" is visible with command "cat /tmp/monitor.txt"
     And "eth0: using connection 'testeth0'" is visible with command "cat /tmp/monitor.txt"
     And "Connectivity is now 'full'" is visible with command "cat /tmp/monitor.txt"
     And "'testeth0' is now the primary connection" is visible with command "cat /tmp/monitor.txt"
     And "Networkmanager is now in the 'connected' state" is visible with command "cat /tmp/monitor.txt"
     And "eth0: connected" is visible with command "cat /tmp/monitor.txt"


    @rhbz998000
    @ver+=1.4.0
    @con_general_remove @disp
    @device_reapply
    Scenario: nmcli - device -reapply
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Bring "up" connection "con_general"
    * Write dispatcher "99-disp" file
    * Execute "ip addr a 1.2.3.4/24 dev eth8"
    * Execute "nmcli c modify con_general +ipv4.address 1.2.3.4/24"
    * Execute "nmcli device reapply eth8"
    When "up" is not visible with command "cat /tmp/dispatcher.txt"
    * Execute "ip addr a 1.2.3.4/24 dev eth8"
    * Execute "nmcli c modify con_general -ipv4.address 1.2.3.4/24"
    * Execute "nmcli device reapply eth8"
    Then "up" is not visible with command "cat /tmp/dispatcher.txt"


    @rhbz1371920
    @ver+=1.4.0
    @con_general_remove @teardown_testveth @kill_dbus-monitor
    @device_dbus_signal
    Scenario: NM - general - device dbus signal
    * Prepare simulated test "testG" device
    * Add connection type "ethernet" named "con_general" for device "testG"
    * Run child "dbus-monitor --system --monitor 'sender=org.freedesktop.NetworkManager' > /tmp/dbus.txt"
    * Bring "up" connection "con_general"
    Then "NetworkManager.Device.Wired; member=PropertiesChanged" is visible with command "grep PropertiesChanged /tmp/dbus.txt"
     And "NetworkManager.Device.Veth; member=PropertiesChanged" is visible with command "grep PropertiesChanged /tmp/dbus.txt"
     And "DBus.Properties; member=PropertiesChanged" is visible with command "grep PropertiesChanged /tmp/dbus.txt"


    @rhbz1404594
    @ver+=1.7.1
    @con_general_remove @kill_dbus-monitor
    @dns_over_dbus
    Scenario: NM - general - publish dns over dbus
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Run child "dbus-monitor --system --monitor 'sender=org.freedesktop.NetworkManager' > /tmp/dbus.txt"
    * Bring "up" connection "con_general"
    Then "string \"nameservers\"\s+variant\s+array\s+\[\s+string" is visible with command "grep -A 10 Dns /tmp/dbus.txt"


    @rhbz1358335
    @ver+=1.4.0
    @NM_syslog_in_anaconda
    Scenario: NM - general - syslog in Anaconda
    Then "NetworkManager" is visible with command "grep NetworkManager /var/log/anaconda/syslog"


    @rhbz1217288
    @ver+=1.4.0
    @con_general_remove
    @snapshot_rollback
    Scenario: NM - general - snapshot and rollback
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Bring "up" connection "con_general"
    * Add connection type "ethernet" named "con_general2" for device "eth9"
    * Bring "up" connection "con_general2"
    * Snapshot "create" for "eth8,eth9"
    * Open editor for connection "con_general"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.4/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general2"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.5/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general2"
    When "1.2.3.4/24" is visible with command "ip a s eth8" in "5" seconds
    When "1.2.3.5/24" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.1" is visible with command "ip r"
    * Snapshot "revert" for "eth8,eth9"
    Then "192.168.100" is visible with command "ip a s eth8" in "5" seconds
     And "192.168.100" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.4/24" is not visible with command "ip a s eth8"
     And "1.2.3.5/24" is not visible with command "ip a s eth8"
     And "1.2.3.1" is not visible with command "ip r"
     And "192.168.100.1" is visible with command "ip r"


    @rhbz1369716
    @ver+=1.8.0
    @con_general_remove
    @snapshot_rollback_all_devices
    Scenario: NM - general - snapshot and rollback all devices
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Bring "up" connection "con_general"
    * Add connection type "ethernet" named "con_general2" for device "eth9"
    * Bring "up" connection "con_general2"
    * Snapshot "create" for "all"
    * Open editor for connection "con_general"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.4/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general2"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.5/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general2"
    When "1.2.3.4/24" is visible with command "ip a s eth8" in "5" seconds
    When "1.2.3.5/24" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.1" is visible with command "ip r"
    * Snapshot "revert" for "all"
    Then "192.168.100" is visible with command "ip a s eth8" in "5" seconds
     And "192.168.100" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.4/24" is not visible with command "ip a s eth8"
     And "1.2.3.5/24" is not visible with command "ip a s eth8"
     And "1.2.3.1" is not visible with command "ip r"
     And "192.168.100.1" is visible with command "ip r"


    @rhbz1369716
    @ver+=1.8.0
    @con_general_remove
    @snapshot_rollback_all_devices_with_timeout
    Scenario: NM - general - snapshot and rollback all devices with timeout
    * Add connection type "ethernet" named "con_general" for device "eth8"
    * Bring "up" connection "con_general"
    * Add connection type "ethernet" named "con_general2" for device "eth9"
    * Bring "up" connection "con_general2"
    * Snapshot "create" for "all" with timeout "10"
    * Open editor for connection "con_general"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.4/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general"
    * Open editor for connection "con_general2"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.2.3.5/24" in editor
    * Submit "set ipv4.gateway 1.2.3.1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "con_general2"
    When "1.2.3.4/24" is visible with command "ip a s eth8" in "5" seconds
    When "1.2.3.5/24" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.1" is visible with command "ip r"
    * Wait for at least "10" seconds
    Then "192.168.100" is visible with command "ip a s eth8" in "5" seconds
     And "192.168.100" is visible with command "ip a s eth9" in "5" seconds
     And "1.2.3.4/24" is not visible with command "ip a s eth8"
     And "1.2.3.5/24" is not visible with command "ip a s eth8"
     And "1.2.3.1" is not visible with command "ip r"
     And "192.168.100.1" is visible with command "ip r"


    @rhbz1369716
    @ver+=1.8.0
    @manage_eth8
    @snapshot_rollback_unmanaged
    Scenario: NM - general - snapshot and rollback unmanaged
    * Execute "nmcli device set eth8 managed off"
    * Snapshot "create" for "eth8" with timeout "10"
    * Execute "nmcli device set eth8 managed on"
    When "unmanaged" is not visible with command "nmcli device show eth8" in "5" seconds
    * Wait for at least "15" seconds
    Then "unmanaged" is visible with command "nmcli device show eth8" in "5" seconds


    @rhbz1464904
    @ver+=1.10.0
    @manage_eth8
    @snapshot_rollback_managed
    Scenario: NM - general - snapshot and rollback managed
    * Execute "nmcli device set eth8 managed on"
    * Snapshot "create" for "eth8" with timeout "10"
    * Execute "nmcli device set eth8 managed off"
    When "unmanaged" is visible with command "nmcli device show eth8" in "5" seconds
    * Wait for at least "15" seconds
    Then "unmanaged" is not visible with command "nmcli device show eth8" in "5" seconds


    @rhbz1369716
    @ver+=1.8.0
    @gen-bond_remove
    @snapshot_rollback_soft_device
    Scenario: NM - general - snapshot and rollback deleted soft device
    * Add connection type "bond" named "gen-bond0" for device "gen-bond"
    * Add slave connection for master "gen-bond" on device "eth8" named "gen-bond0.0"
    * Add slave connection for master "gen-bond" on device "eth9" named "gen-bond0.1"
    * Bring "up" connection "gen-bond0.0"
    * Bring "up" connection "gen-bond0.1"
    When Check slave "eth8" in bond "gen-bond" in proc
    When Check slave "eth9" in bond "gen-bond" in proc
    * Snapshot "create" for "all" with timeout "10"
    * Delete connection "gen-bond0.0"
    * Delete connection "gen-bond0.1"
    * Delete connection "gen-bond0"
    * Wait for at least "15" seconds
    Then Check slave "eth8" in bond "gen-bond" in proc
    Then Check slave "eth9" in bond "gen-bond" in proc


    @rhbz1433303
    @ver+=1.4.0
    @long @gen_br_remove
    @stable_mem_consumption
    Scenario: NM - general - stable mem consumption
    * Execute "sh tmp/repro_1433303.sh"
    * Execute "sh tmp/repro_1433303.sh"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep 'rw---'" as value "1"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep total | awk '{print $3}'" as value "3"
    * Execute "sh tmp/repro_1433303.sh"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep 'rw---'" as value "2"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep total | awk '{print $3}'" as value "4"
    Then Check RSS writable memory in noted value "2" differs from "1" less than "500"
    Then Check noted value "4" difference from "3" is lower than "500"


    @rhbz1461643
    @ver+=1.10.0
    @allow_veth_connections @no_config_server @long
    @stable_mem_consumption2
    Scenario: NM - general - stable mem consumption - var 2
    * Execute "sh tmp/repro_1461643.sh"
    * Execute "sh tmp/repro_1461643.sh"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep 'rw---'" as value "1"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep total | awk '{print $3}'" as value "3"
    * Execute "sh tmp/repro_1461643.sh"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep 'rw---'" as value "2"
    * Note the output of "pmap -x $(pidof NetworkManager) |grep total | awk '{print $3}'" as value "4"
    Then Check RSS writable memory in noted value "2" differs from "1" less than "500"
    Then Check noted value "4" difference from "3" is lower than "750"


    @rhbz1398932
    @ver+=1.7.2
    @BBB
    @dummy_connection
    Scenario: NM - general - create dummy connection
    * Add a new connection of type "dummy" and options "ifname BBB con-name BBB ip4 1.2.3.4/24 autoconnect no"
    * Bring up connection "BBB"
    Then "dummy" is visible with command "ip -d l show BBB | grep dummy"
    Then "1.2.3.4/24" is visible with command "ip a s BBB | grep inet"


    @rhbz1527197
    @ver+=1.10.1
    @BBB
    @dummy_with_qdisc
    Scenario: NM - general - create dummy with qdisc
    * Add a new connection of type "dummy" and options "ifname BBB con-name BBB ipv4.method link-local ipv6.method link-local"
    * Bring up connection "BBB"
    * Bring up connection "BBB"
    * Bring up connection "BBB"
    * Execute "tc qdisc add dev BBB root handle 1234 fq_codel"
    * Bring up connection "BBB"
    Then "dummy" is visible with command "ip -d l show BBB | grep dummy"


    @rhbz1512316
    @ver+=1.10.1
    @BBB
    @do_not_touch_external_dummy
    Scenario: NM - general - do not touch external dummy device
    Then Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"
     And Finish "sh tmp/repro_1512316.sh"


    @rhbz1337997
    @ver+=1.6.0
    @macsec @not_on_aarch64_but_pegas
    @macsec_psk
    Scenario: NM - general - MACsec PSK
    * Prepare MACsec PSK environment with CAK "00112233445566778899001122334455" and CKN "5544332211009988776655443322110055443322110099887766554433221100"
    * Add a new connection of type "ethernet" and options "con-name test-macsec-base ifname macsec_veth ipv4.method disabled ipv6.method ignore"
    * Add a new connection of type "macsec" and options "con-name test-macsec ifname macsec0 autoconnect no macsec.parent macsec_veth macsec.mode psk macsec.mka-cak 00112233445566778899001122334455 macsec.mka-ckn 5544332211009988776655443322110055443322110099887766554433221100"
    * Bring up connection "test-macsec-base"
    * Bring up connection "test-macsec"
    Then Ping "172.16.10.1"


    @rhbz1443114
    @ver+=1.8.0
    @restart
    @non_utf_device
    Scenario: NM - general - non UTF-8 device
    * Execute "ip link add name $'d\xccf\\c' type dummy"
    When "/sys/devices/virtual/net/d\\314f\\\\c" is visible with command "nmcli -f GENERAL.UDI device show"
    * Restart NM
    Then "dummy" is visible with command "nmcli device show 'd\314f\\c'"


    @rhbz1458399
    @ver+=1.8.0
    @firewall @connectivity @con_general_remove @eth0
    @connectivity_check
    Scenario: NM - general - connectivity check
    * Add a new connection of type "ethernet" and options "ifname eth0 con-name con_general autoconnect no ipv6.method ignore"
    * Bring up connection "con_general"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show con_general" in "20" seconds
     And "full" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds
    * Execute "firewall-cmd --panic-on"
    When "limited" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds
    * Execute "firewall-cmd --panic-off"
    Then "full" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds


    @rhbz1458399
    @ver+=1.8.0
    @firewall @connectivity @con_general_remove @delete_testeth0 @restart
    @disable_connectivity_check
    Scenario: NM - general - disable connectivity check
    * Execute "sed -i 's/interval=5/interval=0/' /etc/NetworkManager/conf.d/99-connectivity.conf"
    * Restart NM
    * Add a new connection of type "ethernet" and options "ifname eth0 con-name con_general autoconnect no ipv6.method ignore"
    * Bring up connection "con_general"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show con_general" in "20" seconds
     And "full" is visible with command "nmcli  -g CONNECTIVITY g"
    * Execute "firewall-cmd --panic-on"
    Then "full" is visible with command "nmcli  -g CONNECTIVITY g" for full "70" seconds


    @rhbz1394345
    @ver+=1.8.0
    @con_general_remove @connectivity @eth0
    @per_device_connectivity_check
    Scenario: NM - general - per device connectivity check
    # Device with connectivity but low priority
    * Add a new connection of type "ethernet" and options "ifname eth0 con-name con_general ipv4.route-metric 1024 ipv6.method ignore"
    * Bring up connection "con_general"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show con_general" in "20" seconds
    When "full" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds
    # Device w/o connectivity but with high priority
    * Add a new connection of type "ethernet" and options "ifname eth8 con-name con_general2 autoconnect no ipv4.method manual ipv4.addresses 1.2.3.4/24 ipv4.gateway 1.2.3.1 ipv4.route-metric 100 ipv6.method ignore"
    * Bring up connection "con_general2"
    # Connection should stay at the lower priority device
    Then "full" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds
     And Ping "boston.com"


    @rhbz1534477
    @ver+=1.10
    @firewall @connectivity @con_general_remove @delete_testeth0 @restart @long
    @manipulate_connectivity_check_via_dbus
    Scenario: dbus - general - connectivity check manipulation
    * Add a new connection of type "ethernet" and options "ifname eth0 con-name con_general autoconnect no ipv6.method ignore"
    * Bring up connection "con_general"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show con_general" in "20" seconds
     And "full" is visible with command "nmcli -g CONNECTIVITY g" in "70" seconds
    # VVV Turn off connectivity check
    * Execute "busctl set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled 'b' 0"
    * Execute "sleep 1 && firewall-cmd --panic-on"
    When "false" is visible with command "busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled"
     And "full" is visible with command "nmcli  -g CONNECTIVITY g" for full "70" seconds
    # VVV Turn on connectivity check
    * Execute "busctl set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled 'b' 1"
    When "true" is visible with command "busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled"
     And "limited" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds
    * Execute "firewall-cmd --panic-off"
    Then "full" is visible with command "nmcli  -g CONNECTIVITY g" in "70" seconds


    @rhbz1442361
    @ver+=1.8.3
    @con_general_remove @tuntap
    @keep_external_device_enslaved_on_down
    Scenario: NM - general - keep external device enslaved on down
    # Check that an externally configure device is not released from
    # its master when brought down externally
    * Add a new connection of type "bridge" and options "ifname brX con-name con_general2 autoconnect no"
    * Execute "nmcli connection modify con_general2 ipv4.method disabled ipv6.method ignore"
    * Bring "up" connection "con_general2"
    * Execute "ip tuntap add mode tap tap0"
    * Execute "ip link set tap0 master brX"
    * Execute "ip link set tap0 up"
    * Execute "sleep 2"
    * Execute "ip link set tap0 down"
    Then "master brX" is visible with command "ip link show tap0" for full "5" seconds


    @ver+=1.10
    @add_testeth8 @eth8_disconnect
    @overtake_external_device
    Scenario: nmcli - general - overtake external device
    * Execute "ip add add 1.2.3.4/24 dev eth8"
    When "No such file" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-eth8"
     And "eth8" is visible with command "nmcli -g NAME connection" in "5" seconds
     And "dhclient" is not visible with command "ps aux| grep client-eth8"
    * Execute "nmcli con modify eth8 ipv4.method auto"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show eth8" in "20" seconds
     And "BOOTPROTO=dhcp" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-eth8"
     And "dhclient" is visible with command "ps aux| grep dhclient-eth8"
     And "192.168" is visible with command "ip a s eth8" in "20" seconds


    @rhbz1487702
    @ver+=1.10
    @con_general_remove @no_config_server @teardown_testveth @restart
    @wait_10s_for_flappy_carrier
    Scenario: NM - general - wait for flappy carrier up to 10s
    * Add a new connection of type "ethernet" and options "ifname testG con-name con_general autoconnect no 802-3-ethernet.mtu 9000"
    * Prepare simulated test "testG" device
    * Run child "nmcli con up con_general"
    * Execute "sleep 0.5 && ip link set testG down"
    * Execute "sleep 8"
    * Execute "ip link set testG up"
    When "activated" is visible with command "nmcli -g GENERAL.STATE con show con_general" in "10" seconds
