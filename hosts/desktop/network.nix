{ ... }:

{
  networking = {
    useNetworkd = false;
    useDHCP = false;

    bridges.br0.interfaces = [ "enp6s0" ];

    # VLANs on br0
    vlans = {
      vlan10 = {
        id = 10;
        interface = "br0";
      };
      vlan20 = {
        id = 20;
        interface = "br0";
      };
      vlan40 = {
        id = 40;
        interface = "br0";
      };
    };

    interfaces = {
      # Management IP on native / untagged br0 (carries the default route)
      br0.ipv4.addresses = [
        {
          address = "10.1.0.35";
          prefixLength = 24;
        }
      ];

      vlan10.ipv4.addresses = [
        {
          address = "192.168.10.35";
          prefixLength = 24;
        }
      ];

      vlan20.ipv4.addresses = [
        {
          address = "192.168.1.35";
          prefixLength = 24;
        }
      ];

      vlan40.ipv4.addresses = [
        {
          address = "192.168.40.35";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "10.1.0.1";
      interface = "br0";
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
