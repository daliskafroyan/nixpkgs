{
  description = "Example nix-darwin system flake";

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
    configuration = { pkgs, config, ... }: {
      # First, define nixpkgs configuration and custom packages
      nixpkgs.config.allowUnfree = true;

      # Then define system packages
      environment.systemPackages =
        [ 
          pkgs.vim
          pkgs.google-chrome 
          pkgs.code-cursor
          pkgs.raycast
          pkgs.telegram-desktop
          pkgs.starship
          pkgs.go
          pkgs.devenv
        ];

      system.defaults = {
        trackpad = {
          Clicking = true;
        };

        dock = {
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.0;
          showhidden = true;
          mru-spaces = false;
        };
      };

      # Then define home-manager configuration
      home-manager.users.yoranium = { pkgs, ... }: {
        home.stateVersion = "23.11";
        
        # Allow unfree packages in home-manager
        nixpkgs.config.allowUnfree = true;

        programs.vscode = import ./vscode-config.nix { inherit pkgs; };

        programs.git = {
          enable = true;
          userName = "Firsta Royan D.";
          userEmail = "firstaroyan09@gmail.com";
          
          extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = false;
          };
        };
        
        home.file."/Library/Application Support/com.mitchellh.ghostty/config".text = ''
          # Font settings
          font-family = JetBrains Mono Nerd Font
          font-size = 14
          font-feature = liga
          font-feature = calt
          
          # Use the Nix-installed Fish shell
          command = ${pkgs.fish}/bin/fish
          
          theme = cobalt2
          background-opacity = 0.9
          
          # Terminal settings
          shell-integration = fish
          confirm-close-surface = false
          mouse-hide-while-typing = true
          
          # Window settings
          window-padding-x = 10
          window-padding-y = 10
          window-theme = dark
          macos-option-as-alt = true
        '';
        
        # Fish shell configuration
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            # Set fish greeting
            set fish_greeting ""
            
            # Set terminal colors
            set -g fish_color_command blue
            set -g fish_color_param cyan
            set -g fish_color_error red
            
            # Add useful aliases
            alias ll "ls -la"
            alias g git
            
            # Enable Ghostty shell integration for Fish
            if test "$GHOSTTY_RESOURCES_DIR" != ""
              source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
            end
            
            # Initialize Starship prompt
            starship init fish | source
          '';
          
          plugins = [
            # You can add fish plugins here if needed
            # Example:
            # {
            #   name = "z";
            #   src = pkgs.fetchFromGitHub {
            #     owner = "jethrokuan";
            #     repo = "z";
            #     rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
            #     sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
            #   };
            # }
          ];
        };

        # Add Starship configuration
        programs.starship = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            add_newline = false;
            character = {
              success_symbol = "[➜](bold green)";
              error_symbol = "[✗](bold red)";
            };
            # Customize modules as needed
            directory = {
              truncation_length = 3;
              truncate_to_repo = true;
            };
            git_branch = {
              symbol = "🌱 ";
              truncation_length = 20;
            };
            # Add more module customizations as desired
          };
        };
      };

      # Add user configuration, so that home-manager can find it
      users.users.yoranium = {
        name = "yoranium";
        home = "/Users/yoranium";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable Touch ID for sudo authentication
      security.pam.services.sudo_local.touchIdAuth = true;

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Fonts configuration
      fonts = {
        packages = with pkgs.nerd-fonts; [
          fira-code         # FiraCode Nerd Font
          jetbrains-mono    # JetBrains Mono Nerd Font
        ];
      };

      # Set Fish as the default shell system-wide
      # users.users.yoranium.shell = pkgs.fish;
      
      # Make sure Fish is registered as a valid login shell
      # environment.shells = [ pkgs.fish ];

      # Enable Homebrew
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
        };
        brews = [
        ];
        casks = [
          "whatsapp"  
          "orbstack"
          "obsidian"
          "zoom"
          "discord"
          "tor-browser"
          "elmedia-player"
          "openvpn-connect"
          "ghostty"
          "dbeaver-community"
          "transmission"
          "postman"
          "anki"
          "cloudflare-warp"
          "ngrok"
          "cap"
        ];
      };

      # Add to your system configuration section
      environment.variables = {
        GHOSTTY_CONFIG_HOME = "/Users/yoranium/Library/Application Support/com.mitchellh.ghostty";
        PATH = "/opt/homebrew/bin:$PATH";
      };
    };
    
    # Define pkgs for use in devShells
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake .#yoru
    darwinConfigurations."yoru" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        home-manager.darwinModules.home-manager
      ];
    };

    # Add to your outputs
    devShells.aarch64-darwin.default = pkgs.mkShell {
      packages = [ pkgs.fish pkgs.starship ];
      shellHook = ''
        exec ${pkgs.fish}/bin/fish
      '';
    };
  };
}
