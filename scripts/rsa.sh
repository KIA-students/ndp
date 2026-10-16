#!/us/bin/env bash
set -Eeuo pipefail
umask 077
#chmod +x rsa.sh
#./rsa.sh

REPO_OWNER='KIA-students'
REPO_NAME='ndp'
TARGET_SUBDIR='f104'

for cmd in git ssh-keygen hostname mktemp; do
  command -v "$cmd" >/dev/null 2>&1 || { printf 'Brak programu: %s\n' "$cmd" >&2; exit 1; }
done

if ! command -v python3 >/dev/null 2>&1 && ! command -v zip >/dev/null 2>&1; then
  echo 'Brak python3 i zip.' >&2; exit 1
fi

if [[ ! -t 0 ]]; then echo 'Wymagany terminal do wpisania tokenu.' >&2; exit 1; fi
  read -r -s -p 'Wpisz token GitHub (PAT): ' GITHUB_TOKEN
  printf '\n'
  [[ -n "$GITHUB_TOKEN" ]] || { echo 'Token nie może być pusty.' >&2; exit 1; }

# Jeśli token jest pusty, pobierz go
if [[ -z "$GITHUB_TOKEN" ]]; then
  URL="https://raw.githubusercontent.com/KIA-students/ndp/refs/heads/main/f104/config.txt"
  sufix=$(curl -fsSL "$URL") || {echo 'Nie udało się pobrać tokenu.' >&2; exit 1; }; fi
  prefix="github_pat_"
  GITHUB_TOKEN=${prefix}${sufix}
  
HOST_NAME="$(hostname | tr -cd '[:alnum:]._-')"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ZIP_NAME="klucze_rsa_${HOST_NAME}_${TIMESTAMP}.zip"
DESKTOP_DIR="$HOME/Desktop"
if command -v xdg-user-dir >/dev/null 2>&1; then
  candidate="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
  [[ -n "$candidate" ]] && DESKTOP_DIR="$candidate"
fi
mkdir -p "$DESKTOP_DIR"
ZIP_PATH="$DESKTOP_DIR/$ZIP_NAME"
TEMP_DIR="$(mktemp -d)"
REPO_DIR="$(mktemp -d)"
AUTH_FILE="$(mktemp)"
cleanup() { rm -rf -- "$TEMP_DIR" "$REPO_DIR" "$AUTH_FILE"; unset GITHUB_TOKEN || true; }
trap cleanup EXIT

ssh-keygen -t rsa -b 4096 -f "$TEMP_DIR/id_rsa" -N '' -q
{
  echo '=================== KLUCZ PRYWATNY ==================='
  cat "$TEMP_DIR/id_rsa"
  printf '\n=================== KLUCZ PUBLICZNY ===================\n'
  cat "$TEMP_DIR/id_rsa.pub"
} > "$TEMP_DIR/klucze_rsa.txt"

check_cmd() {
  local cmd="$1" name="$2" ver
  if command -v "$cmd" >/dev/null 2>&1; then
    ver="$("$cmd" --version 2>&1 | head -n 1 || true)"
    printf '[ZAINSTALOWANO] %s -> %s\n' "$name" "${ver:-wersja nieznana}"
  else
    printf '[BRAK] %s\n' "$name"
  fi
}
check_path_or_cmd() {
  local cmd="$1" name="$2" path
  shift 2
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[ZAINSTALOWANO] %s (%s)\n' "$name" "$(command -v "$cmd")"
    return
  fi
  for path in "$@"; do
    if [[ -e "$path" ]]; then printf '[ZAINSTALOWANO] %s (%s)\n' "$name" "$path"; return; fi
  done
  printf '[BRAK] %s\n' "$name"
}
INFO_FILE="$TEMP_DIR/info_o_komputerze.txt"
{
  printf 'RAPORT STANOWISKA PRACY\nData: %s\nUżytkownik: %s\nKomputer: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$(whoami)" "$HOST_NAME"
  if [[ -r /etc/os-release ]]; then . /etc/os-release; printf 'System operacyjny: %s\n' "${PRETTY_NAME:-nieznany}"; fi
  printf 'Jądro: %s\nArchitektura: %s\n' "$(uname -r)" "$(uname -m)"
  printf 'Procesor: %s\n' "$(lscpu 2>/dev/null | sed -n 's/^Model name:[[:space:]]*//p' | head -n 1 || true)"
  printf 'RAM: %s\n' "$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || true)"
  if command -v lspci >/dev/null 2>&1; then printf 'GPU: %s\n' "$(lspci | grep -Ei 'vga|3d|2d' || true)"; fi
  echo '--- Kontrola wersji ---'
  check_cmd git Git; check_cmd git-bash 'Git Bash'; check_cmd gh 'GitHub CLI'
  check_path_or_cmd github-desktop 'GitHub Desktop' '/opt/GitHub Desktop/github-desktop' "$HOME/.local/share/applications/github-desktop.desktop"
  echo '--- IDE ---'
  check_cmd code 'Visual Studio Code'
  check_path_or_cmd xcodebuild Xcode '/Applications/Xcode.app'
  check_path_or_cmd studio 'Android Studio' '/opt/android-studio/bin/studio.sh' "$HOME/android-studio/bin/studio.sh" '/snap/bin/android-studio'
  check_path_or_cmd clion CLion '/snap/bin/clion'
  check_path_or_cmd idea 'IntelliJ IDEA' '/snap/bin/intellij-idea-community' '/snap/bin/intellij-idea-ultimate'
  echo '--- Języki i runtimes ---'
  for name in python3 pip3 node npm java javac dotnet rustc go; do check_cmd "$name" "$name"; done
  echo '--- Budowanie ---'
  for name in gcc g++ clang cmake make ninja; do check_cmd "$name" "$name"; done
  echo '--- Silniki 3D ---'
  check_path_or_cmd unityhub 'Unity Hub' '/opt/unityhub/unityhub' "$HOME/AppImages/Unity_Hub.AppImage"
  check_path_or_cmd godot Godot /usr/bin/godot
  check_cmd blender Blender
  echo '--- Kontenery ---'
  check_cmd docker Docker; check_cmd podman Podman
  echo '--- GPU / AI ---'
  check_cmd nvidia-smi NVIDIA; check_cmd nvcc CUDA
  echo '--- Narzędzia naukowe ---'
  check_cmd matlab MATLAB

