{ modulesPath, config, pkgs, nixpkgs, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  system.stateVersion = "22.05";

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  # user account
  users = {
    users = {
      root = {
        openssh.authorizedKeys.keys = [
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIOiCqSWnlyk3Efun+zeqeR9afQ3gwYV0QF2l9Us15F8BnNkEqZMvVYQipZUJKwyV4P8X7yJP+2G/KGVhW5kG+4= flowercluster"
        ];
      };
      djanatyn = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFQPTKrT397qtitl0hHkl3HysPfnpEm/WmO9f4dC4kLkrHIgs2t9Yvd6z+8C/hufW+e0cVug3sb6xHWFI78+/eCSRQpPWVsE3e6/U5R/EGJqylPLEa/SmB4hB6LpsCnJkeHnD/sVBz/EjFD29wifLFq0Y5keMdxbvUMjkGrep0CD1guYseFJOdFpLF3A5GAnnP2CHgvOT7/Pd2mym5f2Mxp17SF1iYAsx9xId5o6YbmKldz3BN51N+9CROSg9QWuSNCvA7qjflBIPtnBVZFvIN3U56OECZrv9ZY4dY2jrsUGvnGiyBkkdxw4+iR9g5kjx9jPnqZJGSEjWOYSl+2cEQGvvoSF8jPiH8yLEfC+CyFrb5FMbdXitiQz3r3Xy+oLhj8ULhnDdWZpRaJYTqhdS12R9RCoUQyP7tlyMawMxsiCUPH/wcaGInzpeSLZ5BSzVFhhMJ17TX+OpvIhWlmvpPuN0opmfaNGhVdBGFTNDfWt9jjs/OHm6RpVXacfeflP62xZQBUf3Hcat2JOqj182umjjZhBPDCJscfv52sdfkiqwWIc/GwdmKt5HqU+dX7lCFJ1OGF2ymnGEnkUwW+35qX8g2P+Vc4s28MmaO5M1R5UsMFnhtFbLdfLFKn2PEvepvIqyYFMziPzEBya4zBUch/9sd6UN3DV+rA/JB/rBApw== djanatyn@nixos"
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIOiCqSWnlyk3Efun+zeqeR9afQ3gwYV0QF2l9Us15F8BnNkEqZMvVYQipZUJKwyV4P8X7yJP+2G/KGVhW5kG+4= flowercluster"
        ];
      };
      penny = {
        description = "system account for Discord-Red";
        isSystemUser = true;
        group = "penny";
      };
    };

    groups.penny = {};

    # elegy for hallownest
    motd = ''
      In wilds beyond they speak your name with reverence and regret,
      For none could tame our savage souls yet you the challenge met,
      Under palest watch, you taught, we changed, base instincts were redeemed,
      A world you gave to bug and beast as they had never dreamed.
    '';
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  networking = {
    hostName = "ramuh";
    useDHCP = false;
    # nameservers = [ "8.8.8.8" ];
    # defaultGateway = "142.4.203.1";

    # interfaces."ens3" = {
    #   ipv4.addresses = [{
    #     address = "142.4.203.33";
    #     prefixLength = 24;
    #   }];
    # };

    firewall = {
      enable = true;

      checkReversePath = false;

      allowedTCPPorts = [ 1234 8888 7777 51820 8080 8384 ];
      allowedUDPPorts = [ 1234 7777 51820 8080 ];
    };
  };

  # systemd.services = {
  #   "penny-redbot" = {
  #     path = with pkgs; [ python3 jdk11_headless ];
  #     wantedBy = [ "multi-user.target" ];
  #     after = [ "network.target" ];

  #     serviceConfig = {
  #       ExecStart = "/home/djanatyn/.discordred/bin/redbot penny";
  #       User = "penny";
  #       Restart = "always";
  #     };
  #   };
  # };

  services = {
    tailscale.enable = true;

    miniflux = {
      enable = true;
      adminCredentialsFile = "/run/keys/minifluxAdmin";
      config = { "LISTEN_ADDR" = "0.0.0.0:8080"; };
    };

    # postgresql.package = pkgs.postgresql_12;
    # postgresql.dataDir = "/var/lib/postgresql/12";

    # syncthing = {
    #   enable = true;
    #   user = "djanatyn";
    #   dataDir = "/home/djanatyn/syncthing";
    #   configDir = "/home/djanatyn/.config/syncthing";
    #   guiAddress = "10.100.0.1:8384";
    # };

    openssh = {
      enable = true;
      ports = [ 8888 ];
    };

    fail2ban.enable = true;
  };

  nixpkgs.config = { allowUnfree = true; };

  virtualisation.docker.enable = true;

  security.sudo = {
    wheelNeedsPassword = false;
    extraRules = [{ 
      users = ["djanatyn"];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl restart penny-redbot";
        options = [ "NOPASSWD" ];
      }];
    }];
  };

  environment.systemPackages = with pkgs; [
    zsh
    openjdk8
    consul
    nomad
    vim
    exa
    git
    python
    tmux
    fzy
    zip
    unzip
    starship
    cachix
  ];

}
