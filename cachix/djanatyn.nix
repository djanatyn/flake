{
  nix.settings = {
    substituters = [
      "https://djanatyn.cachix.org"
      "https://ssbm-nix.cachix.org"
    ];
    trusted-public-keys = [
      "djanatyn.cachix.org-1:zSSfIGxx58+oAZWEIwQVnfGBV0t+MlTi6C5zpA7OA5U="
    ];
  };
}
