# home.nix
{ config, pkgs, ... }:

{

  home.stateVersion = "23.11"; # Or a different version if appropriate

  #home.homeDirectory = pkgs.lib.mkDefault "/Users/lmatas"; # Use mkDefault!

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux"; # Or /bin/zsh, etc.
        args = [ "new-session" "-A" "-s" "default" ];
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font"; # Nombre de la fuente
          style = "Regular"; # Estilo (Regular, Bold, Italic, etc.)
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
        size = 12.0; # Tamaño de la fuente (en puntos)
      };
    };
  };

  programs.tmux = { enable = true; };

  programs.oh-my-posh = {
    enable = true;
    settings =
      builtins.fromJSON (builtins.readFile ./oh-my-posh/atomic.omp.json);

  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
   
  };

  xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;  # Asegura que todos los subdirectorios se copien
  };

}
