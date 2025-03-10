{
  description = "lmatas nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew start
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    # Homebrew end

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew
    , homebrew-core, homebrew-cask, homebrew-bundle }:
    let
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          
          mkalias
          nixfmt-classic
          neovim
          tmux
          oh-my-posh
          alacritty
          lazygit
          lazydocker
          ripgrep          
          jdk11
          maven
          browsh
          macmon
          tabiew


          python312
          python312Packages.pip

          nodejs_20
          yarn

          ruby_3_1
          bundler
          gnumake
            
          lua-language-server
          solargraph 
          bash-language-server
          jdt-language-server
          pyright
  

        ];

        # nerd fonts
        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.nerd-fonts.meslo-lg

        ];

        environment.variables = {
          JAVA_HOME = "${pkgs.openjdk11}/zulu-11.jdk/Contents/Home";
          PATH = "$JAVA_HOME/bin:$PATH";
        };

        # Add this section:
        users.users.lmatas = { home = "/Users/lmatas"; };

        # homebrew casks
        homebrew = {
          enable = true;
          casks = [
            "firefox"
            "google-chrome"
            "the-unarchiver"


          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

        # Set up applications in /Applications.
        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

        # Set up user mac system defaults.
        system.defaults = {

          dock.autohide = false;
          finder.FXPreferredViewStyle = "clmv";

        };

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # touchid in mac
        security.pam.services.sudo_local.touchIdAuth = true;

        # unfree 
        nixpkgs.config.allowUnfree = true;

      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mini
      darwinConfigurations."mini" =

        nix-darwin.lib.darwinSystem {
          modules = [
            configuration

            # Homebrew
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = "lmatas";

                # Optional: Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };

                # Optional: Enable fully-declarative tap management
                #
                # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                mutableTaps = false;
              };
            } # nix-homebrew

          ];
        };
    };
}
