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
          # pkgs.whatsapp-for-mac
          pkgs.raycast
          pkgs.telegram-desktop
          (pkgs.writeScriptBin "switch-cursor-theme" ''
            #!${pkgs.bash}/bin/bash
            SETTINGS_FILE="$HOME/Library/Application Support/Cursor/User/settings.json"
            
            # Default to toggle if no argument provided
            if [ -z "$1" ]; then
              # Check current theme and toggle
              if grep -q "Catppuccin Latte" "$SETTINGS_FILE" 2>/dev/null; then
                THEME="Catppuccin Macchiato"
                ICON_THEME="catppuccin-macchiato"
                echo "Switching to dark theme"
              else
                THEME="Catppuccin Latte"
                ICON_THEME="catppuccin-latte"
                echo "Switching to light theme"
              fi
            else
              # Use provided argument
              case "$1" in
                light|latte)
                  THEME="Catppuccin Latte"
                  ICON_THEME="catppuccin-latte"
                  ;;
                dark|macchiato)
                  THEME="Catppuccin Macchiato"
                  ICON_THEME="catppuccin-macchiato"
                  ;;
                *)
                  echo "Unknown theme: $1"
                  echo "Usage: switch-cursor-theme [light|dark]"
                  exit 1
                  ;;
              esac
            fi
            
            # Create temp file with new settings
            TEMP_FILE=$(mktemp)
            cat > "$TEMP_FILE" << EOF
            {
              "window.commandCenter": 1,
              "editor.fontFamily": "JetBrains Mono, 'Courier New', monospace",
              "editor.fontLigatures": true,
              "workbench.colorTheme": "$THEME",
              "workbench.iconTheme": "$ICON_THEME",
              "catppuccin.accentColor": "blue",
              "catppuccin.bracketMode": "rainbow"
            }
            EOF
            
            # Ensure directory exists
            mkdir -p "$(dirname "$SETTINGS_FILE")"
            
            # Move the file with proper permissions
            mv "$TEMP_FILE" "$SETTINGS_FILE"
            
            # Set proper ownership
            chown $(whoami) "$SETTINGS_FILE"
            chmod 644 "$SETTINGS_FILE"
            
            echo "$(date): Updated Cursor theme to $THEME" >> /tmp/cursor-theme-switch.log
          '')
        ];

      # Add macOS system preferences to hide the dock
      system.defaults.dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        showhidden = true;
        mru-spaces = false;
      };

      # Add launchd service for theme switching
      launchd.agents.cursor-theme-switch = {
        serviceConfig = {
          ProgramArguments = [ "${pkgs.bash}/bin/bash" "-c" "switch-cursor-theme" ];
          StartCalendarInterval = [
            { Hour = 7;  Minute = 0; }  # Switch to light theme at 7 AM
            { Hour = 19; Minute = 0; }  # Switch to dark theme at 7 PM
          ];
          StandardErrorPath = "/tmp/cursor-theme-switch.err.log";
          StandardOutPath = "/tmp/cursor-theme-switch.out.log";
          RunAtLoad = true;
          UserName = "yoranium";  # Run as your user
        };
      };

      # Then define home-manager configuration
      home-manager.users.yoranium = { pkgs, ... }: {
        home.stateVersion = "23.11";
        
        # Add Git configuration
        programs.git = {
          enable = true;
          userName = "Firsta Royan D.";
          userEmail = "firstaroyan09@gmail.com";
          
          # Optional: Add additional Git configurations if needed
          extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = false;
          };
        };
        
        home.file."Library/Application Support/Cursor/User/settings.json" = {
          text = builtins.toJSON {
            "window.commandCenter" = 1;
            "editor.fontFamily" = "JetBrains Mono, 'Courier New', monospace";
            "editor.fontLigatures" = true;
            "workbench.colorTheme" = "Catppuccin Latte";
            "workbench.iconTheme" = "catppuccin-latte";
            "catppuccin.accentColor" = "blue";
            "catppuccin.bracketMode" = "rainbow";
          };
        };

        home.file."Library/Application Support/Cursor/User/extensions".source = let
          extensions = [
            pkgs.vscode-extensions.bbenoist.nix
            pkgs.vscode-extensions.catppuccin.catppuccin-vsc
            pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons  # Add icons package
          ];
        in pkgs.symlinkJoin {
          name = "cursor-extensions";
          paths = extensions;
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
      # programs.fish.enable = true;

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
          "super-productivity"
        ];
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#yoru
    darwinConfigurations."yoru" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
