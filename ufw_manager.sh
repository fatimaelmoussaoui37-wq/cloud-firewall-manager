#!/bin/bash
# ============================================================
#  SecureWall — Gestionnaire UFW
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# ── Logging ──────────────────────────────────────────────────
log_action() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [UFW] $msg" >> "$FIREWALL_LOG"
}

# ── Vérifie si UFW est installé ───────────────────────────────
check_ufw() {
    if ! command -v ufw &>/dev/null; then
        echo -e "\n  ${RED}✗  UFW n'est pas installé.${RESET}"
        echo -e "  ${DIM}Installez-le avec : apt install ufw${RESET}\n"
        return 1
    fi
    return 0
}

# ── Affiche le statut UFW ─────────────────────────────────────
show_status() {
    echo -e "\n  ${WHITE}${BOLD}── Statut UFW ──────────────────────────────${RESET}"
    echo ""

    local raw_status
    raw_status=$(ufw status verbose 2>/dev/null)
    local first_line
    first_line=$(echo "$raw_status" | head -1)

    if echo "$first_line" | grep -q "active"; then
        echo -e "  ${GREEN}● Firewall ACTIF${RESET}"
    else
        echo -e "  ${RED}● Firewall INACTIF${RESET}"
    fi

    echo ""
    echo -e "  ${DIM}Règles actives :${RESET}"
    echo -e "  ${CYAN}─────────────────────────────────────────────${RESET}"

    local rules
    rules=$(ufw status numbered 2>/dev/null | grep -E "^\[")
    if [ -z "$rules" ]; then
        echo -e "  ${DIM}  Aucune règle configurée.${RESET}"
    else
        while IFS= read -r line; do
            echo -e "  $line"
        done <<< "$rules"
    fi

    echo -e "  ${CYAN}─────────────────────────────────────────────${RESET}"
}

# ── Activer UFW ───────────────────────────────────────────────
enable_ufw() {
    echo -e "\n  ${YELLOW}⚡ Activation du firewall UFW...${RESET}"
    echo -ne "  ${WHITE}Confirmer l'activation ? [o/N] : ${RESET}"
    read -r confirm
    if [[ "$confirm" =~ ^[oOyY]$ ]]; then
        ufw --force enable 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓  Firewall activé avec succès.${RESET}"
            log_action "Firewall activé par l'utilisateur $(logname 2>/dev/null || echo root)"
        else
            echo -e "  ${RED}✗  Échec de l'activation.${RESET}"
        fi
    else
        echo -e "  ${DIM}  Opération annulée.${RESET}"
    fi
}

# ── Désactiver UFW ────────────────────────────────────────────
disable_ufw() {
    echo -e "\n  ${RED}⚠  ATTENTION : Désactivation du firewall !${RESET}"
    echo -ne "  ${WHITE}Confirmer la désactivation ? [o/N] : ${RESET}"
    read -r confirm
    if [[ "$confirm" =~ ^[oOyY]$ ]]; then
        ufw disable 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${YELLOW}✓  Firewall désactivé.${RESET}"
            log_action "Firewall DÉSACTIVÉ par l'utilisateur $(logname 2>/dev/null || echo root)"
        else
            echo -e "  ${RED}✗  Échec de la désactivation.${RESET}"
        fi
    else
        echo -e "  ${DIM}  Opération annulée.${RESET}"
    fi
}

# ── Réinitialiser UFW ─────────────────────────────────────────
reset_ufw() {
    echo -e "\n  ${RED}⚠  DANGER : Toutes les règles seront supprimées !${RESET}"
    echo -ne "  ${WHITE}Confirmer la réinitialisation ? [o/N] : ${RESET}"
    read -r confirm
    if [[ "$confirm" =~ ^[oOyY]$ ]]; then
        ufw --force reset 2>/dev/null
        echo -e "  ${GREEN}✓  Règles réinitialisées.${RESET}"
        log_action "Firewall RÉINITIALISÉ — toutes les règles supprimées"
    else
        echo -e "  ${DIM}  Opération annulée.${RESET}"
    fi
}

# ── Menu UFW ──────────────────────────────────────────────────
main() {
    check_ufw || return

    clear
    echo -e "\n  ${CYAN}${BOLD}🔥  Gestionnaire UFW${RESET}"
    show_status
    echo ""
    echo -e "  ${WHITE}${BOLD}Options disponibles :${RESET}"
    echo -e "  ${DIM}──────────────────────${RESET}"
    echo -e "  ${YELLOW}1${RESET}  Activer le firewall"
    echo -e "  ${YELLOW}2${RESET}  Désactiver le firewall"
    echo -e "  ${YELLOW}3${RESET}  Réinitialiser toutes les règles"
    echo -e "  ${YELLOW}4${RESET}  Afficher le statut détaillé"
    echo -e "  ${RED}0${RESET}  Retour au menu principal"
    echo ""
    echo -ne "  ${WHITE}Votre choix${RESET} ${DIM}[0-4]${RESET} : "
    read -r choice

    case "$choice" in
        1) enable_ufw ;;
        2) disable_ufw ;;
        3) reset_ufw ;;
        4) show_status ;;
        0) return ;;
        *) echo -e "  ${RED}✗  Choix invalide.${RESET}" ;;
    esac
}

main "$@"
