#!/bin/bash

# Load configuration
source ./config.env

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      SECUREWALL MANAGER          ║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  1. Gérer le Firewall UFW        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  2. Gérer les ports              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  3. Détecter intrusions          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  4. Générer rapport sécurité     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  5. Quitter                      ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
    echo ""
}

# Main program
main() {
    # Check if UFW is installed
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}UFW not found. Installing...${NC}"
        sudo apt-get update
        sudo apt-get install ufw -y
    fi
    
    while true; do
        show_menu
        read -p "Veuillez choisir une option [1-5]: " choice
        
        case $choice in
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
                echo -e "${GREEN}Bye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run main
main
