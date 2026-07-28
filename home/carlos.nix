# Home configuration for carlos.
#
# Deliberately free of NixOS-only options. This file is meant to be imported unchanged by a
# nix-darwin host later, and that stays cheap only if the coupling never happens in the
# first place. If something here ever needs a NixOS option, it belongs in the host file
# instead, not here.
#
# `home.username` and `home.homeDirectory` are deliberately unset. The NixOS module fills
# both in from the system user, and hardcoding /home/carlos is precisely the line that would
# break on macOS, where the home directory is /Users/carlos.
{
  # Same meaning as system.stateVersion, and the same rule: it records which release's
  # stateful defaults this home was built against, and it is not a version to keep current.
  home.stateVersion = "26.11";

  programs.zsh = {
    enable = true;

    # zsh-autosuggestions. Greys in a suggestion from history as you type, accepted with the
    # right arrow key. Defaults to false, so it has to be asked for.
    autosuggestion.enable = true;

    # zsh-syntax-highlighting. Colours the command line as you type, so a misspelled command
    # is red before you press enter rather than an error afterwards.
    syntaxHighlighting.enable = true;

    # `enableCompletion` already defaults to true, so it is not repeated here. See the
    # matching `environment.pathsToLink` line in the host config, without which completion
    # works for user packages but silently finds nothing for system ones.

    history = {
      # Only values that differ from home-manager's defaults appear here. ignoreDups,
      # ignoreSpace and share are already true upstream; restating them would be noise that
      # implies a decision was made where none was.
      size = 100000;
      save = 100000;

      # Record a timestamp and duration alongside each command. Costs nothing, and is the
      # difference between knowing you ran something and knowing when.
      extended = true;

      # When the history file is trimmed, drop duplicates before unique commands.
      expireDuplicatesFirst = true;
    };
  };

  # Prompt. Chosen over an oh-my-zsh theme because it is a single static binary with no
  # plugin framework underneath it, and it behaves identically under zsh on macOS. Left at
  # its defaults for now: setting `programs.starship.settings` is what generates a
  # starship.toml, and there is nothing yet worth putting in one.
  programs.starship.enable = true;

  programs.git = {
    enable = true;

    # `settings` mirrors git's own config file structure, one attribute per section, and is
    # written to ~/.config/git/config. The older flat options (userName, userEmail,
    # aliases, extraConfig) still work through rename shims but warn on every rebuild, and
    # most guides you will find still show them.
    settings.user = {
      name = "Carlos Domani";
      email = "carlos.a.domani@gmail.com";
    };
  };
}
