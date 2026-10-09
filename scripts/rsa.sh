#!/bin/bash

# Nadaj skryptowi uprawnienia do wykonywania:
# chmod +x generate_rsa_f104.sh
# Uruchom skrypt:
# ./generate_rsa_f104.sh

set -e=== KONFIGURACJA REPOZYTORIUM I AUTORYZACJI ===Wklej swój GitHub Personal Access Token (z uprawnieniami repo/contents:write)GITHUB_TOKEN="TWÓJ_PERSONAL_ACCESS_TOKEN"REPO_OWNER="KIA-students"
REPO_NAME="ndp"
TARGET_SUBDIR="f104"===============================================if [ "$GITHUB_TOKEN" = "TWÓJ_PERSONAL_ACCESS_TOKEN" ] \vert{}\vert{} [ -z "$GITHUB_TOKEN" ]; then
echo "[!] BŁĄD: Musisz wpisać swój Personal Access Token w zmiennej GITHUB_TOKEN na początku skryptu."
echo "    Token wygenerujesz na GitHubie: Settings -> Developer Settings -> Personal Access Tokens (Fine-grained lub Classic)."
exit 1
fiREPO_URL="https://${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"HOSTNAME=$(hostname)
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
ZIP_NAME="klucze_rsa_${HOSTNAME}_${TIMESTAMP}.zip"DESKTOP_DIR="$HOME/Desktop"
if command -v xdg-user-dir &> /dev/null; then
DESKTOP_DIR="$(xdg-user-dir DESKTOP)"
fiZIP_PATH="$DESKTOP_DIR/$ZIP_NAME"
TEMP_DIR="/tmp/rsa_keys_temp_$$" REPO_DIR="/tmp/repo_temp_$$"Automatyczne czyszczenie repozytorium i plików roboczych po zakończeniu skryptu (lub w przypadku błędu)cleanup() {
echo "[+] Sprzątanie: usuwanie tymczasowego repozytorium i plików wygenerowanych..."
rm -rf "$TEMP_DIR" "$REPO_DIR"
}
trap cleanup EXITecho "[+] Rozpoczynanie procesu dla stanowiska: $HOSTNAME"1. Sprawdzenie i ewentualna instalacja Git oraz zipif ! command -v git &> /dev/null || ! command -v zip &> /dev/null; then
echo "[!] Instalacja wymaganych pakietów systemowych (git, zip)..."
sudo apt update && sudo apt install -y git zip
else
echo "[+] Wymagane narzędzia podstawowe (git, zip) są zainstalowane."
fi2. Generowanie pary kluczy RSA (4096-bit)mkdir -p "$TEMP_DIR"
echo "[+] Generowanie pary kluczy RSA 4096-bit..."
ssh-keygen -t rsa -b 4096 -f "$TEMP_DIR/id_rsa" -N "" -qScalenie kluczy do czytelnego pliku tekstowego{
echo "=================== KLUCZ PRYWATNY ="
cat "$TEMP_DIR/id_rsa"
echo -e "\n= KLUCZ PUBLICZNY ==================="
cat "$TEMP_DIR/id_rsa.pub"
} > "$TEMP_DIR/klucze_rsa.txt"3. Zbieranie szczegółowych informacji o stanowisku i oprogramowaniuINFO_FILE="$TEMP_DIR/info_o_komputerze.txt"check_cmd() {
local cmd="$1"
local name="$2"
if command -v "$cmd" &> /dev/null; then
local ver
ver=$("$cmd" --version 2>&1 | head -n 1 || echo "Zainstalowano")
echo "[ZAINSTALOWANO] $name ->$ver"
else
echo "[BRAK]          $name"
fi
}check_path_or_cmd() {
local cmd="$1"
local name="$2"
shift 2
local found=0
if command -v "$cmd" &> /dev/null; then
echo "[ZAINSTALOWANO] $name ($(command -v "$cmd"))"
found=1
else
for path in "$@"; do
if [ -e "$path" ]; then
echo "[ZAINSTALOWANO] $name ($path)"
found=1
break
fi
done
fi
if [ $found -eq 0 ]; then
echo "[BRAK]          $name"
fi
}echo "[+] Generowanie raportu ze specyfikacją komputera..."{
echo ""
echo "RAPORT STANOWISKA PRACY"
echo "Data wygenerowania: $(date +'%Y-%m-%d %H:%M:%S')"
echo ""
echo "Użytkownik:        $(whoami)"
echo "Nazwa komputera:   $(hostname)"
echo "System operacyjny: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"' || uname -sr)"
echo "Jądro systemowe:   $(uname -r)"
echo "Architektura:      $(uname -m)"
echo "Procesor:          $(lscpu 2>/dev/null | grep 'Model name:' | sed 's/Model name:\s*//' || echo 'Nieznany')"
echo "Pamięć RAM:        $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 'Nieznana')"
if command -v lspci &> /dev/null; then
echo "Karta graficzna:   $(lspci | grep -i 'vga|3d|2d' | cut -d: -f3 | sed 's/^[ \t]*//')"
fi
echo ""
echo ""
echo "KONTROLA OPROGRAMOWANIA I ŚRODOWISK"
echo ""
echo "--- Kontrola wersji ---"
check_cmd "git" "Git"
check_cmd "git-bash" "Git Bash"
check_cmd "gh" "GitHub CLI"
check_path_or_cmd "github-desktop" "GitHub Desktop" "/opt/GitHub Desktop/github-desktop" "$HOME/.local/share/applications/github-desktop.desktop"echo ""
echo "--- Środowiska programistyczne (IDE) ---"
check_cmd "code" "Visual Studio Code"
check_path_or_cmd "xcodebuild" "Xcode" "/Applications/Xcode.app"
check_path_or_cmd "studio" "Android Studio" "/opt/android-studio/bin/studio.sh" "$HOME/android-studio/bin/studio.sh" "/snap/bin/android-studio"
check_path_or_cmd "clion" "CLion" "/snap/bin/clion"
check_path_or_cmd "idea" "IntelliJ IDEA" "/snap/bin/intellij-idea-community" "/snap/bin/intellij-idea-ultimate"echo ""
echo "--- Języki i Runtimes ---"
check_cmd "python3" "Python 3"
check_cmd "pip3" "Pip (Python)"
check_cmd "node" "Node.js"
check_cmd "npm" "npm"
check_cmd "java" "Java Runtime"
check_cmd "javac" "Java Compiler (JDK)"
check_cmd "dotnet" ".NET SDK"
check_cmd "rustc" "Rust"
check_cmd "go" "Go"echo ""
echo "--- Kompilatory i Narzędzia Budowania ---"
check_cmd "gcc" "GCC (C)"
check_cmd "g++" "G++ (C++)"
check_cmd "clang" "Clang"
check_cmd "cmake" "CMake"
check_cmd "make" "Make"
check_cmd "ninja" "Ninja"echo ""
echo "--- Silniki gier i Grafika 3D ---"
check_path_or_cmd "unityhub" "Unity / Unity Hub" "/opt/unityhub/unityhub" "$HOME/AppImages/Unity_Hub.AppImage"
check_path_or_cmd "godot" "Godot Engine" "/usr/bin/godot"
check_cmd "blender" "Blender"echo ""
echo "--- Konteneryzacja & Wirtualizacja ---"
check_cmd "docker" "Docker"
check_cmd "podman" "Podman"echo ""
echo "--- Akceleracja GPU i AI ---"
check_cmd "nvidia-smi" "Sterowniki NVIDIA GPU"
check_cmd "nvcc" "NVIDIA CUDA Toolkit"echo ""
echo "--- Narzędzia naukowe i Dokumentacja ---"
check_cmd "matlab" "MATLAB"
check_cmd "pdflatex" "TeX / LaTeX (pdflatex)"
check_cmd "xelatex" "TeX / LaTeX (xelatex)"
check_cmd "lualatex" "TeX / LaTeX (lualatex)"
} > "$INFO_FILE"4. Pakowanie plików do archiwum ZIP na Pulpicierm -f "$ZIP_PATH"
zip -j "$ZIP_PATH" "$TEMP_DIR/klucze_rsa.txt" "$TEMP_DIR/id_rsa" "$TEMP_DIR/id_rsa.pub" "$INFO_FILE"
echo "[+] Paczka wygenerowana na Pulpicie: $ZIP_PATH"5. Klonowanie repozytorium z przekazanym tokenem, dodanie pliku do f104/ i pushrm -rf "$REPO_DIR"
echo "[+] Klonowanie repozytorium..."
git clone --quiet "$REPO_URL" "$REPO_DIR"DEST_DIR_IN_REPO="$REPO_DIR/$TARGET_SUBDIR"
mkdir -p "$DEST_DIR_IN_REPO"cp "$ZIP_PATH" "$DEST_DIR_IN_REPO/"cd "$REPO_DIR"
git config user.name "Auto-Key-Uploader"
git config user.email "auto-uploader@localhost"git add "$TARGET_SUBDIR/$ZIP_NAME"
git commit -m "Dodano paczkę z kluczami RSA dla stanowiska $HOSTNAME do folderu$TARGET_SUBDIR"echo "[+] Wysyłanie zmian do GitHub (bezinteraktywne)..."
git push --quiet origin main || git push --quiet origin masterecho ""
echo "[+] SUKCES! Plik $ZIP_NAME został pomyślnie wysłany do katalogu $TARGET_SUBDIR/ w repozytorium."
echo ""
