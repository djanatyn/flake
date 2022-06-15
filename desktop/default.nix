{ config, pkgs, nixpkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../cachix.nix
  ];

  ssbm.gcc.oc-kmod.enable = true;

  system.stateVersion = "19.09";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  nix = {
    settings.sandbox = true;
    optimise.automatic = true;
    gc.automatic = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users = {
    users = {
      pripripripripri = {
        isNormalUser = true;
        description = "Pritika Dasgupta";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBAZHvtrWNro8nsB5uyat5kpzdwZ1pArC+LvKap2/eNSQJ8TPuMhvvxNru4nEsX9HdMGQX3vVnjflcCuR5oHp/kcNw4IsmQ14OnOc7k3NsY0NnTjaIeL530Vt1ooaddyDJI2pVXx4Fhr8V99wc7Mixu8VdQHPXqIElOC6cSz0/1BTiEB+5wDYidqS4W2YrVyirIMVvdIaKZg8GM953u+QDXhp2J/srLXJyLzHJ0VR/0lbKZiBHvzi8CH/nP1cyFTAvn2yMrMQZqWnGDefWHI3Mq9wnn+J+6WObk9dr0C7a/hZpjfRKUPEOnHBT8bEjadiv+oFgQzNCH9ffJka3XGnZQ7RqcAD2z/dtoXm2kBhOyET5gG2P+1/alHjRzkBW9Zc/X8mxSSj7crXZ4umH+yCw0WXdDi2Swldx7IbuxUc7AeyayaBLN3RfLGHy0H1zHsv8ZPY5NaBNbG9zi3X7y4s+wsqOqdpnI/C5VS1W1KA/j01Z2KVi8OAdtrZSLJ37FO0= prd17@Dbmis-MBP-2"
        ];
      };

      djanatyn = {
        isNormalUser = true;
        description = "Jonathan Strickland";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFQPTKrT397qtitl0hHkl3HysPfnpEm/WmO9f4dC4kLkrHIgs2t9Yvd6z+8C/hufW+e0cVug3sb6xHWFI78+/eCSRQpPWVsE3e6/U5R/EGJqylPLEa/SmB4hB6LpsCnJkeHnD/sVBz/EjFD29wifLFq0Y5keMdxbvUMjkGrep0CD1guYseFJOdFpLF3A5GAnnP2CHgvOT7/Pd2mym5f2Mxp17SF1iYAsx9xId5o6YbmKldz3BN51N+9CROSg9QWuSNCvA7qjflBIPtnBVZFvIN3U56OECZrv9ZY4dY2jrsUGvnGiyBkkdxw4+iR9g5kjx9jPnqZJGSEjWOYSl+2cEQGvvoSF8jPiH8yLEfC+CyFrb5FMbdXitiQz3r3Xy+oLhj8ULhnDdWZpRaJYTqhdS12R9RCoUQyP7tlyMawMxsiCUPH/wcaGInzpeSLZ5BSzVFhhMJ17TX+OpvIhWlmvpPuN0opmfaNGhVdBGFTNDfWt9jjs/OHm6RpVXacfeflP62xZQBUf3Hcat2JOqj182umjjZhBPDCJscfv52sdfkiqwWIc/GwdmKt5HqU+dX7lCFJ1OGF2ymnGEnkUwW+35qX8g2P+Vc4s28MmaO5M1R5UsMFnhtFbLdfLFKn2PEvepvIqyYFMziPzEBya4zBUch/9sd6UN3DV+rA/JB/rBApw== djanatyn@nixos"
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIOiCqSWnlyk3Efun+zeqeR9afQ3gwYV0QF2l9Us15F8BnNkEqZMvVYQipZUJKwyV4P8X7yJP+2G/KGVhW5kG+4= flowercluster"
        ];

        shell = "${pkgs.zsh}/bin/zsh";

        extraGroups =
          [ "wheel" "networkmanager" "docker" "video" "audio" "adb" ];
      };
    };

    extraGroups.vboxusers.members = [ "djanatyn" ];
  };

  boot = with pkgs; {
    extraModprobeConfig = ''
      options gvusb2_sound index=3
    '';

    loader = {
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
      efi.efiSysMountPoint = "/boot";
      # systemd-boot.enable = true;
    };

    kernelPackages = linuxPackages_latest;
    kernelModules = [ "kvm-amd" "kvm" ];

    extraModulePackages = with linuxPackages_latest; [
      v4l2loopback
      # gvusb2 # https://github.com/NixOS/nixpkgs/pull/109560
    ];

    kernelParams = [
      "amdgpu.noretry=0"
      "amdgpu.gpu_recovery=1"
      "amdgpu.lockup_timeout=1000"
      "amdgpu.gttsize=8192"
      "amdgpu.ppfeaturemask=0xfffd3fff"
    ];

    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  hardware = {
    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };

    pulseaudio = {
      enable = true;
      # extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      configFile = pkgs.runCommand "default.pa" { } ''
        sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
          ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
      '';
    };

    bluetooth.enable = true;
  };

  systemd = {
    coredump.enable = true;
    globalEnvironment = { RADV_PERFTEST = "aco"; };

    services = {
      fetch-followers = {
        path = with pkgs; [ bash fetch-followers ];
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/var/db/fetch-followers";
          EnvironmentFile = "/var/db/fetch-followers/secrets";
        };

        script = ''
          fetch-followers
        '';
      };
    };

    timers = {
      fetch-followers-timers = {
        wantedBy = [ "timers.target" ];
        partOf = [ "fetch-followers.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 00:00:00";
          Unit = "fetch-followers.service";
        };
      };
    };
  };

  networking = {
    networkmanager.dns = "systemd-resolved";
    hostName = "voidheart";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 51820 8080 8096 ];
      allowedUDPPorts = [ 51820 ];
    };

    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.2/24" ];

        privateKeyFile = "/root/nixos/wireguard/private";

        peers = [{
          publicKey = "YzTaORCrx2VKE0fKgn8DM+ylv5vMWXSILHjgF4M6EjA=";
          allowedIPs = [ "10.100.0.1" ];

          endpoint = "167.114.113.126:51820";
          persistentKeepalive = 25;
        }];
      };
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host.enable = false;
  };

  services.minidlna = {
    enable = true;
    mediaDirs = [ "/media" ];
  };

  services.tailscale.enable = true;

  # enable grafana with default settings
  services.grafana.enable = true;

  # enable prometheus with node exporter
  services.prometheus.enable = true;
  services.prometheus.exporters.node.enable = true;

  # scrape node exporter
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node_scraper";
      static_configs = [{
        targets = [
          "${
            toString config.services.prometheus.exporters.node.listenAddress
          }:${toString config.services.prometheus.exporters.node.port}"
        ];
      }];
    }
    {
      job_name = "wakatime";
      static_configs = [{ targets = [ "0.0.0.0:9212" ]; }];
    }
  ];

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      layout = "us";
      xkbOptions = "ctrl:nocaps";

      displayManager.defaultSession = "none+xmonad";
      desktopManager.xterm.enable = false;
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };

    openvpn.servers = {
      expressvpn = { config = "config /root/nixos/openvpn/expressvpn.conf"; };
    };

    jackett = {
      enable = false;
      package = pkgs.jackett;
    };

    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    dnsmasq = {
      enable = false;
      servers = [ "8.8.8.8" ];
      extraConfig = ''
        strict-order
        no-resolv
        log-queries
      '';
    };

    udev.extraRules = ''
      # gamecube wii u usb adapter
      ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="666", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device" TAG+="uaccess"
    '';

    syncthing = {
      enable = true;
      user = "djanatyn";
      dataDir = "/home/djanatyn/syncthing";
      configDir = "/home/djanatyn/.config/syncthing";
      guiAddress = "0.0.0.0:8384";
    };

    influxdb = {
      enable = true;
    };

    jellyfin.enable = true;
    openssh.enable = true;
    lorri.enable = true;
    blueman.enable = true;
  };

  security = {
    sudo.wheelNeedsPassword = false;
    pam.enableSSHAgentAuth = true;
  };

  programs = {
    adb.enable = true;
    browserpass.enable = true;
    mtr.enable = true;
    sysdig.enable = true;
    bandwhich.enable = true;
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  environment.systemPackages = with (import ../categories.nix { inherit pkgs; });
    builtins.concatLists [
      # desktop NixOS box
      system
      virtualisation

      # creation
      terminal
      organization
      tmux
      editor
      transform
      git
      development

      # discovery
      search

      # learning
      games
      gameboy
      study

      # trust
      secrets

      # packaging
      nix
      archives
      patches

      # languages
      haskell
      java
      dhall
      python

      # internet
      network
      ssh
      browser
      torrents
      mail

      # cloud
      google

      # disk
      filesystem

      # social
      chat
      streaming

      # ui
      xorg

      # audio
      music
      sound

      # voidheart-specific rituals
      voidheart
    ];
}
