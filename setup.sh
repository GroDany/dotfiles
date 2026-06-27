#!/usr/bin/env bash

# Exit on error
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define targets
NVIM_SRC="$SCRIPT_DIR/.config/nvim"
ALACRITTY_SRC="$SCRIPT_DIR/.config/alacritty"
GITIGNORE_SRC="$SCRIPT_DIR/.gitignore_global"
TMUX_SRC="$SCRIPT_DIR/.config/tmux"

NVIM_DEST="$HOME/.config/nvim"
ALACRITTY_DEST="$HOME/.config/alacritty"
GITIGNORE_DEST="$HOME/.gitignore_global"
TMUX_DEST="$HOME/.config/tmux"
TMUX_CONF_DEST="$HOME/.tmux.conf"

# Mode: default is linux, can be wsl
MODE="linux"
if [ "$1" = "wsl" ]; then
    MODE="wsl"
fi

echo "Deploying dotfiles in '$MODE' mode..."

# Helper function to safely symlink a directory/file
deploy_symlink() {
    local src="$1"
    local dest="$2"

    # Ensure the parent directory exists
    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            echo "Removing existing symlink at $dest"
            rm "$dest"
        else
            local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
            echo "Warning: $dest already exists and is a regular file/directory."
            echo "Backing it up to $backup"
            mv "$dest" "$backup"
        fi
    fi

    echo "Symlinking $dest -> $src"
    ln -s "$src" "$dest"
}

# Helper function to safely deploy Alacritty config to Windows
deploy_windows_alacritty() {
    local src="$1"
    local wsl_appdata=""

    echo "Locating Windows AppData directory..."

    # Method 1: Try wslvar (if wslu is installed)
    if command -v wslvar >/dev/null 2>&1; then
        local win_appdata
        win_appdata=$(wslvar APPDATA 2>/dev/null)
        if [ -n "$win_appdata" ]; then
            wsl_appdata=$(wslpath "$win_appdata" 2>/dev/null)
        fi
    fi

    # Method 2: Try checking direct environment variable (if WSLENV contains APPDATA)
    if [ -z "$wsl_appdata" ] && [ -n "$APPDATA" ]; then
        wsl_appdata=$(wslpath "$APPDATA" 2>/dev/null)
    fi

    # Method 3: Scan /mnt/c/Users directory (fast and doesn't call Windows binaries)
    if [ -z "$wsl_appdata" ] && [ -d "/mnt/c/Users" ]; then
        for user_dir in /mnt/c/Users/*; do
            if [ -d "$user_dir/AppData/Roaming" ]; then
                local base
                base=$(basename "$user_dir")
                # Match user directory prefix (handles username variations e.g., 'daniel' vs 'danie')
                if [[ "$base" == "${USER}"* ]] || [[ "${USER}" == "$base"* ]]; then
                    wsl_appdata="$user_dir/AppData/Roaming"
                    break
                fi
            fi
        done
        # Fallback to the first AppData/Roaming directory found under Users if no username match
        if [ -z "$wsl_appdata" ]; then
            for user_dir in /mnt/c/Users/*; do
                if [ -d "$user_dir/AppData/Roaming" ]; then
                    wsl_appdata="$user_dir/AppData/Roaming"
                    break
                fi
            done
        fi
    fi

    # Method 4: As a last resort, try calling cmd.exe to echo %APPDATA%
    if [ -z "$wsl_appdata" ] && command -v cmd.exe >/dev/null 2>&1; then
        # We run it with a timeout to avoid hangs in non-interactive environments
        local win_appdata
        win_appdata=$(timeout 3 cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
        if [ -n "$win_appdata" ] && [ "$win_appdata" != "%APPDATA%" ]; then
            wsl_appdata=$(wslpath "$win_appdata" 2>/dev/null)
        fi
    fi

    if [ -z "$wsl_appdata" ]; then
        echo "Error: Could not automatically locate Windows AppData directory." >&2
        echo "Please make sure your Windows C: drive is mounted under /mnt/c." >&2
        return 1
    fi

    echo "Found Windows AppData at: $wsl_appdata"

    local dest_dir="$wsl_appdata/alacritty"
    local dest_file="$dest_dir/alacritty.toml"

    mkdir -p "$dest_dir"

    # Backup if the destination file already exists
    if [ -f "$dest_file" ]; then
        local backup="${dest_file}.bak.$(date +%Y%m%d%H%M%S)"
        echo "Warning: $dest_file already exists."
        echo "Backing it up to $backup"
        mv "$dest_file" "$backup"
    fi

    echo "Copying Alacritty config to Windows: $dest_file"
    cp "$src/alacritty.toml" "$dest_file"
    
    # Append WSL shell configuration for Windows Alacritty
    echo "" >> "$dest_file"
    echo "[terminal.shell]" >> "$dest_file"
    echo 'program = "wsl"' >> "$dest_file"
    echo 'args = ["-d", "Ubuntu-24.04", "--cd", "~"]' >> "$dest_file"
}

# 1. Deploy Neovim config (always symlinked to Linux home directory)
echo "Deploying Neovim configuration..."
deploy_symlink "$NVIM_SRC" "$NVIM_DEST"

# 2. Deploy Alacritty config (Linux or Windows side depending on parameter)
echo "Deploying Alacritty configuration..."
if [ "$MODE" = "wsl" ]; then
    deploy_windows_alacritty "$ALACRITTY_SRC"
else
    deploy_symlink "$ALACRITTY_SRC" "$ALACRITTY_DEST"
fi

# 3. Deploy Global Gitignore
echo "Deploying global gitignore..."
deploy_symlink "$GITIGNORE_SRC" "$GITIGNORE_DEST"

echo "Configuring git to use global gitignore..."
git config --global core.excludesfile "$GITIGNORE_DEST"

# 4. Deploy Tmux configuration
echo "Deploying Tmux configuration..."
deploy_symlink "$TMUX_SRC" "$TMUX_DEST"
deploy_symlink "$TMUX_DEST/tmux.conf" "$TMUX_CONF_DEST"

echo "Done! Dotfiles successfully deployed."
