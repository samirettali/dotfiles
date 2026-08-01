---
name: project-workflow
description: Work on tasks tracked as GitHub issues in Samir's personal repos — pick up an issue, open a new one, close it with a PR. Use when asked to work on an issue or a task, to open an issue for something found along the way, or to check what is pending on a project.
---

# Project workflow

Le task dei progetti personali sono **issue GitHub**, raccolte nel Project `dev`
(<https://github.com/users/samirettali/projects/1>). I repo stanno sotto
`samirettali/`, i checkout locali in `~/dev/<nome-repo>`.

`Priority` (P0–P3) e `Status` sono **campi del Project**, non label.

**Non decidere `Priority` di tua iniziativa**: la triage la fa Samir. Se te la
indica lui, impostala pure.

## Stati

`📋 Backlog` → `🏗 In progress` → `👀 In review` → `✅ Done`

Backlog e Done sono automatici (workflow del Project: *item added* e *pull
request merged* / *item closed*). Le due transizioni di mezzo le fai tu:

```sh
ITEM=$(gh project item-list 1 --owner samirettali --format json \
  | jq -r '.items[] | select(.content.number == <N>
      and (.content.repository | test("/<repo>$"))) | .id')

gh project item-edit --project-id PVT_kwHOALClx84AFfr4 --id "$ITEM" \
  --field-id PVTSSF_lAHOALClx84AFfr4zgDKqo8 \
  --single-select-option-id <OPZIONE>
```

`<OPZIONE>`: `In progress` = `4ddd38ae`, `In review` = `f78a3bae`.

Gli ID qui sopra sono fissi perché `item-edit` non accetta i nomi. Se un giorno
smettono di funzionare — Project o campo ricreati — ripescali con:

```sh
gh project field-list 1 --owner samirettali --format json
```

## Prendere in carico una issue

1. Leggi la issue **con i commenti** — il contesto vero spesso sta lì, non nel corpo:

   ```sh
   gh issue view <N> --repo samirettali/<repo> --comments
   ```

2. Leggi il contesto del progetto: `AGENTS.md`, l'indice di `docs/`, e
   `JOURNAL.md` se esiste.
3. Crea un branch dedicato: `git switch -c issue-<N>-<slug>`.
4. Porta la issue su `🏗 In progress` (vedi [Stati](#stati)).
5. Se qualcosa nella issue non torna o è ambiguo, **chiedi prima di scrivere
   codice**. Una issue scritta mesi fa può descrivere un problema che nel
   frattempo è cambiato.

## Aprire una issue

1. Cerca prima i doppioni:

   ```sh
   gh issue list --repo samirettali/<repo> --search "<parole chiave>" --state all
   ```

2. Scrivi una descrizione **autosufficiente**. Il lettore è qualcuno — o un
   agente — che la prende a freddo mesi dopo, senza memoria di come è saltata
   fuori:

   - cosa non va
   - **dove**: file e funzione, con lo snippet quando aiuta a capire
   - perché conta, in concreto
   - come si ripara — e se non lo sai, scrivi che è da indagare invece di
     inventare una causa plausibile
   - cosa verificare dopo
   - quali doc vanno aggiornati quando atterra

3. Crea passando **sempre** il Project, senza contare sull'auto-add (il piano
   Free ne consente uno solo, su un repo solo):

   ```sh
   gh issue create --repo samirettali/<repo> --project "dev" \
     --title "<titolo>" --body "<corpo>"
   ```

4. La nuova issue entra in `📋 Backlog` da sola. Non impostare `Priority`.

## Chiudere

1. Se il comportamento è cambiato, aggiorna i doc **nella stessa PR**. Un doc
   rimandato alla PR successiva è un doc che resta indietro.
2. Apri la PR con il riferimento che chiude la issue:

   ```sh
   gh pr create --title "<titolo>" --body "Closes #<N>

   <cosa cambia e come è stato verificato>"
   ```

3. Porta la issue su `👀 In review` (vedi [Stati](#stati)).
4. Non chiudere la issue a mano, e non metterla su `✅ Done`: ci pensa il merge.

## Documentazione

- `AGENTS.md` resta **sottile**: cos'è il progetto, comandi, convenzioni, e un
  indice di una riga per ogni pagina di `docs/`.
- Il resto sta in `docs/`, versionato insieme al codice. Niente wiki: vive in un
  repo separato, non passa dalla review, e i riferimenti al codice si rompono in
  silenzio.

## Note

- I TODO nel codice restano nel codice. Se ne trasformi uno in issue, cita file e
  riga nella issue e **non rimuovere il commento** senza che sia stato chiesto.
- I worktree per ora si gestiscono a mano: non sono parte di questo flusso.
