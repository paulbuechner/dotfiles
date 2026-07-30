---
name: yadm-dotfiles
description: Manage the paulbuechner/dotfiles repo through yadm — set up a new machine, add a config file to tracking, update or inspect an already-tracked file, and work out whether something belongs in the repo at all. Use this whenever the user mentions yadm, dotfiles, or "tracking" a config file, and also whenever they ask to change a config that yadm might already own (shell rc files, Claude Code settings, oh-my-posh theme, PowerShell profiles, Warp, Windows Terminal, Ghostty) — editing such a file in place is usually the wrong move and this skill explains why. Also use it when a tracked config mysteriously reverts, when yadm status shows drift the user did not cause, or when deciding where a new alternate file should live.
---

# yadm dotfiles

The dotfiles repo is a git repo whose work-tree is `$HOME`. Files stay where the
apps expect them; git tracks them in place.

- Repo: `~/.local/share/yadm/repo.git`, remote `github.com/paulbuechner/dotfiles`, branch `main`
- Work-tree: `$HOME`
- yadm config dir: `~/.config/yadm`
- On Windows, yadm itself runs from a source clone at `~/.yadm-project`, with a
  shim at `~/bin/yadm` so a bare `yadm` works in Git Bash.

Run `yadm` from Git Bash or a POSIX shell. It is a bash script and does nothing
useful from PowerShell or `cmd`.

## Orient before acting

Two commands answer most "what is going on here" questions:

```bash
yadm list -a        # everything tracked, including ##-suffixed sources
yadm status         # only tracked files; untracked are hidden by config
```

`status.showUntrackedFiles=no` is set deliberately, so `yadm status` never
drowns in the noise of `$HOME`. The flip side is that adding a new file always
needs an explicit `yadm add <path>` — nothing gets picked up implicitly.

## The one rule that prevents most damage

**If a file has a `##`-suffixed source, edit the source, never the file itself.**

Alternates work by generating a target from a suffixed source. On Windows
`yadm.alt-copy` is on, so the target is a plain copy. `yadm alt` overwrites that
copy without warning, and the generated targets are added to
`repo.git/info/exclude`, so `yadm status` will not warn you either. Editing the
target is silent work that disappears at the next `yadm alt`.

To find out whether a file is generated, look for a source:

```bash
yadm list -a | grep -i <filename>
```

If a `##`-suffixed entry comes back, edit that. Then regenerate and verify:

```bash
yadm alt
diff <source> <target>
```

## Adding a file to tracking

Work through these in order — each question rules out a wrong answer that is
annoying to undo later.

**1. Does it contain secrets?** Scan before tracking, not after; git history is
forever:

```bash
grep -ciE "token|apikey|secret|password|<password>|credential" <file>
```

Known offenders that must stay untracked: `.m2/settings.xml` (Artifactory
credentials), `.git-credentials`, `.gnupg/`, `.1password`, `.dbus-keyrings`.
`.gitconfig` is also deliberately untracked — it holds an email and
`credential.helper` that should be decided per machine. If the user wants
secrets to travel, that is `~/.config/yadm/encrypt` plus `yadm encrypt`, not
plain tracking.

**2. Is it config, or is it state?** Track config. Leave anything the app
rewrites constantly — session state, window positions, caches, installed
packages. Vendoring dependencies (a `Modules/` tree, a `node_modules`) puts
binaries in history permanently and they go stale; install them from the
bootstrap instead.

**3. Does it apply on every OS?** If yes, track it plain:

```bash
yadm add ~/.condarc
```

Prefer plain even for files that are inert elsewhere. A `.zshrc` on a machine
without zsh costs nothing and works the moment zsh appears; a conditional one
breaks on the OS you forgot to include. Guard optional tools inside the file
(`command -v jenv >/dev/null && eval "$(jenv init -)"`) rather than splitting it
per platform.

**4. If it is OS-specific, where does the source go?** Both forms generate the
same target; the difference is where the clutter lands.

Alternate sources are checked out on *every* machine — only the target is
conditional. So a side-by-side source appears on the Mac too.

- **Target is a dotfile in `$HOME`** → side-by-side. It is hidden among the
  other dotfiles and stays discoverable next to what it generates.
  ```
  ~/.bashrc##os.Msys  ->  ~/.bashrc
  ```
- **Target is under a browsable or system directory** (`Documents/`,
  `AppData/`) → `~/.config/yadm/alt/`, which mirrors the path relative to
  `$HOME`. A stray `Microsoft.PowerShell_profile.ps1##os.Msys` in `~/Documents`
  on the Mac is just litter.
  ```
  ~/.config/yadm/alt/Documents/PowerShell/profile.ps1##os.Msys
      ->  ~/Documents/PowerShell/profile.ps1
  ```

Then materialise and confirm the target actually appeared:

```bash
yadm add '<source path with ##>'
yadm alt
```

`yadm alt` prints one `Copying ... to ...` line per generated file. No line
means no condition matched — usually a wrong `os` value, see below.

## Condition values

The value that trips people up is the OS one, because it is not what `uname -s`
prints:

| Platform | `os` condition |
| --- | --- |
| macOS | `Darwin` |
| Linux | `Linux` |
| WSL | `WSL` — yadm overrides `uname -s` by checking `/proc/version` |
| Git Bash | `Msys` — yadm rewrites `MINGW64_NT-…` via `uname -o` |
| Cygwin | `Cygwin` |

`##os.Windows` silently never matches. Other attributes: `hostname`, `user`,
`arch`, `class`, `distro`, `distro_family`. Prefix with `~` to negate. Values
compare case-insensitively. To see what a machine reports:

```bash
uname -s; uname -n; id -u -n; uname -m; yadm config --get local.class
```

The two config namespaces live in different files, which is confusing when
hunting for a setting: `local.*` (class, os, hostname) is in
`~/.local/share/yadm/repo.git/config`; `yadm.*` (alt-copy, auto-alt) is in
`~/.config/yadm/config`. Neither travels with the repo.

## Config files a GUI app owns

Warp, Windows Terminal and similar apps rewrite their own config on their own
schedule, usually on exit. Two habits keep this from wasting an afternoon.

**Check the app is closed before editing.** It flushes in-memory settings on
quit and will silently overwrite whatever you wrote underneath it:

```bash
tasklist //FI "IMAGENAME eq WindowsTerminal.exe" | grep -qi terminal && echo RUNNING
```

**Track what the app actually writes, not what you wish it wrote.** Windows
Terminal re-adds `actions: []`, `keybindings: []`, `newTabMenu`, `schemes: []`
and `themes: []` on every exit no matter how cleanly they are stripped. Fighting
that means `yadm status` is dirty after every session, which trains the user to
ignore it. Concede formatting and empty containers; the content you actually
care about — profile lists, `disabledProfileSources`, font blocks — does
survive.

Related patterns worth recognising:

- **App-native cloud sync races yadm.** Turn the app's sync off so yadm is the
  single owner, or do not track the file. Warp's is
  `[account] is_settings_sync_enabled`.
- **Deleting a dynamically generated entry does not remove it.** Windows
  Terminal profiles carrying a `source` field are regenerated whenever the
  generator finds the app. Suppress with `disabledProfileSources`, or keep the
  entry with `"hidden": true`. Deleting only works when the underlying app is
  genuinely gone.

## Setting up a new machine

```bash
# Windows only: no package exists, so run yadm from source
git clone https://github.com/yadm-dev/yadm.git ~/.yadm-project
~/.yadm-project/yadm clone https://github.com/paulbuechner/dotfiles.git

# macOS / Linux
yadm clone https://github.com/paulbuechner/dotfiles.git
```

Files that already exist in `$HOME` are left untouched — yadm will not overwrite
them. They then show up as local modifications the user never made. Resolve with
`yadm status` and `yadm checkout -- <file>` to take the committed version.

Then run the bootstrap, which `yadm clone` also offers to run:

```bash
yadm bootstrap
```

It sets `yadm.alt-copy` and writes the `~/bin/yadm` shim on Windows, installs
the PowerShell modules the profiles need, prompts for `local.class` if unset,
and runs `yadm alt`. It is idempotent.

Note `yadm bootstrap` takes no options — it `exec`s the script immediately, so
there is no `--help` or dry run. Anything typed after it is passed to the script.

## Editing the bootstrap

It runs with a deliberately plain environment: `GIT_DIR` unset, no `YADM_*`
variables, and `yadm` possibly not on PATH yet on a fresh machine. Resolve it:

```bash
YADM=$(command -v yadm || echo "$HOME/.yadm-project/yadm")
```

Branch on raw `uname -s` inside the script, not on yadm's `os` value —
`yadm config --get local.os` is an override that returns empty unless explicitly
set.

Commit it with the exec bit forced, or it lands non-executable on Unix and
`yadm bootstrap` refuses to run it. `core.filemode=false` on Windows means git
records `100644` otherwise:

```bash
yadm add --chmod=+x ~/.config/yadm/bootstrap
```

## Line endings

The repo tracks `.gitattributes` with `* text=auto eol=lf` plus
`*.ps1 text eol=crlf`. Without the first rule, `core.autocrlf=true` on Windows
checks out shell scripts as CRLF and they die with `bad interpreter: /bin/sh^M`.
Add such a rule before committing a new script type, not after.

## Committing

Do not commit unprompted — the user's global CLAUDE.md asks for this
explicitly, and it applies here too. Make the change, verify it, report what
changed, and let the user decide.

When they do ask, this is a personal repo: no `#noissue` or ticket prefix, just
`<type>(<scope>): <description>`.

```
feat(warp): track settings.toml as os.Msys alternate
fix(zsh): guard optional tool initialisation
chore(terminal): remove profiles for uninstalled VS versions
```

## Verifying before you report

Claiming success without checking is the failure mode that costs the most trust
here, because generated files fail silently. A quick pass:

```bash
yadm status --short --branch      # clean? how far ahead of origin?
yadm alt                          # every expected target listed?
diff <source> <target>            # generated file matches its source?
python -c "import json,sys; json.load(open(sys.argv[1]))" <file>   # JSON still valid?
```

For a file a GUI app owns, the real test is after the app has been closed and
reopened — that is when it rewrites. Ask the user to close it, then re-check.
