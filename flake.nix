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
        ];

      # Add macOS system preferences to hide the dock
      system.defaults.dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        showhidden = true;
        mru-spaces = false;
      };

      # Then define home-manager configuration
      home-manager.users.yoranium = { pkgs, ... }: {
        home.stateVersion = "23.11";
        
        # Allow unfree packages in home-manager
        nixpkgs.config.allowUnfree = true;

        programs.vscode = {
          enable = true;
          package = pkgs.vscode;
          profiles.default = {
            extensions = with pkgs.vscode-extensions; [
              bbenoist.nix
            ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "theme-cobalt2";
                publisher = "wesbos";
                version = "2.5.0";
                sha256 = "0xvhbzxkpi0yqp8m01dgrakkz6djzzviafh33dvpz9bma85jq8ly";
              }
              {
                name = "monica-code";
                publisher = "monicaim";
                version = "1.3.153";
                sha256 = "1g0ljda8f03qsgsdzha13b1ky0p2mv7mvwg1xn8dhnb97dqpxd1a";
              }
            ];
            userSettings = {
              "git.autofetch" = true;
              "git.enableSmartCommit" = true;
              "git.confirmSync" = false;

              "editor.formatOnSave" = true;
              "files.autoSave" = "onFocusChange";

              "window.commandCenter" = 1;
              "editor.fontFamily" = "'JetBrains Mono Nerd Font', monospace";
              "editor.fontLigatures" = true;
              "workbench.colorTheme" = "Cobalt2";
              "workbench.iconTheme" = "vs-seti";
              "workbench.sideBar.location": "right"
            };
          };
        };

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
        ];
      };

      # Add to your system configuration section
      environment.variables = {
        GHOSTTY_CONFIG_HOME = "/Users/yoranium/Library/Application Support/com.mitchellh.ghostty";
      };
    };
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
  };
}
