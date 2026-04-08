#!/bin/bash
#
# fix-cedilla-cachyos (Baseado no script de walcew para Pop!_OS)
# Adaptado para CachyOS / Arch Linux
#
# Uso: ./fix-cedilla-arch.sh
# Reverter: ./fix-cedilla-arch.sh --revert

set -euo pipefail

BOLD=$(tput bold 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")

LANG_USER=${LANG:=pt_BR.UTF-8}
COMPOSE_DIR="/usr/share/X11/locale"
USER_COMPOSE="$HOME/.XCompose"
PROGNAME="${0##*/}"

# Pacotes específicos do Arch Linux / CachyOS
FCITX5_PACKAGES=(
  fcitx5
  fcitx5-configtool
  fcitx5-gtk
  fcitx5-qt
)

log_info()  { echo "${GREEN}[INFO]${RESET} $*"; }
log_warn()  { echo "${YELLOW}[WARN]${RESET} $*" >&2; }
log_error() { echo "${RED}[ERRO]${RESET} $*" >&2; }

# ─── Revert ──────────────────────────────────────────────────────────────────

revert() {
  echo "${BOLD}Revertendo alterações...${RESET}"
  
  if [ -f "${USER_COMPOSE}.ORIGINAL" ]; then
    mv -f "${USER_COMPOSE}.ORIGINAL" "${USER_COMPOSE}"
    log_info "Restaurado ${USER_COMPOSE} a partir do backup."
  else
    rm -f "${USER_COMPOSE}"
    log_info "Removido ${USER_COMPOSE}."
  fi

  sudo sed -i '/^GTK_IM_MODULE=/d' /etc/environment
  sudo sed -i '/^QT_IM_MODULE=/d' /etc/environment
  sudo sed -i '/^XMODIFIERS=/d' /etc/environment
  log_info "Removidas variáveis do /etc/environment."

  rm -f ~/.config/autostart/org.fcitx.Fcitx5.desktop
  rm -rf ~/.config/fcitx5
  log_info "Configurações do fcitx5 removidas."

  echo
  echo "${BOLD}Revert completo.${RESET} Reinicie o computador."
  exit 0
}

# ─── Verificações ────────────────────────────────────────────────────────────

check_prerequisites() {
  if ! command -v pacman &>/dev/null; then
    log_error "Este script requer pacman (CachyOS/Arch Linux)."
    exit 1
  fi
}

# ─── Passo 1: ~/.XCompose ────────────────────────────────────────────────────

setup_xcompose() {
  log_info "Configurando ${USER_COMPOSE}..."

  local system_compose
  system_compose="${COMPOSE_DIR}/$(sed -ne "s/^\([^:]*\):[ \t]*${LANG_USER}/\1/p" <"${COMPOSE_DIR}/compose.dir" | head -1)"

  if [ -z "${system_compose}" ] || [ ! -s "${system_compose}" ]; then
    log_warn "Não foi possível encontrar compose file para ${LANG_USER}. Usando en_US.UTF-8."
    system_compose="${COMPOSE_DIR}/en_US.UTF-8/Compose"
  fi

  if [ -s "${USER_COMPOSE}" ]; then
    cp -f "${USER_COMPOSE}" "${USER_COMPOSE}.ORIGINAL"
  fi

  # Troca ć por ç no arquivo Compose
  sed -e 's/\xc4\x87/\xc3\xa7/g' \
      -e 's/\xc4\x86/\xc3\x87/g' <"${system_compose}" >"${USER_COMPOSE}"

  log_info "~/.XCompose criado."
}

# ─── Passo 2: Instalar fcitx5 ───────────────────────────────────────────────

install_fcitx5() {
  log_info "Instalando fcitx5 e módulos..."
  sudo pacman -S --needed --noconfirm "${FCITX5_PACKAGES[@]}"
}

# ─── Passo 3: Variáveis de ambiente ─────────────────────────────────────────

setup_environment() {
  log_info "Configurando /etc/environment..."

  sudo sed -i '/^GTK_IM_MODULE=/d' /etc/environment
  sudo sed -i '/^QT_IM_MODULE=/d' /etc/environment
  sudo sed -i '/^XMODIFIERS=/d' /etc/environment
  
  echo "GTK_IM_MODULE=fcitx" | sudo tee -a /etc/environment > /dev/null
  echo "QT_IM_MODULE=fcitx"  | sudo tee -a /etc/environment > /dev/null
  echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment > /dev/null
}

# ─── Passo 4: Configurar fcitx5 ─────────────────────────────────────────────

configure_fcitx5() {
  log_info "Configurando layout no fcitx5..."

  mkdir -p ~/.config/fcitx5
  cat > ~/.config/fcitx5/profile << 'EOF'
[Groups/0]
Name=Default
Default Layout=us-intl
DefaultIM=keyboard-us-intl

[Groups/0/Items/0]
Name=keyboard-us-intl
Layout=

[GroupOrder]
0=Default
EOF

  # Autostart
  mkdir -p ~/.config/autostart
  if [ -f /usr/share/applications/org.fcitx.Fcitx5.desktop ]; then
    cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
  if [[ "${1:-}" == "--revert" ]]; then
    revert
  fi

  check_prerequisites
  setup_xcompose
  install_fcitx5
  setup_environment
  configure_fcitx5

  echo
  echo "${GREEN}${BOLD}Pronto! A cedilha foi configurada via Fcitx5.${RESET}"
  echo "Reinicie sua sessão (Logout ou Reboot) para as mudanças valerem."
}

main "$@"
