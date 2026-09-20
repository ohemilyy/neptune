# Neptune

```text
                 _..._
             .-'     '-.
          .-'  .-"""-.  '-.
        .'    /       \\    '.
       /     |  ~ ~ ~  |     \\
      |       \\       /       |
       \\       '.___.'       /
        '.                 .'
          '-.           .-'
             '---------'
              N E P T U N E
```

## DevOps-flavored macOS dotfiles

A ready-to-go macOS setup for people who spend too much time in terminals,
YAML files, Kubernetes clusters, and VS Code.

These are my personal dotfiles, but they are intentionally kept portable and
free of credentials so anyone can clone them, tweak a few things, and make
themselves at home. You get a nice shell, a useful DevOps toolkit, sensible Git
defaults, and a customized VS Code setup without assembling everything from
scratch.

## A quick peek

![Full VS Code setup with the Catppuccin theme and custom background](screenshots/vscode.png)

![Closer look at the editor colors, typography, minimap, and background](screenshots/vscode-editor.png)

![IntelliJ IDEA with the Tokyo Dark theme and a wallpaper behind the editor](screenshots/intellij.png)

![Closer look at the IntelliJ editor colors, inline blame, and background](screenshots/intellij-editor.png)

## What's included?

- A tidy Zsh setup with completions, aliases, and small quality-of-life helpers
- A LunaFetch greeting when a terminal opens, themed to match Neptune
- Ghostty, Starship, tmux, zoxide, fzf, bat, eza, ripgrep, and other terminal goodies
- Docker and Colima
- kubectl, Helm, k9s, kubectx, Stern, and kind
- OpenTofu, Terraform, Ansible, pre-commit, ShellCheck, and shfmt
- AWS, Azure, PowerShell, Go, Rust, Java, Python via `uv`, and Node via `fnm`
- Handy networking, security, and database tools
- VS Code settings, a big extension pack, Catppuccin styling, and a custom wallpaper
- IntelliJ IDEA plugins, the Tokyo Dark theme, a random editor wallpaper, and Discord rich presence
- An optional Intel-friendly Mac utility bundle: Stats, Rectangle, AltTab, Maccy, and KeepingYouAwake

Nothing here automatically applies infrastructure, deletes clusters, force
pushes branches, or does other exciting career-limiting things.

## Quick start

You will need macOS, an internet connection, and an administrator account.
Install Apple's command-line tools first:

```bash
xcode-select --install
```

Then install [Homebrew](https://brew.sh), clone this repo, and start the guided
setup:

```bash
git clone https://github.com/ohemilyy/neptune.git ~/dotfiles
cd ~/dotfiles
./bootstrap/macos.sh
```

The installer asks what you actually want. Docker, Kubernetes, infrastructure
tools, language runtimes, cloud CLIs, databases, networking tools, and the VS
Code profile can all be selected separately. AWS and Azure are off by default.
It can also set your Git name and email without adding them to this repository.

Existing config files are moved into a timestamped backup folder before the
dotfile links are created. It is fine to run the installer again later.

Prefer fewer questions? There are a few shortcuts:

```bash
./bootstrap/macos.sh --yes      # recommended defaults
./bootstrap/macos.sh --minimal  # shell, Git, and core CLI tools
./bootstrap/macos.sh --all      # the whole toolbox
```

The root `Brewfile` remains available if you prefer a traditional full
`brew bundle` install.

> [!TIP]
> Have a look through `Brewfile` and `bootstrap/macos.sh` before running them.
> Fork the repo and remove anything you do not want—dotfiles should feel like
> yours, not like a mysterious appliance.

## Just want the VS Code setup?

If VS Code is already installed, you can restore only the editor settings,
extensions, and wallpaper:

```bash
git clone https://github.com/ohemilyy/neptune.git ~/dotfiles
cd ~/dotfiles
./vscode/install.sh
```

The custom background extension may ask for administrator access the first time
it patches VS Code. After installation, run **Developer: Reload Window** from
the Command Palette if the wallpaper does not appear right away.

## Just want the IntelliJ plugins?

If IntelliJ IDEA is already installed, you can restore the plugins, theme,
editor background, and Discord rich presence settings. Both JetBrains Toolbox
installs and the Homebrew cask are found automatically:

```bash
git clone https://github.com/ohemilyy/neptune.git ~/dotfiles
cd ~/dotfiles
./jetbrains/install.sh
```

The editor background is picked at random from the eight wallpapers in
`jetbrains/backgrounds/`. Run the script again for a different one, drop your own
images in that folder, or point `JETBRAINS_WALLPAPER_DIR` at a folder of your
own—it is searched recursively.

Quit IntelliJ IDEA before running this—the IDE rewrites its settings when it
exits. Plugins that ship bundled with IDEA, or that are not available for your
edition, are skipped with a note.

## Vorssaint on Apple Silicon

[Vorssaint](https://github.com/vorssaint/vorssaint-utils) is available as an
optional install in the guided setup. It bundles a system monitor, network
readouts, window management, clipboard history, Keep Awake, a command bar,
Homebrew management, and a lot more into one local-first menu bar app.

For a developer-friendly starting point, try enabling:

- System Monitor and Network
- Window Layout and the app switcher
- Clipboard History and Paste as Plain Text
- Keep Awake, Command Bar, and Homebrew Manager

Vorssaint currently requires **Apple Silicon** and **macOS 14 or newer**.
Neptune checks the CPU architecture before offering it, skips it cleanly on
Intel Macs, and never grants macOS permissions automatically. Enable only the
features and permissions you actually want.

## A couple of personal bits you still need to add

Secrets and machine-specific data do not belong in this repo. You will still
need to:

- Put your Git name and email in `~/.gitconfig.local`
- Sign in to tools such as `gh`, `aws`, and `az` if you chose to install them
- Add your own SSH keys, host aliases, kubeconfigs, cloud credentials, and Tailscale login

For example:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
```

## What's where?

```text
bootstrap/   the main macOS setup script
git/         safe Git defaults (no personal identity)
ghostty/     terminal theme and key bindings
jetbrains/   IntelliJ IDEA plugins, theme, wallpapers, and installer
shell/       small .zshrc and .zprofile entry points
ssh/         non-secret macOS SSH client defaults
lunafetch/   Neptune-themed terminal greeting configuration
starship/    prompt configuration
tmux/        lightweight tmux configuration
vscode/      editor settings, extensions, wallpaper, and installer
zsh/         aliases, functions, completions, and integrations
```

## Notes for fellow tinkerers

- Python 3.13 is installed through `uv`.
- Node 22 is managed by `fnm`; it is pinned for compatibility with the included CLIs.
- The `tf` alias uses OpenTofu. Terraform is also installed for projects that need it.
- Database packages are clients only and are not started as background services.
- The prompt makes production Kubernetes contexts intentionally hard to miss.

## Credits

The VS Code settings are based on the setup by
[AndyReckt](https://github.com/andyreckt). Thanks for sharing it! 💜

Steal what you like, delete what you do not, and make something cozy. ✨
