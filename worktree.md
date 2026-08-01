# Worktree per agenti

Ricerca del 1 agosto 2026. Per ora i worktree si gestiscono **a mano**: niente
tooling, niente skill. Queste sono le opzioni valutate, da riprendere quando il
flusso manuale mostra un attrito concreto.

## Il flusso da supportare

Si resta su `main` nel checkout principale (visibilità del branch), si pianifica
o si prende una task, e **lo stesso agente** si sposta in un worktree e continua
a lavorarci. Niente subagent.

Il primitivo necessario è quindi lo spostamento **a metà sessione**, non
`cwd = worktree` all'avvio.

## Il problema vero: il bootstrap

`git worktree` porta solo i file tracciati. Quello che manca:

| repo | non arriva nel worktree |
| --- | --- |
| sottocasa | `.env`, `.env.*`, `.data/`, `node_modules/` |
| marks | `node_modules`, `data` |
| dotfiles | direnv riparte bloccato, shell nix da rivalutare |
| spotctl, pulse | niente |

Un worktree senza bootstrap è una dir dove non gira niente. Meglio dichiararlo
in un file di config che descriverlo a parole in `AGENTS.md`: un agente può
dimenticare un'istruzione, un config viene eseguito.

## Claude Code — supporto nativo

- `EnterWorktree` crea in `.claude/worktrees/` su un branch nuovo e sposta la cwd
  della sessione. Con `path` entra in un worktree **già esistente** purché sia in
  `git worktree list` (prima entrata dalla launch dir: qualsiasi path registrato).
- `ExitWorktree` con `keep` / `remove`, rifiuta di rimuovere con modifiche non
  committate.
- Setting `worktree.baseRef`: `fresh` (default, branch da `origin/<default>`) o
  `head` (dal HEAD locale). Con `fresh` i commit locali non pushati su main non
  finiscono nel worktree.
- Isolamento subagent via `isolation: "worktree"`.
- **Non fa bootstrap** e gli hook `WorktreeCreate`/`WorktreeRemove` sembrano
  riservati al caso "fuori da un repo git" — da verificare.

## wtp (satococoa/wtp)

CLI Go per worktree con `.wtp.yml` per repo: `post_create` con step `type: copy`
(ammette file gitignored come `.env`) e `type: command` (`pnpm install`). Più
`wtp remove --with-branch` atomico.

- **Non è in nixpkgs** (c'è solo `wt`, il toolkit web C++) → andrebbe nel NUR.
- Path di default `../worktrees/<branch>`, **condiviso tra tutti i repo**: due
  branch omonimi in repo diversi collidono. Va configurato col nome del repo.

Combinazione naturale su Claude Code: `wtp add` crea e bootstrappa, poi
`EnterWorktree` con `path` ci sposta la sessione. È l'unico modo di avere sia il
bootstrap sia lo spostamento in sessione.

## pi — estensioni esistenti

pi non ha worktree né subagent nativi (il README rimanda esplicitamente alle
estensioni). L'API `ExtensionAPI` non espone la mutazione del cwd, ma **una
sessione porta con sé il suo cwd** — da lì il trucco usato sotto.

| Estensione | Come si sposta | Bootstrap |
| --- | --- | --- |
| `@narumitw/pi-worktree` | Prepara una sessione con cwd = worktree e la sostituisce via session replacement API, **preservando la conversazione** (se già persistita) | no |
| `pi-worktree` | **Rilancia pi** nel worktree se rileva tmux/cmux, altrimenti stampa il path | sì — `.pi/worktree.json` con hook per db, `.env.local`, deps, migration |
| `worktree-sessions` | — (symlinka `.pi/sessions` dei worktree a quello del main, sessioni condivise nei due sensi) | no |
| `@season179/pi-worktree` | Il cwd non si sposta: **virtualizza i tool** (bash dal worktree, read/write/edit riscritti, scritture esterne bloccate). Solo `pi --worktree` all'avvio | no |
| `@thisux/pi-worktree` | Non entra, mostra il path. Ha `/worktree pr <n>` via `gh` | no |

Combinazione che rispecchia il lato Claude Code: `@narumitw/pi-worktree` + `wtp`
— wtp crea e bootstrappa, l'estensione entra preservando la conversazione.
Alternativa monolitica: `pi-worktree` + `worktree-sessions`, ma sono due sistemi
di bootstrap diversi tra i due harness.

Avvertenze:
- I path di default divergono (narumitw: `~/.worktrees/<main>/<branch>`, wtp:
  `../worktrees/<branch>`) — vanno allineati.
- pi chiede il trust per ogni cartella nuova ma **lo eredita dalle cartelle
  padre**: un root comune approvato una volta copre tutti i worktree futuri.
- I pi package girano con **pieno accesso al sistema**. Leggere il sorgente prima
  di installarli: non è un ecosistema con review.

## Path

Fuori dal repo, così `rg`/`fd` e gli editor non ci finiscono dentro e non ci sono
repo annidati. Un root comune per sfruttare l'ereditarietà del trust di pi.

## Da ricordare

Un worktree dimenticato **tiene il branch in checkout**, e poi non si capisce
perché non si riesce a fare checkout di quel branch altrove. `git worktree prune`
non è cosmetico.

Su dotfiles vale la regola solita: i file nuovi sono invisibili al flake finché
non sono staged (`git add -N`). In un worktree ci si sbatte contro subito.
