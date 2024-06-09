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
        [ pkgs.vim ];

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
              "Lilex"
            ]; 
          }
        )
      ];

      homebrew = {
       enable = true;
       brews = [
          "postgresql@14" # test postgres connection
       ];
       casks = [
          "google-chrome" 
          "visual-studio-code"
          "obsidian"
          "postman"
          "orbstack"
          "pritunl"
          "dbeaver-community"
          "intellij-idea"
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
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          shellAliases = {
            ls = "ls --color=auto -F";
            nixswitch = "darwin-rebuild switch --flake ~/src/system-config/.#";
            nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd";
          };
          plugins = [
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
            {
              name = "powerlevel10k-config";
              src = ./.;
              file = "p10k.zsh";
            }
          ];
          localVariables = {
            # disable configuration wizard
			      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
          };
          # oh-my-zsh = {
          #   enable = true;
          #   plugins = [ "git" ];
          #   custom = "$HOME/.config/zsh_nix/custom";
          # };
        };
        programs.starship.enable = true;
        programs.starship.enableZshIntegration = true;
        programs.starship.settings = {
          character = {
            success_symbol = "[>](bold green)";
            error_symbol = "[x](bold red)";
            vimcmd_symbol = "[<](bold green)";
          };

          git_commit.tag_symbol = " tag ";

          git_status = {
            ahead = ">";
            behind = "<";
            diverged = "<>";
            renamed = "r";
            deleted = "x";
          };

          aws.symbol = "aws ";
          azure.symbol = "az ";
          bun.symbol = "bun ";
          c.symbol = "C ";
          cobol.symbol = "cobol ";
          conda.symbol = "conda ";
          crystal.symbol = "cr ";
          cmake.symbol = "cmake ";
          daml.symbol = "daml ";
          dart.symbol = "dart ";
          deno.symbol = "deno ";
          dotnet.symbol = ".NET ";
          directory.read_only = " ro";
          docker_context.symbol = "docker ";
          elixir.symbol = "exs ";
          elm.symbol = "elm ";
          fennel.symbol = "fnl ";
          fossil_branch.symbol = "fossil ";
          gcloud.symbol = "gcp ";
          git_branch.symbol = "git ";
          golang.symbol = "go ";
          gradle.symbol = "gradle ";
          guix_shell.symbol = "guix ";
          hg_branch.symbol = "hg ";
          java.symbol = "java ";
          julia.symbol = "jl ";
          kotlin.symbol = "kt ";
          lua.symbol = "lua ";
          nodejs.symbol = "nodejs ";
          memory_usage.symbol = "memory ";
          meson.symbol = "meson ";
          nim.symbol = "nim ";
          nix_shell.symbol = "nix ";
          ocaml.symbol = "ml ";
          opa.symbol = "opa ";
          os.symbols = {
            Alpaquita = "alq ";
            Alpine = "alp ";
            Amazon = "amz ";
            Android = "andr ";
            Arch = "rch ";
            Artix = "atx ";
            CentOS = "cent ";
            Debian = "deb ";
            DragonFly = "dfbsd ";
            Emscripten = "emsc ";
            EndeavourOS = "ndev ";
            Fedora = "fed ";
            FreeBSD = "fbsd ";
            Garuda = "garu ";
            Gentoo = "gent ";
            HardenedBSD = "hbsd ";
            Illumos = "lum ";
            Linux = "lnx ";
            Mabox = "mbox ";
            Macos = "mac ";
            Manjaro = "mjo ";
            Mariner = "mrn ";
            MidnightBSD = "mid ";
            Mint = "mint ";
            NetBSD = "nbsd ";
            NixOS = "nix ";
            OpenBSD = "obsd ";
            OpenCloudOS = "ocos ";
            openEuler = "oeul ";
            openSUSE = "osuse ";
            OracleLinux = "orac ";
            Pop = "pop ";
            Raspbian = "rasp ";
            Redhat = "rhl ";
            RedHatEnterprise = "rhel ";
            Redox = "redox ";
            Solus = "sol ";
            SUSE = "suse ";
            Ubuntu = "ubnt ";
            Unknown = "unk ";
            Windows = "win ";
          };
          package.symbol = "pkg ";
          perl.symbol = "pl ";
          php.symbol = "php ";
          pijul_channel.symbol = "pijul ";
          pulumi.symbol = "pulumi ";
          purescript.symbol = "purs ";
          python.symbol = "py ";
          raku.symbol = "raku ";
          ruby.symbol = "rb ";
          rust.symbol = "rs ";
          scala.symbol = "scala ";
          spack.symbol = "spack ";
          solidity.symbol = "solidity ";
          status.symbol = "[x](bold red) ";
          sudo.symbol = "sudo ";
          swift.symbol = "swift ";
          typst.symbol = "typst ";
          terraform.symbol = "terraform ";
          zig.symbol = "zig ";
        };
        programs.alacritty = {
          enable = true;
          settings.font.normal.family = "JetBrainsMono Nerd Font";
          settings.font.size = 12;
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
