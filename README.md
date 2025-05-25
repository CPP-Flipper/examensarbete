# Instruktioner för att köra egna tester

Följ dessa steg för att komma igång:

1. **Ladda hem projektet**
    - Klicka på "Code" och välj "Download ZIP".
    - Packa upp ZIP-filen på valfri plats på din dator.

2. **Installera Docker Desktop**
    - Ladda ner och installera Docker Desktop från [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/).
    - Starta Docker Desktop efter installationen.

3. **Navigera till rätt mapp**
    - Öppna en terminal (t.ex. Terminal på macOS eller Kommandotolken/PowerShell på Windows).
    - Navigera till antingen `inte_normaliserad` eller `normaliserad` mappen, beroende på vad du vill testa:
      ```
      cd ../inte_normaliserad
      ```
      eller
      ```
      cd ../normaliserad
      ```

4. **Starta containrarna**
    - Kör följande kommando för att bygga och starta containrarna i bakgrunden:
      ```
      docker compose up --build -d
      ```
    - När du är klar och vill stänga ner samt ta bort alla volymer, kör:
      ```
      docker compose down -v
      ```

5. **Använd pgAdmin**
    - När pgAdmin är igång, öppna webbläsaren och navigera till `http://localhost:5050`.
    - Logga in med de standarduppgifter som anges i `docker-compose.yml` filen:
      - **E-post:** PGADMIN_DEFAULT_EMAIL
      - **Lösenord:** PGADMIN_DEFAULT_PASSWORD

5. **Anslut till TimescaleDB**
    - Skapa en ny serveranslutning i pgAdmin, alla uppgifter finns i `docker-compose.yml` filen
    - Klicka på "Save" för att spara anslutningen.

6. **Kör tester**
    - Tools > Query Tool
    - Kör VACUUM ANALYZE på den databas du vill testa:
      ```sql
      VACUUM ANALYZE tabell_namn;
      ```
    - Kör sedan dina SQL-frågor eller tester i samma Query Tool.
