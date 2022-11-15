{ config, pkgs, nixpkgs, ... }: {
  imports = [
    ../cachix.nix
  ];
  system.stateVersion = "22.05";

  # Bootloader.
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.initrd.luks.devices = { root = { device = "/dev/nvme0n1p2"; preLVM = true; }; };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d51f31dc-ad76-42a5-8b32-753a934e865e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5F1A-EF92";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a5be0c90-cb07-41fe-816d-b9d1e3808d33"; }
    ];

  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.sandbox = true;
    optimise.automatic = true;
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users.djanatyn = {
    isNormalUser = true;
    description = "Jonathan Strickland";
    group = "users";
    extraGroups =
      [ "wheel" "networkmanager" "docker" "video" "disk" "audio" "adb" ];
    shell = "${pkgs.zsh}/bin/zsh";
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
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };

    bluetooth.enable = true;
  };

  systemd = {
    coredump.enable = true;
  };

  networking = {
    hostName = "djan-oso"; # Define your hostname.
    nameservers = [ "8.8.8.8" ];
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 8080 8096 ];
      allowedUDPPorts = [ 51820 ];
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host.enable = false;
  };

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
  ];

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      layout = "us";
      xkbOptions = "ctrl:nocaps";
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

    tailscale.enable = true;

    openssh.enable = true;
    blueman.enable = true;
    pcscd.enable = true;
  };

  security = {
    pam.enableSSHAgentAuth = true;
  };

  programs = {
    adb.enable = true;
    browserpass.enable = true;
    mtr.enable = true;
    bandwhich.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableSSHSupport = true;
    };
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
      python
      erlang
      zig
      deno

      # internet
      network
      ssh
      browser
      mail

      # cloud
      google

      # disk
      filesystem

      # social
      chat

      # ui
      xorg

      # audio
      music
      sound
    ];
}
