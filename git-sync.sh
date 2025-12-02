#!/usr/bin/env bash
# Sync dotfiles and nvim subtree with remotes
#
# Usage:
#   ./git-sync.sh push    - Push dotfiles and nvim subtree
#   ./git-sync.sh pull    - Pull dotfiles and nvim subtree (from upstream)

set -e

NVIM_PREFIX="nvim/.config/nvim"
NVIM_REMOTE="git@github.com:cadomani/nvim.git"
NVIM_BRANCH="master"
UPSTREAM_REMOTE="https://github.com/dam9000/kickstart-modular.nvim.git"

case "$1" in
  push)
    echo "==> Pushing dotfiles to origin..."
    git push origin main

    echo "==> Pushing nvim subtree to fork..."
    git subtree push --prefix="$NVIM_PREFIX" "$NVIM_REMOTE" "$NVIM_BRANCH"

    echo "==> Done!"
    ;;

  pull)
    echo "==> Pulling dotfiles from origin..."
    git pull origin main

    echo "==> Pulling nvim subtree from fork..."
    git subtree pull --prefix="$NVIM_PREFIX" "$NVIM_REMOTE" "$NVIM_BRANCH" --squash -m "Pull nvim updates from fork"

    echo "==> Done!"
    ;;

  pull-upstream)
    echo "==> Pulling nvim updates from upstream (kickstart-modular)..."
    git subtree pull --prefix="$NVIM_PREFIX" "$UPSTREAM_REMOTE" master --squash -m "Merge upstream kickstart-modular updates"

    echo "==> Done! Review changes, then run: ./git-sync.sh push"
    ;;

  *)
    echo "Usage: $0 {push|pull|pull-upstream}"
    echo ""
    echo "  push          - Push dotfiles and nvim subtree to remotes"
    echo "  pull          - Pull dotfiles and nvim subtree from remotes"
    echo "  pull-upstream - Pull updates from upstream kickstart-modular.nvim"
    exit 1
    ;;
esac
