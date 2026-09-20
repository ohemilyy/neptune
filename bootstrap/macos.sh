#!/bin/zsh
set -euo pipefail

repo_dir="${0:A:h:h}"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mode="interactive"

usage() {
  cat <<'HELP'
Usage: ./bootstrap/macos.sh [--all | --minimal | --yes]

  no flags    friendly guided setup
  --yes       install the recommended defaults without questions
  --minimal   shell, Git, and core command-line tools only
  --all       install every tool group (sign-ins are still manual)
HELP
}

for arg in "$@"; do
  case "$arg" in
    --all|--minimal|--yes) mode="${arg#--}" ;;
    -h|--help) usage; exit 0 ;;
    *) print -u2 "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

if [[ "$mode" == interactive && ! -t 0 ]]; then
  print -u2 "Interactive mode needs a terminal. Try --yes, --minimal, or --all."
  exit 1
fi

say() {
  print
  print "  ✦ $1"
}

ask() {
  local prompt="$1"
  local default="${2:-n}"
  local reply

  if [[ "$mode" == all ]]; then
    return 0
  elif [[ "$mode" == minimal ]]; then
    return 1
  elif [[ "$mode" == yes ]]; then
    [[ "$default" == y ]]
    return
  fi

  if [[ "$default" == y ]]; then
    read "reply?$prompt [Y/n] "
    [[ -z "$reply" || "$reply" == [Yy]* ]]
  else
    read "reply?$prompt [y/N] "
    [[ "$reply" == [Yy]* ]]
  fi
}

install_formulae() {
  if (( $# == 0 )); then
    return
  fi
  brew install "$@"
}

install_casks() {
  if (( $# == 0 )); then
    return
  fi
  brew install --cask "$@"
}

link_config() {
  local source="$1"
  local target="$2"

  mkdir -p "${target:h}"

  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$backup_dir"
    mv "$target" "$backup_dir/${target:t}"
    print "    backed up $target"
  fi

  ln -sfn "$source" "$target"
  print "    linked $target"
}

[[ "$OSTYPE" == "darwin"* ]] || {
  print -u2 "This script is for macOS only."
  exit 1
}

print
print '                 _..._'
print "             .-'     '-."
print "          .-'  .-\"\"\"-.  '-."
print "        .'    /       \\    '."
print '       /     |  ~ ~ ~  |     \\'
print "      |       \\       /       |"
print "       \\       '.___.'       /"
print "        '.                 .'"
print "          '-.           .-'"
print "             '---------'"
print '              N E P T U N E'
print
print "  🚀 Neptune setup"
print "  A cozy shell and a pick-your-own DevOps toolbox."
print
print "  Nothing will sign in to cloud accounts or copy credentials automatically."
print "  Existing config files are backed up before links are created."

command -v brew >/dev/null || {
  print -u2
  print -u2 "  Homebrew is not installed yet."
  print -u2 "  Install it from https://brew.sh, then run this script again."
  exit 1
}

core_formulae=(
  starship zoxide fzf bat eza ripgrep fd jq yq tree wget watch
  tmux htop btop direnv git git-lfs gh
)
core_casks=(ghostty font-jetbrains-mono-nerd-font)

say "Installing the shell and everyday command-line tools"
install_formulae "${core_formulae[@]}"
install_casks "${core_casks[@]}"

want_containers=false
want_kubernetes=false
want_iac=false
want_languages=false
want_aws=false
want_azure=false
want_network=false
want_databases=false
want_vscode=false
want_jetbrains=false
want_vorssaint=false
want_lunafetch=false
want_mac_utilities=false

ask "Install Docker and Colima?" y && want_containers=true
ask "Install Kubernetes tools (kubectl, Helm, k9s, kind, and friends)?" y && want_kubernetes=true
ask "Install infrastructure tools (OpenTofu, Terraform, Ansible, and linters)?" y && want_iac=true
ask "Install developer runtimes (Python, Node, Go, Rust, and Java)?" y && want_languages=true
ask "Install the AWS CLI?" n && want_aws=true
ask "Install Azure CLI and PowerShell?" n && want_azure=true
ask "Install networking and security tools?" n && want_network=true
ask "Install database clients?" n && want_databases=true
ask "Install the customized VS Code profile and extensions?" y && want_vscode=true
ask "Install IntelliJ IDEA and its plugins?" n && want_jetbrains=true
ask "Install LunaFetch as your terminal greeting?" y && want_lunafetch=true
ask "Install Mac utilities (Stats, Rectangle, AltTab, Maccy, and Keep Awake)?" y && want_mac_utilities=true

if [[ "$(uname -m)" == arm64 ]]; then
  ask "Install Vorssaint, the local-first Mac utility toolbox?" n && want_vorssaint=true
else
  print "    Vorssaint skipped: it currently requires an Apple Silicon Mac."
fi

if $want_containers; then
  say "Installing container tools"
  install_formulae docker docker-compose colima
fi

if $want_kubernetes; then
  say "Installing Kubernetes tools"
  install_formulae kubernetes-cli helm k9s kubectx stern kind
fi

if $want_iac; then
  say "Installing infrastructure and automation tools"
  install_formulae opentofu ansible pre-commit shellcheck shfmt
  brew tap hashicorp/tap
  brew trust --formula hashicorp/tap/terraform
  install_formulae hashicorp/tap/terraform
fi

if $want_languages; then
  say "Installing language runtimes"
  install_formulae fnm uv go rustup openjdk

  uv python install 3.13 --default

  eval "$(fnm env --shell zsh)"
  fnm install 22
  fnm default 22
  fnm use 22
  corepack disable 2>/dev/null || true
  npm install --global pnpm@10.34.5

  export PATH="$(brew --prefix rustup)/bin:$PATH"
  rustup default stable
fi

if $want_aws; then
  say "Installing AWS CLI"
  install_formulae awscli
fi

if $want_azure; then
  say "Installing Azure CLI and PowerShell"
  install_formulae azure-cli powershell
fi

if $want_network; then
  say "Installing networking and security tools"
  install_formulae nmap mtr iperf3 socat doggo httpie openssl@3 age sops
  install_casks wireshark-app
fi

if $want_databases; then
  say "Installing database clients"
  install_formulae libpq redis
  install_casks dbeaver-community
fi

if $want_lunafetch; then
  say "Building LunaFetch"

  if ! command -v cargo >/dev/null 2>&1; then
    install_formulae rustup
    export PATH="$(brew --prefix rustup)/bin:$PATH"
    rustup default stable
  fi

  lunafetch_source="$(mktemp -d /tmp/lunafetch-build.XXXXXX)"
  git clone --depth 1 https://github.com/ohemilyy/lunafetch.git "$lunafetch_source"
  cargo install --path "$lunafetch_source" --root "$HOME/.local" --locked
fi

if $want_mac_utilities; then
  say "Installing Mac quality-of-life utilities"
  install_casks stats rectangle alt-tab maccy keepingyouawake
fi

say "Linking the dotfiles"
link_config "$repo_dir/zsh" "$config_dir/zsh"
link_config "$repo_dir/ghostty" "$config_dir/ghostty"
link_config "$repo_dir/starship/starship.toml" "$config_dir/starship.toml"
if $want_lunafetch; then
  link_config "$repo_dir/lunafetch" "$config_dir/lunafetch"
fi
link_config "$repo_dir/shell/zshrc" "$HOME/.zshrc"
link_config "$repo_dir/shell/zprofile" "$HOME/.zprofile"
link_config "$repo_dir/tmux/tmux.conf" "$HOME/.tmux.conf"
link_config "$repo_dir/git/config" "$HOME/.gitconfig"
link_config "$repo_dir/ssh/00-workstation.conf" "$HOME/.ssh/config.d/00-workstation.conf"

git lfs install --skip-repo

if $want_vscode; then
  say "Installing VS Code and its profile"
  install_casks visual-studio-code
  "$repo_dir/vscode/install.sh"
fi

if $want_jetbrains; then
  say "Installing IntelliJ IDEA and its plugins"
  install_casks intellij-idea
  "$repo_dir/jetbrains/install.sh"
fi

if $want_vorssaint; then
  say "Installing Vorssaint"
  install_casks vorssaint
fi

if $want_lunafetch; then
  print "  LunaFetch will greet you once when a real terminal opens."
fi

if $want_mac_utilities; then
  print "  Open Stats, Rectangle, AltTab, Maccy, and KeepingYouAwake once."
  print "  macOS will ask for Accessibility access only where it is needed."
fi

if [[ "$mode" == interactive ]]; then
  say "Personalizing Git"

  current_name="$(git config --file "$HOME/.gitconfig.local" user.name 2>/dev/null || true)"
  current_email="$(git config --file "$HOME/.gitconfig.local" user.email 2>/dev/null || true)"

  if [[ -n "$current_name" && -n "$current_email" ]]; then
    print "    Current identity: $current_name <$current_email>"
  fi

  if ask "Set or update your Git name and email now?" y; then
    read "git_name?Git name: "
    read "git_email?Git email: "

    if [[ -n "$git_name" && "$git_email" == *@*.* ]]; then
      git config --file "$HOME/.gitconfig.local" user.name "$git_name"
      git config --file "$HOME/.gitconfig.local" user.email "$git_email"
      print "    saved to ~/.gitconfig.local"
    else
      print "    skipped: the name or email looked incomplete"
    fi
  fi

  if ! gh auth status >/dev/null 2>&1 && ask "Sign in to GitHub CLI now?" n; then
    gh auth login
  fi

  if $want_aws && ask "Run AWS credential setup now?" n; then
    aws configure
  fi

  if $want_azure && ask "Sign in to Azure now?" n; then
    az login
  fi
fi

print
print "  ✨ All done."
print "  Open a new terminal to load the shell changes."

if [[ -d "$backup_dir" ]]; then
  print "  Previous config files were saved in $backup_dir"
fi

if $want_containers; then
  print "  Start Docker when you need it with: colima start"
fi

if $want_vscode; then
  print "  Reload VS Code once to activate the theme and background."
fi

if $want_jetbrains; then
  print "  Restart IntelliJ IDEA once to load the new plugins."
fi

if $want_vorssaint; then
  print "  Open Vorssaint and try: System Monitor, Network, Window Layout,"
  print "  Clipboard History, Keep Awake, Command Bar, and Homebrew Manager."
  print "  Only grant the macOS permissions needed by features you enable."
fi
