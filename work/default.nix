{ config, pkgs, nixpkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../cachix.nix
  ];
  system.stateVersion = "22.05";

  # Bootloader.
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    devices = ["nodev"];
    copyKernels = true;
    efiInstallAsRemovable = true;
    useOSProber = true;
  };

  # boot.loader.systemd-boot.configurationLimit = 42;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot2/efi";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.sandbox = true;
    optimise.automatic = true;
    gc.automatic = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users.jstrickland = {
    isNormalUser = true;
    description = "Jonathan Strickland";
        extraGroups =
          [ "wheel" "networkmanager" "docker" "video" "audio" "adb" ];
    packages = with pkgs; [];
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
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
    hostName = "jon-metafy";

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
      layout = "us";
      xkbOptions = "ctrl:nocaps";

      displayManager.defaultSession = "none+i3";
      windowManager.i3 = {
        enable = true;
	      extraPackages = with pkgs; [
		      dmenu
			    i3status
			    i3lock
	      ];
      };
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

    openssh.enable = true;
    lorri.enable = true;
    blueman.enable = true;
  };

  security = {
    pam.enableSSHAgentAuth = true;
  };

  programs = {
    adb.enable = true;
    browserpass.enable = true;
    mtr.enable = true;
    sysdig.enable = true;
    bandwhich.enable = true;
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
    ];
}
