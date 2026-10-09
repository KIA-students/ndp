# Instrukcja przygotowania środowiska i rejestracji stanowiska (Lab F104)

Sekcja przeznaczona dla studentów realizujących zajęcia laboratoryjne. Pozwala na automatyczne zweryfikowanie zainstalowanego oprogramowania oraz zarejestrowanie klucza RSA stanowiska pracy w repozytorium.

## Szybkie uruchomienie

Otwórz terminal w systemie Linux i wklej poniższe polecenie:

```
bash <(curl -fsSL https://raw.githubusercontent.com/KIA-students/ndp/main/scripts/rsa.sh)

```

> **Wskazówka:** Jeżeli w systemie brakuje pakietów `git` lub `zip`, skrypt wyświetli prompt o podanie hasła administratora (`sudo`), aby je automatycznie doinstalować.

## Zakres działania skryptu

Uruchomiony skrypt wykonuje w tle następujące kroki:

1. **Weryfikacja zależności:** Sprawdza obecność narzędzi `git` oraz `zip`.

2. **Generowanie kluczy:** Tworzy nową, bezpieczną parę kluczy RSA (4096-bit).

3. **Audyt środowiska:** Zbiera szczegółowe informacje o sprzęcie (CPU, RAM, GPU) oraz weryfikuje wersje zainstalowanego oprogramowania programistycznego (VS Code, Python, Docker, CUDA, LaTeX itp.).

4. **Archiwizacja:** Pakuje raport oraz klucze do pliku `.zip` z identyfikatorem komputera i znacznikiem czasu na Pulpicie.

5. **Wysyłka danych:** Przesyła spakowaną paczkę do katalogu `f104/` w repozytorium.

6. **Automatyczne czyszczenie:** Usuwa z lokalnego dysku tymczasowo sklonowane repozytorium i pliki robocze (`trap EXIT`).

## Rozwiązywanie problemów

* **Błąd pobierania `curl`:** Upewnij się, że komputer posiada dostęp do Internetu oraz że skrypt `generate_rsa_f104.sh` został wypchnięty do gałęzi `main` w katalogu `scripts/`.

* **Wymagane hasło sudo:** Podaj lokalne hasło użytkownika systemu Linux, aby skrypt mógł zainstalować brakujące narzędzia.
