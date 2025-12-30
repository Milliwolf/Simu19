#!/usr/bin/env bash
set -euo pipefail

# Miniconda installer script (macOS)
# Usage: bash scripts/install_miniconda.sh
# Review the script before running it.

echo "== Miniconda Installer (macOS) =="

# Check if conda already exists
if command -v conda >/dev/null 2>&1; then
  echo "Conda ist bereits installiert: $(command -v conda)"
  conda --version || true
  exit 0
fi

# Detect OS
OS_NAME=$(uname -s)
if [ "$OS_NAME" != "Darwin" ]; then
  echo "Dieses Skript ist nur für macOS (Darwin). Ersetze es durch den passenden Installer für dein System." >&2
  exit 2
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  "arm64")
    INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
    ;;
  "x86_64"|"i386")
    INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
    ;;
  *)
    echo "Unbekannte Architektur: $ARCH" >&2
    exit 3
    ;;
esac

TMP_FILE="/tmp/miniconda_installer.sh"

echo "Herunterladen: $INSTALLER_URL"
curl -fL "$INSTALLER_URL" -o "$TMP_FILE"
chmod +x "$TMP_FILE"

echo "Installation (Batch-Modus): bash $TMP_FILE -b -p \"$HOME/miniconda3\""
bash "$TMP_FILE" -b -p "$HOME/miniconda3"

# Ensure conda is in PATH for the remainder of the script
export PATH="$HOME/miniconda3/bin:$PATH"

if command -v conda >/dev/null 2>&1; then
  echo "Miniconda installiert. Version: $(conda --version)"
else
  echo "Fehler: conda wurde nach der Installation nicht gefunden." >&2
  exit 4
fi

# Initialize the detected shell (zsh is default on modern macOS)
SHELL_NAME=$(basename "$SHELL" || true)
if [ "$SHELL_NAME" = "zsh" ] || [ "$SHELL_NAME" = "bash" ]; then
  echo "Führe: conda init $SHELL_NAME"
  conda init "$SHELL_NAME" || true
  echo "Führe 'source ~/.${SHELL_NAME}rc' oder öffne ein neues Terminal, damit die Änderung wirksam wird."
else
  echo "Shell ('$SHELL_NAME') nicht automatisch initialisiert. Bitte führe 'conda init <deine-shell>' manuell aus, falls gewünscht." 
fi

cat <<'EOF'

Fertig! Nächste Schritte:
 - Öffne ein neues Terminal oder führe z.B. `source ~/.zshrc` aus
 - Prüfe mit `conda --version`
 - Optional: `conda install mamba -n base -c conda-forge` um mamba zu nutzen

Hinweis: Überprüfe das Skript bevor du es ausführst. Wenn du Fragen hast, sag Bescheid.
EOF
