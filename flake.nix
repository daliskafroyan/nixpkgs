{
  description = "daliskafroyan personal nix home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
     nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [ pkgs.vim
        ];

      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      nix.settings.experimental-features = "nix-command flakes";

      programs.zsh.enable = true;
      # programs.fish.enable = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 4;

      nixpkgs.hostPlatform = "aarch64-darwin";

      users.users.yoake = {
        name = "yoake";
        home = "/Users/yoake";
      };

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        (nerdfonts.override { 
            fonts = [ 
              "FiraCode" 
              "JetBrainsMono" 
            ]; 
          }
        )
      ];

      homebrew = {
       enable = true;
       casks = [
          "google-chrome" 
          "visual-studio-code"
          "obsidian"
        ];
      };
    };
    homeconfig = { pkgs, ... }: {
        # this is internal compatibility configuration for home-manager, 
        # don't change this!
        home.stateVersion = "23.05";
        # Let home-manager install and manage itself.
        programs.home-manager.enable = true;

        home.packages = with pkgs; [ ];

        programs.git = {
          enable = true;
          userName = "Daliska F. Royan";
          userEmail = "firstaroyan09@gmail.com";
          ignores = [ ".DS_Store" ];
          extraConfig = {
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
          };
        };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#yoake
    # or
    # $ nix run nix-darwin -- switch --flake .#yoake
    darwinConfigurations."yoake" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.yoake = homeconfig;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."yoake".pkgs;
  };
}
