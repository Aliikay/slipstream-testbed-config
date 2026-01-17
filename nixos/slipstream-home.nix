{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # BTOP
  programs.btop = {
    enable = true;
    #settings = {
    #  color_theme = "horizon";
    #  theme_background = false;
    #};
  };

  # Update desktop entry
  xdg.desktopEntries = {
    update = {
      name = "Update System";
      genericName = "System Utility";
      exec = "${pkgs.writeShellScript "update-system" ''
        sudo nixos-rebuild switch --flake github:Aliikay/slipstream-testbed-config\#slipstream-testbed --show-trace
      ''}";
      terminal = true;
      categories = [
        "System"
        "Utility"
      ];
    };
  };

  # Atuin
  programs.atuin.enable = true;

  # Fish
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      # Only show fetch on top level shells
      if test "$SHLVL" = 2
        # fastfetch -l "None"
        # hyfetch
      end
      # fish_config prompt choose scales
      bind up _atuin_bind_up
      eval "$(atuin init fish)"

      # Load my user functions
      y
      ns
    '';

    plugins = [
      #{ name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "pisces";
        src = pkgs.fishPlugins.pisces.src;
      }
    ];

    functions = {
      # Allows Yazi to be opened with y and close into the current directory in the terminal
      y = "function y
       	set tmp (mktemp -t \"yazi-cwd.XXXXXX\")
       	yazi $argv --cwd-file=\"$tmp\"
       	if read -z cwd < \"$tmp\"; and [ -n \"$cwd\" ]; and [ \"$cwd\" != \"$PWD\" ]
        		builtin cd -- \"$cwd\"
       	end
       	rm -f -- \"$tmp\"
      end";

      # Nix shell alias
      ns = "function ns
        if test \"$argv\" = \"\"
          echo \"Missing argument\"
          return
        end
        echo \"Entering nix shell with $argv\"
        nix shell nixpkgs#$argv
        echo \"Exiting nix shell with $argv\"
      end";
    };
  };

  # Yazi
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        show_hidden = false;
        sort_dir_first = true;

        #sort_by = "mtime";
        #sort_reverse = true;
        sort_by = "alphabetical";
        sort_reverse = false;
      };
    };
  };

  # Starship
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Zeditor
  programs.zed-editor = {
    enable = true;
    userSettings = {
      soft_wrap = "editor_width";
      diagnostics = {
        inline = {
          enabled = true;
        };
      };
      disable_ai = true;
      helix_mode = false;
      colorize_brackets = true;
    };
  };

  # Micro
  programs.micro = {
    enable = true;
  };

  # Alacritty
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty-graphics;
    settings = {
      window = {
        decorations = "None";
        padding = {
          x = 10;
          y = 10;
        };
        dimensions = {
          columns = 105;
          lines = 28;
        };
      };

      cursor.style = {
        shape = "Beam";
        blinking = "On";
      };
    };
  };

  # Helix
  programs.helix = {
    enable = true;
  };

  # Aliases
  home.shellAliases = {
    cat = "bat --pager=none";
    nano = "micro";
    sbcl = "rlwrap sbcl";
    ls = "eza";
  };

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
