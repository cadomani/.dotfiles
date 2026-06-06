. "$HOME/.cargo/env"

# Nix: ensure profile bins (nixd, nixfmt, anything from `nix profile add`) are on
# PATH for every shell, including non-login shells that Neovim/GUI apps inherit.
# Arch's /etc/profile.d/nix-daemon.sh only runs for login shells, so tools were
# missing in editor-spawned shells. Portable: only prepends dirs that exist.
for _nix_bin in "$HOME/.nix-profile/bin" "$HOME/.local/state/nix/profiles/profile/bin"; do
    if [ -d "$_nix_bin" ] && [[ ":$PATH:" != *":$_nix_bin:"* ]]; then
        export PATH="$_nix_bin:$PATH"
    fi
done
unset _nix_bin
