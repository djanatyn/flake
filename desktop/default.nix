{ config, pkgs, nixpkgs, ... }: {
  imports = [ ./hardware-configuration.nix ../cachix.nix ];

  ssbm.gcc.oc-kmod.enable = true;

  system.stateVersion = "19.09";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  nix = {
    settings.sandbox = true;
    optimise.automatic = true;
    gc.automatic = true;
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

    extraModulePackages = with linuxPackages_latest;
      [
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
      build-system = {
        path = with pkgs; [ bash nixos-rebuild git ];
        serviceConfig = {
          Type = "oneshot";
          Environment = [
            "FLAKE=/home/djanatyn/hack/flake" # better path?
          ];

        };

        script = ''
          nixos-rebuild build --impure --flake "$FLAKE#desktop"
        '';
      };

      run-backups = {
        # to initialize a backup repository:
        # 1. generate a password
        # $ pass generate backups/music/password
        #
        # 2. initialize borg repository
        # $ BORG_PASSCOMMAND="pass show backups/music/password" \
        #   borg init -e repokey /archive/music
        #
        # 3. store password + repokey with systemd-creds
        # $ pass show backups/music/password | sudo systemd-creds encrypt --name=music - /var/lib/backups/music.creds
        # $ borg key export /archive/shell-history | pass insert -m backups/shell-history/borg-key
        #
        # 4. run initial backup:
        # $ BORG_PASSCOMMAND="pass show backups/music/password" \
        #   borg create -v --stats "/archive/music::initial backup" ~/music
        #
        # 5. create backblaze bucket
        # $ backblaze-b2 create-bucket djanatyn-shell-history allPrivate
        #
        # 6. add location of credential to LoadCredentialEncrypted:
        # "music:/var/lib/backups/music.creds"
        #
        # 7. specify directory to backup, backblaze bucket, and backup location
        # "MUSIC=/home/djanatyn/music"
        # "MUSIC_BUCKET=b2://djanatyn-music/music"
        # "MUSIC_REPO=/archive/music"
        #
        # 8. add appropriate borg create + backblaze-b2 sync commands to script
        path = with pkgs; [ bash borgbackup backblaze-b2 coreutils ];
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/var/lib/backups";
          # https://systemd.io/CREDENTIALS/
          LoadCredentialEncrypted = [
            "borg-notes:/var/lib/backups/borg-notes.creds"
            "shell-history:/var/lib/backups/shell-history.creds"
            "music:/var/lib/backups/music.creds"
            "backblaze-b2-key-id:/var/lib/backups/backblaze-b2-key-id.creds"
            "backblaze-b2-key:/var/lib/backups/backblaze-b2-key.creds"
          ];
          Environment = [
            # directories to back up (mostly local SSD)
            "NOTES=/home/djanatyn/org-roam"
            "SHELL_HISTORY=/home/djanatyn/.zsh_history"
            "MUSIC=/home/djanatyn/music"
            # backblaze b2 buckets (cloud)
            "NOTES_BUCKET=b2://djanatyn-notes/notes"
            "SHELL_HISTORY_BUCKET=b2://djanatyn-shell-history/shell-history"
            "MUSIC_BUCKET=b2://djanatyn-music/music"
            # borg repositories (NAS)
            "NOTES_REPO=/archive/notes"
            "SHELL_HISTORY_REPO=/archive/shell-history"
            "MUSIC_REPO=/archive/music"
          ];
        };

        script = ''
          # run backups with borg
          BORG_PASSCOMMAND='systemd-creds cat borg-notes' \
            borg create -v --stats "$NOTES_REPO::automated-$(date +%F-%T)" $NOTES
          BORG_PASSCOMMAND='systemd-creds cat shell-history' \
            borg create -v --stats "$SHELL_HISTORY_REPO::automated-$(date +%F-%T)" $SHELL_HISTORY
          BORG_PASSCOMMAND='systemd-creds cat music' \
            borg create -v --stats "$MUSIC_REPO::automated-$(date +%F-%T)" $MUSIC

          # TODO: what other backups?
          # - ~/hack directory

          # upload to backblaze-b2
          export B2_APPLICATION_KEY_ID="$(systemd-creds cat backblaze-b2-key-id)"
          export B2_APPLICATION_KEY="$(systemd-creds cat backblaze-b2-key)"
          backblaze-b2 sync $NOTES_REPO $NOTES_BUCKET
          backblaze-b2 sync $SHELL_HISTORY_REPO $SHELL_HISTORY_BUCKET
          backblaze-b2 sync $MUSIC_REPO $MUSIC_BUCKET
        '';
      };
    };

    # TODO: add mbsync creds + job + timer
    timers = {
      run-backups-timer = {
        wantedBy = [ "timers.target" ];
        partOf = [ "run-backups.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 01:00:00";
          Unit = "run-backups.service";
        };
      };

      build-system-timer = {
        wantedBy = [ "timers.target" ];
        partOf = [ "build-system.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00";
          Unit = "build-system.service";
        };
      };
    };
  };

  networking = {
    networkmanager.dns = "systemd-resolved";
    hostName = "voidheart";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 51820 8080 8096 9117 ];
      allowedUDPPorts = [ 51820 1900 7359 ];
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

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_14;
  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    listenAddresses = [{
      addr = "0.0.0.0";
      port = 22;
    }];
  };

  # enable grafana with default settings
  # services.grafana.enable = true; TODO: fix grafana

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
      expressvpn = {
        config = "config /root/nixos/openvpn/expressvpn.conf";
        autoStart = false;
      };
    };

    jackett = {
      enable = true;
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

    udev.extraRules = ''
      # gamecube wii u usb adapter
      ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="666", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device" TAG+="uaccess"

      # tomu: https://github.com/im-tomu/chopstx/tree/efm32/u2f#update-udev-rules
      ACTION=="add|change", KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="cdab", TAG+="uaccess"
    '';

    syncthing = {
      enable = true;
      user = "djanatyn";
      dataDir = "/home/djanatyn/syncthing";
      configDir = "/home/djanatyn/.config/syncthing";
      guiAddress = "0.0.0.0:8384";
    };

    influxdb = { enable = true; };

    jellyfin.enable = true;
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

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  environment.systemPackages =
    with (import ../categories.nix { inherit pkgs; });
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

      # gaming
      games
      gameboy
      doom

      # learning
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
      erlang
      zig
      deno
      ponylang

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
