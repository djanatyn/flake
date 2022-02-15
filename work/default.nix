{ config, pkgs, ... }: {
  imports = [ ../cachix.nix ];


  # prefer zsh + emacs
  environment.loginShell = pkgs.zsh;
  environment.variables.EDITOR = "emacsclient";

  nix = {
    trustedUsers = [ "stricklanj" ];
    package = pkgs.nixFlakes;
    trustedBinaryCaches =
      [ "https://cache.nixos.org" "https://all-hies.cachix.org" ];
    settings.sandbox = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # don't auto-fix homestuck typing quirks
  system.defaults = {
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    dock.autohide = true;
  };

  documentation.enable = false;

  time.timeZone = "America/New_York";

  programs = {
    nix-index.enable = true;
    bash.enable = true;
    zsh.enable = true;
  };

  environment.systemPackages =
    with (import ../categories.nix { inherit pkgs; });
    builtins.concatLists [
      # work macbook
      system
      work
      organization

      # creation
      terminal
      tmux
      editor
      (pkgs.lib.remove pkgs.yq transform)
      git
      development

      # discovery
      search

      # trust
      secrets

      # packaging
      nix
      archives

      # internet
      network
      ssh
      mail

      # cloud
      google

      # disk
      filesystem

      # tools
      hashicorp
    ];
}
