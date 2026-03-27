#!/bin/bash
# ============================================================
#  SecureWall — Menu Principal Interactif
#  Version 1.0
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

# ── Couleurs ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# ── Utilitaires ─────────────────────────────────────────────
clear_screen() { clear; }

print_banner() {
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║                                      ║"
    echo "  ║        SECUREWALL MANAGER  v1.0      ║"
    echo "  ║        Gestionnaire de Sécurité      ║"
    echo "  ║                                      ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_status_bar() {
    local ufw_status
    if command -v ufw &>/dev/null; then
        ufw_status=$(ufw status 2>/dev/null | head -1 | awk '{print $2}')
        [ "$ufw_status" = "active" ] \
            && echo -e "  ${DIM}Firewall :${RESET} ${GREEN}● actif${RESET}     ${DIM}│${RESET}  ${DIM}$(date '+%d/%m/%Y %H:%M')${RESET}" \
            || echo -e "  ${DIM}Firewall :${RESET} ${RED}● inactif${RESET}   ${DIM}│${RESET}  ${DIM}$(date '+%d/%m/%Y %H:%M')${RESET}"
    else
        echo -e "  ${DIM}Firewall :${RESET} ${YELLOW}● ufw absent${RESET}  ${DIM}│${RESET}  ${DIM}$(date '+%d/%m/%Y %H:%M')${RESET}"
    fi
    echo ""
}

print_menu() {
    echo -e "  ${WHITE}${BOLD}Que souhaitez-vous faire ?${RESET}"
    echo ""
    echo -e "  ${CYAN}┌─────────────────────────────────────┐${RESET}"
    echo -e "  ${CYAN}│${RESET}  ${YELLOW}1${RESET}  Gérer le Firewall UFW           ${CYAN}│${RESET}"
    echo -e "  ${CYAN}│${RESET}  ${YELLOW}2${RESET}  Gérer les ports                 ${CYAN}│${RESET}"
    echo -e "  ${CYAN}│${RESET}  ${YELLOW}3${RESET}  Détecter les intrusions         ${CYAN}│${RESET}"
    echo -e "  ${CYAN}│${RESET}  ${YELLOW}4${RESET}  Générer un rapport de sécurité  ${CYAN}│${RESET}"
    echo -e "  ${CYAN}│${RESET}  ${RED}5${RESET}  Quitter                         ${CYAN}│${RESET}"
    echo -e "  ${CYAN}└─────────────────────────────────────┘${RESET}"
    echo ""
}



# ── Boucle principale ────────────────────────────────────────
main() {
    
    while true; do
        clear_screen
        print_banner
        print_status_bar
        print_menu

        echo -ne "  ${WHITE}Votre choix${RESET} ${DIM}[1-5]${RESET} : "
        read -r choice

        case "$choice" in
            1)
                ./ufw_manager.sh
                ;;
            2)
                ./ports_manager.sh
                ;;
            3)
                ./intrusion.sh
                ;;
            4)
                ./rapport.sh
                ;;
            5)
                clear_screen
                echo -e "\n  ${CYAN}Au revoir. Votre système reste protégé. ${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "\n  ${RED}✗  Choix invalide. Veuillez entrer un chiffre entre 1 et 5.${RESET}"
                sleep 1.5
                ;;
        esac

        echo ""
        echo -ne "  ${DIM}Appuyez sur Entrée pour revenir au menu...${RESET}"
        read -r
    done
}

main "$@"
